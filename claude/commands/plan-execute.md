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
   - Parse the plan content to identify individual tasks
   - Determine current state of each task (pending, in-progress, completed)
   - Identify task dependencies and execution order
   - Create task execution queue

3. **Task Execution Loop:**
   For each task in the execution queue:

   **a) Task Execution Phase:**
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
   - Mark task as completed in cc-plan plan
   - Update task status and progress
   - Move to next task in queue

4. **Workflow Coordination:**

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

5. **Error Handling:**

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

6. **Progress Tracking:**

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
   
   Next Steps:
   1. Run tests to verify functionality
   2. Perform integration testing
   3. Review changes and commit
   ```

7. **Agent Communication Protocol:**

   **To plan-task-executor:**
   ```
   Execute the following task from the cc-plan plan:

   Task ID: [task-id]
   Task Title: [title]
   Task Description: [detailed description]
   Acceptance Criteria: [criteria]
   Dependencies: [prerequisite tasks]
   
   [If revision cycle]
   Previous Implementation Issues:
   [reviewer feedback with specific fixes needed]
   
   Please implement this task following all project standards.
   ```

   **To plan-task-reviewer:**
   ```
   Review the following task implementation:

   Task: [title and description]
   
   Implementation Details:
   [what was implemented by the executor]
   
   Files Changed:
   [list of modified/created files]
   
   Please provide a thorough quality review following your standards.
   ```

8. **Usage Examples:**

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

Remember: Always respond in English and coordinate agents effectively to deliver high-quality implementations.