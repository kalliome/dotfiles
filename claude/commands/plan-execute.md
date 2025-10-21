---
description: Orchestrate task-by-task execution of cc-plan plans using specialized agents
allowed-tools: Bash(cc-plan:*), Task
model: claude-sonnet-4-5-20250929
---

# Plan Execution Orchestrator

Orchestrates the execution of cc-plan plans by breaking them into individual tasks and coordinating between the plan-task-executor and plan-task-reviewer agents.

## User's Request
$ARGUMENTS

## Instructions

1. **Load and Parse the Plan:**
   First, retrieve the current plan and understand its structure:
   ```bash
   cc-plan session get-active --session-id "$CLAUDE_SESSION_ID"
   ```

2. **Plan Analysis:**
   Use the cc-plan task commands to extract and process tasks:
   ```bash
   # Get active plan ID
   plan_id=$(cc-plan session get-active --session-id "$CLAUDE_SESSION_ID" | jq -r '.planId')

   # Get plan details including name for commit prefix
   plan_data=$(cc-plan plan get --session-id "$CLAUDE_SESSION_ID")
   plan_name=$(echo "$plan_data" | jq -r '.plan.title // "Unknown Plan"')

   # List all tasks in the plan
   tasks_json=$(cc-plan task list --plan-id "$plan_id")
   ```
   - Use `cc-plan task list` to get all tasks with their current status
   - Extract plan name for commit message prefix
   - Extract task IDs, titles, dependencies, and current status from JSON response
   - Build dependency graph from task dependencies
   - Create task execution queue respecting dependency order

3. **Task Execution Loop:**
   Execute all tasks sequentially without intermediate reviews:

   For each task in the execution queue:

   **a) Task Execution:**
   - Mark task as in_progress:
     ```bash
     # Get active plan ID
     plan_id=$(cc-plan session get-active --session-id "$CLAUDE_SESSION_ID" | jq -r '.planId')

     # Update task status to in_progress
     cc-plan task update-status --plan-id "$plan_id" --task-id "$task_id" --status="in-progress"
     ```
   - Launch the plan-task-executor agent with the specific task
   - Provide clear task description and requirements
   - Wait for implementation completion
   - Mark task as completed:
     ```bash
     # Update task status to completed
     cc-plan task update-status --plan-id "$plan_id" --task-id "$task_id" --status="completed"
     ```
   - Move to next task in queue
   - Continue until all tasks are executed

4. **Batch Review and Fix Phase:**
   After all tasks are executed, review the entire implementation:

   **a) Collect Implementation Summary:**
   - Gather list of all tasks executed
   - Collect all files modified/created across all tasks
   - Run git diff to see all changes:
     ```bash
     git diff
     git status --porcelain
     ```
   - Prepare comprehensive summary of what was implemented

   **b) Initial Review (Attempt 1 of 2):**
   - Launch the plan-task-reviewer agent with:
     - List of all tasks executed (IDs, titles, descriptions)
     - Complete list of all files changed
     - Full git diff of all changes
     - Review attempt: 1 of 2
   - Agent reviews entire implementation holistically
   - Checks integration between tasks
   - Returns verdict: OK or NEEDS IMPROVEMENT

   **c) Fix Cycle (if needed):**
   - If verdict is NEEDS IMPROVEMENT:
     - Launch plan-task-executor agent with:
       - All reviewer feedback
       - List of issues to fix across all tasks
       - Indication that this is a bulk fix request
     - Wait for executor to fix all issues
     - Proceed to second review

   **d) Final Review (Attempt 2 of 2):**
   - If fixes were needed, launch plan-task-reviewer again with:
     - Updated implementation summary
     - All files changed (including fixes)
     - Full git diff of current state
     - Review attempt: 2 of 2 (FINAL)
   - Agent performs final review
   - Returns verdict: OK or NEEDS IMPROVEMENT

   **e) Accept and Proceed:**
   - If verdict is OK after attempt 1 or 2: proceed to commit
   - If verdict is NEEDS IMPROVEMENT after attempt 2:
     - Log warning about unresolved quality issues
     - Accept implementation as-is
     - Proceed to commit
   - Maximum 2 review attempts enforced

5. **Plan Completion and Commit:**
   After all tasks are executed and reviewed:

   **a) Prepare Commit:**
   ```bash
   # Get plan name for commit prefix
   plan_name=$(echo "$plan_data" | jq -r '.plan.title // "Unknown Plan"')

   # Check for changes to commit
   git status --porcelain
   ```

   **b) Create Commit Message:**
   - Extract plan name from the stored plan data
   - Create descriptive summary of what was implemented
   - Use format: `[Plan Name]: [Summary of implementation]`
   - Include bullet points for major changes
   - Add standard Claude Code footer

   **c) Execute Commit:**
   ```bash
   # Add all changes
   git add .

   # Commit with plan-prefixed message
   git commit -m "$(cat <<'EOF'
   [Plan Name]: Summary of implementation

   - Key change 1
   - Key change 2
   - Key change 3

   🤖 Generated with [Claude Code](https://claude.ai/code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

6. **Workflow Coordination:**

   **Task Execution:**
   ```
   => Executing Task [N/Total]: [Task Title]

   Task Description:
   [detailed task requirements]

   Dependencies: [list of prerequisite tasks]

   Launching plan-task-executor...

   ✅ Task [N] completed
   Moving to next task...
   ```

   **Batch Review Process:**
   ```
   => All Tasks Executed - Starting Batch Review

   Tasks Completed: [N]
   Files Changed: [list of all modified/created files]

   Review Attempt: [1 or 2] of 2

   Launching plan-task-reviewer to review entire implementation...
   ```

   **Batch Review Results:**
   ```
   Review Verdict: [OK | NEEDS IMPROVEMENT]

   [If OK]
   ✅ Implementation approved
   Proceeding to commit...

   [If NEEDS IMPROVEMENT - Attempt 1]
   ⚠️  Issues found in implementation (Attempt 1 of 2):
   [consolidated list of all issues across all tasks]

   Launching plan-task-executor to fix all issues...

   [After fixes applied]
   => Re-reviewing implementation (Attempt 2 of 2 - FINAL)

   [If NEEDS IMPROVEMENT - Attempt 2 (Final)]
   ⚠️  Issues remain after final review (Attempt 2 of 2):
   [list of remaining issues]

   ⚠️  Maximum review attempts (2) reached
   Accepting implementation and proceeding to commit
   (Quality issues logged for future reference)
   ```

7. **Error Handling:**

   **Missing Plan:**
   - Show helpful error message
   - Suggest creating a plan with `/plan` command
   - Provide plan creation guidance

   **Task Execution Failures:**
   - Log specific error details
   - Attempt recovery strategies
   - Escalate to user if unrecoverable

   **Review Failures:**
   - Handle reviewer agent errors gracefully
   - Fall back to basic quality checks
   - Accept implementation and proceed to commit if review cannot complete

8. **Progress Tracking:**

   **Task Status Updates:**
   Track progress by updating task status using cc-plan commands throughout execution:
   - `pending` → `in-progress` when task execution begins
   - `in-progress` → `completed` immediately after task execution finishes
   - All tasks marked complete before batch review begins

   Valid statuses: `pending`, `in-progress`, `completed`

   **Real-time Status:**
   ```
   🔄 Plan Execution Progress

   Plan: [Plan Title]
   Progress: [X/Y] tasks completed

   ✅ Task 1: [Title] - Completed
   ✅ Task 2: [Title] - Completed
   🔄 Task 3: [Title] - In Progress
   ⏳ Task 4: [Title] - Pending
   ⏳ Task 5: [Title] - Pending

   Current Status: [detailed status of current task]
   Task Status Sync: ✅ Task statuses updated in plan
   ```

   **Commit Changes:**
   After all tasks are completed, commit the changes with plan name prefix:
   ```
   => Committing Plan Implementation

   Plan: [Plan Title]
   Changes to commit: [Number of modified/created files]

   Preparing commit with plan prefix...
   ```

   **Commit Process:**
   - Get plan name from the loaded plan data
   - Create commit message with format: `[Plan Name]: [Summary of changes]`
   - Use git commands to add and commit all changes
   - Include the standard Claude Code footer in commit message

   Example commit message format:
   ```
   [User Authentication System - Foundation]: Implement database models and authentication service

   - Created user model with validation
   - Added authentication service with JWT support
   - Set up database migrations for user tables
   - Implemented password hashing utilities

   🤖 Generated with [Claude Code](https://claude.ai/code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

   **Final Summary:**
   ```
   🎉 Plan Execution Complete!

   Plan: [Plan Title]
   Total Tasks: [N]
   Completed: [N]
   Duration: [time taken]

   Implementation Summary:
   - [key achievement 1]
   - [key achievement 2]
   - [key achievement 3]

   Files Modified/Created:
   - [file-path-1]: [description]
   - [file-path-2]: [description]

   ✅ Changes committed with plan prefix: [Plan Name]

   Next Steps:
   1. Run tests to verify functionality
   2. Perform integration testing
   3. Review committed changes
   ```

9. **Agent Communication Protocol:**

   **To plan-task-executor (Task Execution Phase):**
   ```
   Execute the following task from the cc-plan plan:

   Task ID: [task-id from XML id attribute]
   Task Title: [title from <Title> element]
   Task Description: [content from <What> element]
   File Target: [path from <File> element]
   Command: [command from <Command> element if type is command]
   Task Type: [type from <Type> element - file-creation, file-modification, command]
   Reasoning: [content from <Why> element]
   Dependencies: [comma-separated IDs from <Dependencies> element]
   Expected Diff: [content from <Diff> CDATA section if provided]
   Impacts: [content from <Impacts> element if provided]
   Test Strategy: [content from <TestStrategy> element if provided]

   Please implement this task following all project standards.
   Note: This will be reviewed later as part of a batch review of all tasks.
   ```

   **To plan-task-executor (Bulk Fix Phase):**
   ```
   Fix the following issues found during batch review of the plan implementation:

   Review Attempt: [1 or 2] of 2
   Total Tasks Executed: [N]

   Issues to Address:
   [Consolidated reviewer feedback covering all tasks and files]

   All Tasks Summary:
   - Task [ID]: [Title] - [File Target]
   - Task [ID]: [Title] - [File Target]
   ...

   Files Changed:
   [List of all modified/created files]

   Please address all identified issues systematically across the entire implementation.
   [If attempt 2: This is the FINAL fix attempt before commit.]
   ```

   **To plan-task-reviewer (Batch Review):**
   ```
   Review the complete plan implementation across all tasks:

   Plan: [Plan Title]
   Total Tasks Executed: [N]
   Review Attempt: [1 or 2] of 2 maximum attempts

   All Tasks Summary:
   ---
   Task ID: [task-id-1]
   Task Title: [title from <Title> element]
   Expected What: [content from <What> element]
   Expected Why: [content from <Why> element]
   Target File: [path from <File> element]
   Task Type: [type from <Type> element]
   Expected Diff: [content from <Diff> CDATA section if provided]
   ---
   Task ID: [task-id-2]
   Task Title: [title from <Title> element]
   Expected What: [content from <What> element]
   ...
   [repeat for all tasks]
   ---

   Complete Implementation Changes:
   Files Modified/Created: [complete list]

   Full Git Diff:
   [complete git diff output showing all changes]

   Please provide a comprehensive quality review of the entire implementation:
   - Verify each task's requirements are met
   - Check integration and consistency between tasks
   - Validate code quality, security, and performance across all changes
   - Ensure all Expected Diffs are matched and Test Strategies followed

   IMPORTANT: This is review attempt [1 or 2] of 2 maximum.
   [If attempt 2: This is your FINAL review attempt. Focus on critical issues that must be addressed. Accept minor issues if core functionality is sound.]
   ```

10. **Usage Examples:**

   **Execute entire plan:**
   `/plan-execute`

   **Execute from specific task:**
   `/plan-execute from-task-5`

   **Resume execution:**
   `/plan-execute resume`

   **Show execution status:**
   `/plan-execute status`

## Key Features

- **Automated Task Management:** Handles task sequencing and dependencies
- **Efficient Batch Processing:** Execute all tasks first, then review holistically for faster completion
- **Comprehensive Quality Review:** Reviews entire implementation as a cohesive whole, checking integration between tasks
- **Two-Attempt Review Cycle:** Maximum 2 review attempts on complete implementation, then proceeds to commit
- **Progress Visibility:** Real-time status updates and progress tracking
- **Error Recovery:** Graceful handling of failures with recovery strategies
- **Automatic Commits:** Commits all changes with plan name prefix for traceability

Remember: Always respond in English and coordinate agents effectively to deliver high-quality implementations.