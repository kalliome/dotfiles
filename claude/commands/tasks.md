---
description: List tasks from the current session's plan with their statuses
allowed-tools: Bash(cc-plan:*)
model: claude-sonnet-4-5-20250929
---

# Tasks Command

List all tasks from the current session's active plan with their current statuses.

## User's Request
$ARGUMENTS

## Instructions

1. **Get Active Plan:**
   First, check if there's an active plan for this session:

   ```bash
   cc-plan session get-active --session-id "$CLAUDE_SESSION_ID"
   ```

   If successful, extract the plan ID from the response.

2. **Handle No Active Plan:**
   If no active plan is found:

   - Inform the user that no active plan is associated with this session
   - Suggest using `/plan` to create a new plan
   - Suggest using `/plan-attach` to attach to an existing plan
   - Exit gracefully

3. **List Tasks:**
   If an active plan exists, list all tasks:

   ```bash
   # Get the plan ID
   plan_id=$(cc-plan session get-active --session-id "$CLAUDE_SESSION_ID" | jq -r '.planId')

   # List all tasks in the plan
   cc-plan task list --plan-id "$plan_id"
   ```

4. **Display Task Information:**
   Parse the JSON response and display tasks in a clean format:

   **Basic Format:**
   ```
   📋 Tasks for Plan: [Plan ID]

   Status Summary:
   ✅ Completed: [X] tasks
   🔄 In Progress: [Y] tasks
   ⏳ Pending: [Z] tasks
   📊 Total: [N] tasks

   Task List:
   [Status Icon] [ID]: [Title] ([Status])
   [Status Icon] [ID]: [Title] ([Status])
   [Status Icon] [ID]: [Title] ([Status])
   ```

   **Status Icons:**
   - ✅ for `completed`
   - 🔄 for `in-progress`
   - ⏳ for `pending`

5. **Handle Arguments (Optional Filtering):**
   If arguments are provided, filter or modify the display:

   - `completed` - Show only completed tasks
   - `pending` - Show only pending tasks
   - `in-progress` - Show only in-progress tasks
   - `summary` - Show only the status summary
   - `detailed` - Show additional task details if available

6. **Error Handling:**

   **No Session ID:**
   - Inform user that session information is not available
   - Suggest running the command within a Claude session

   **cc-plan Command Failures:**
   - Show the specific error from cc-plan
   - Suggest checking if cc-plan is properly installed
   - Provide guidance on potential solutions

   **Invalid JSON Response:**
   - Inform user of parsing issues
   - Show raw response for debugging
   - Suggest checking plan integrity

7. **Usage Examples:**

   **List all tasks:**
   `/tasks`

   **Filter by status:**
   `/tasks pending`
   `/tasks completed`
   `/tasks in-progress`

   **Show summary only:**
   `/tasks summary`

   **Detailed view:**
   `/tasks detailed`

## Response Format

**Success Response:**
```
📋 Tasks for Plan: authentication-system

Status Summary:
✅ Completed: 2 tasks
🔄 In Progress: 1 task
⏳ Pending: 3 tasks
📊 Total: 6 tasks

Task List:
✅ 1: Add authentication middleware (completed)
✅ 2: Create user model (completed)
🔄 3: Implement login endpoint (in-progress)
⏳ 4: Add password validation (pending)
⏳ 5: Create user registration (pending)
⏳ 6: Add session management (pending)
```

**No Plan Response:**
```
❌ No active plan found for this session

To get started:
• Use `/plan [description]` to create a new plan
• Use `/plan-attach [plan-id]` to attach to an existing plan
```

**Error Response:**
```
⚠️ Error retrieving tasks: [error message]

Troubleshooting:
• Ensure cc-plan is installed and accessible
• Check that you have an active plan session
• Try running `/plan-info` to verify plan status
```

Remember: Always respond in English and provide clear, actionable task status information.