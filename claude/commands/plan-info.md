---
description: Display current session plan information and answer questions about the plan and tasks
allowed-tools: Bash(cc-plan:*), Read
model: claude-sonnet-4-5-20250929
---

# Plan Information Command

Display information about the current session's plan and tasks, or answer specific questions about them.

## User's Request

$ARGUMENTS

## Instructions

1. **Check for Active Session Plan:**
   First, check if there's an active plan for this session:

   ```bash
   cc-plan session get-active --session-id "$CLAUDE_SESSION_ID"
   ```

   If no active session is found, try to get any plan for this session:

   ```bash
   cc-plan plan get --session-id "$CLAUDE_SESSION_ID"
   ```

2. **Handle No Plan Found:**
   If no plan exists for this session:

   - Inform the user that no plan is currently associated with this session
   - Suggest using `/plan` to create a new plan
   - Suggest using `/plan-attach` to attach to an existing plan
   - Exit gracefully

3. **Display Plan Information:**
   If a plan is found, provide:

   - **Plan Overview:** Brief summary of what the plan aims to accomplish
   - **Current Status:** Whether it's active, how many tasks exist
   - **Key Components:** Main areas or files that will be modified
   - **Progress:** If tasks exist, show completion status

4. **List and Display Tasks:**
   If a plan exists, get task information using cc-plan commands:

   ```bash
   # Get active plan ID
   plan_id=$(cc-plan session get-active --session-id "$CLAUDE_SESSION_ID" | jq -r '.planId')

   # List all tasks in the plan
   tasks_json=$(cc-plan task list --plan-id "$plan_id")

   # Alternative: List tasks by session ID
   # tasks_json=$(cc-plan task list --session-id "$CLAUDE_SESSION_ID")
   ```

   Display task summary:

   - Total number of tasks from JSON response
   - Completed vs pending tasks by status field
   - Current or next task to work on based on dependencies
   - Task dependency relationships

5. **Handle User Questions:**
   If arguments are provided (user asked a specific question):

   - Analyze the question in context of the found plan and task list
   - Provide specific answers based on the plan content and task data from cc-plan
   - Reference specific tasks with IDs, titles, dependencies when relevant
   - Use task data from cc-plan to answer questions about files, types, dependencies
   - If the question cannot be answered from the plan, say so clearly

6. **Response Format:**

   **When no arguments provided (general info):**

   ```
   📋 Current Session Plan: [Plan Title/ID]

   Overview: [Brief description of what the plan accomplishes]

   Status: [Active/Inactive] | Tasks: [X completed, Y pending, Z in-progress]

   Task Summary: (from cc-plan task list)
   Total: [N] tasks

   Task Progress:
   ✅ [Task ID]: [Task Title] (completed)
   🔄 [Task ID]: [Task Title] (in-progress)
   ⏳ [Task ID]: [Task Title] (pending)

   Dependencies:
   - Task [ID] depends on: [dep1, dep2]
   - Task [ID] enables: [dependent1, dependent2]

   Key Areas:
   - [Component/file 1 from task data]
   - [Component/file 2 from task data]

   Next Action: [What should be done next based on dependency graph]
   ```

   **When specific question asked:**

   ```
   Question: [User's question]

   Answer: [Specific answer based on plan and parsed XML tasks]

   Related Tasks:
   - [Task ID]: [Task Title] - [What] ([File] - [Type])
   - [Task ID]: [Task Title] - [What] ([File] - [Type])

   Dependencies: [Show dependency chain if relevant]
   Plan Reference: [Relevant section of plan if applicable]
   ```

7. **Error Handling:**
   - If cc-plan commands fail, inform user of the issue
   - If plan data is corrupted or unreadable, suggest creating a new plan
   - If session ID is not available, inform user of the limitation

## Usage Examples

**Basic info:**
`/plan-info`

**Specific questions:**
`/plan-info What files need to be modified?`
`/plan-info What's the next step?`
`/plan-info How many tasks are left?`
`/plan-info What does this plan accomplish?`

Remember: Always respond in English and provide concise, actionable information.
