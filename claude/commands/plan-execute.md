---
description: Orchestrate task-by-task execution of cc-plan plans using specialized agents
allowed-tools: Bash(cc-plan:*), Task
model: claude-opus-4-1-20250805
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
   For each task in the execution queue:

   **a) Task Execution Phase:**
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

   **b) Review Phase:**
   - Launch the plan-task-reviewer agent to review the implementation
   - Provide task context and implementation details
   - Assess review verdict (OK or NEEDS IMPROVEMENT)

   **c) Improvement Loop (if needed):**
   - If reviewer finds issues, relay feedback to plan-task-executor
   - Continue executor → reviewer cycles until review passes
   - Ensure all quality standards are met

   **d) Task Completion:**
   - Mark task as completed:
     ```bash
     # Get active plan ID
     plan_id=$(cc-plan session get-active --session-id "$CLAUDE_SESSION_ID" | jq -r '.planId')

     # Update task status to completed
     cc-plan task update-status --plan-id "$plan_id" --task-id "$task_id" --status="completed"
     ```
   - Move to next task in queue

4. **Plan Completion and Commit:**
   After all tasks are completed successfully:

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

5. **Workflow Coordination:**

   **Task Execution:**
   ```
   => Executing Task [N/Total]: [Task Title]
   
   Task Description:
   [detailed task requirements]
   
   Dependencies: [list of prerequisite tasks]
   
   Launching plan-task-executor...
   ```

   **Review Process:**
   ```
   => Reviewing Implementation for Task [N]: [Task Title]
   
   Implementation Summary:
   [what was implemented]
   
   Launching plan-task-reviewer...
   ```

   **Review Results:**
   ```
   Review Verdict: [OK | NEEDS IMPROVEMENT]
   
   [If OK]
   ✅ Task [N] completed successfully
   Moving to next task...
   
   [If NEEDS IMPROVEMENT]
   ⚠️  Issues found, requesting fixes:
   [list of issues]
   
   Re-launching plan-task-executor with feedback...
   ```

6. **Error Handling:**

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
   - Continue with next task if possible

7. **Progress Tracking:**

   **Task Status Updates:**
   Track progress by updating task status using cc-plan commands throughout execution:
   - `pending` → `in-progress` when task execution begins
   - `in-progress` → `completed` when task passes review
   - Status remains `in-progress` during revision cycles

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

8. **Agent Communication Protocol:**

   **To plan-task-executor:**
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

   [If revision cycle]
   Previous Implementation Issues:
   [reviewer feedback with specific fixes needed]

   Please implement this task following all project standards.
   ```

   **To plan-task-reviewer:**
   ```
   Review the following task implementation:

   Task ID: [task-id from XML]
   Task Title: [title from <Title> element]
   Expected What: [content from <What> element]
   Expected Why: [content from <Why> element]
   Target File: [path from <File> element]
   Command: [command from <Command> element if applicable]
   Task Type: [type from <Type> element]
   Expected Diff: [content from <Diff> CDATA section if provided]
   Expected Impacts: [content from <Impacts> element if provided]
   Test Strategy: [content from <TestStrategy> element if provided]

   Implementation Details:
   [what was implemented by the executor]

   Files Changed:
   [list of modified/created files]

   Please provide a thorough quality review following your standards.
   Validate that the implementation matches the Expected Diff if provided.
   Ensure Test Strategy is followed if specified.
   ```

9. **Usage Examples:**

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
- **Quality Assurance:** Ensures every task meets standards before proceeding
- **Progress Visibility:** Real-time status updates and progress tracking
- **Error Recovery:** Graceful handling of failures with recovery strategies
- **Iterative Improvement:** Automatic revision cycles until quality standards are met
- **Automatic Commits:** Commits all changes with plan name prefix for traceability

Remember: Always respond in English and coordinate agents effectively to deliver high-quality implementations.