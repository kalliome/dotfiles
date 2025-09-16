---
description: Execute tasks from plans, review implementations, and guide applying diffs to codebase
allowed-tools: Bash(claude-memory:*), Read
model: claude-opus-4-1-20250805
---

# Task Execution Command

Execute implementation tasks generated from plans, review their diffs, and provide guidance on applying changes to your codebase.

## User's Request
$ARGUMENTS

## Instructions

1. **Check for Active Session Plan:**
   First, check if there's an active plan for this session:
   ```bash
   claude-memory session get-active --session-id "$CLAUDE_SESSION_ID"
   ```

2. **List Available Tasks:**
   Show what tasks are available:
   ```bash
   claude-memory tasks list --session-id "$CLAUDE_SESSION_ID"
   ```

3. **Handle User Request:**
   Based on the arguments provided:

   **If no arguments (general help):**
   - Show available tasks
   - Explain the execution workflow
   - Provide next steps

   **If task ID provided:**
   - Execute the specific task
   - Show the implementation
   - Guide through verification process

   **If "next" argument:**
   - Find the next pending task
   - Execute it automatically
   - Show results for review

4. **Task Execution Process:**

   **Execute Task:**
   ```bash
   claude-memory tasks execute --session-id "$CLAUDE_SESSION_ID" --task-id "[task-id]"
   ```

   **Verify Implementation:**
   ```bash
   claude-memory tasks verify --session-id "$CLAUDE_SESSION_ID" --task-id "[task-id]"
   ```

   **If implementation looks good:**
   ```bash
   claude-memory tasks verify --session-id "$CLAUDE_SESSION_ID" --task-id "[task-id]" --approve
   ```

5. **Provide Diff Application Guide:**

   For each executed task, provide specific instructions on how to apply the diff:

   **For New Files:**
   - Show how to create directory structure
   - Provide the exact file content to create
   - Give command-line examples

   **For Existing Files:**
   - Show which lines to remove (marked with -)
   - Show which lines to add (marked with +)
   - Provide git patch application method if applicable

6. **Error Handling:**

   If task execution fails:
   - Show the error message
   - Suggest refinement with specific feedback
   - Provide troubleshooting steps

   If no tasks exist:
   - Suggest using `/create-tasks` to generate tasks from plan
   - Explain the task generation process

7. **Response Format:**

   **When showing execution results:**
   ```
   => Executing Task: [Task Name]

   File: [target-file-path]
   Status: [execution-result]

   => Implementation Preview:
   [key changes summary]

   =› Next Steps:
   1. Review the implementation with: claude-memory tasks verify --task-id [id]
   2. If good, apply the diff manually (instructions below)
   3. Approve with: claude-memory tasks verify --task-id [id] --approve

   > How to Apply This Diff:
   [specific instructions for this file/change]
   ```

   **When providing diff application guide:**
   ```
   =¡ File: [file-path]

   [Action]: Create new file / Modify existing file

   Manual Steps:
   1. [step 1]
   2. [step 2]
   3. [step 3]

   Command Line:
   ```bash
   [exact commands to run]
   ```

   Verification:
   - Test the change works
   - Run linting if applicable
   - Commit the change
   ```

8. **Best Practices Guidance:**
   Always include advice on:
   - Reviewing implementations carefully
   - Testing changes before approving
   - Using version control
   - Understanding the impact of changes

## Usage Examples

**Execute next pending task:**
`/tasks-execute next`

**Execute specific task:**
`/tasks-execute [task-id]`

**Show execution help:**
`/tasks-execute`

**Get task execution status:**
`/tasks-execute status`

Remember: Always respond in English and provide clear, actionable instructions for applying diffs to the codebase.
