---
description: Display current session plan information and answer questions about the plan and tasks
allowed-tools: Bash(cc-plan:*), Read
model: claude-opus-4-1-20250805
---

# Plan Information Command

Display information about the current session's plan and tasks, or answer specific questions about them.

## User's Request

$ARGUMENTS

## Instructions

1. **Check for Active Session Plan:**
   First, check if there's an active plan for this session:

   ```bash
   cc-plan session get-active --session-id "$CLAUDE_SESSION_ID" --test "$CLAUDE_SESSION_ID"
   ```

   If no active session is found, try to get any plan for this session:

   ```bash
   cc-plan plan get --session-id "$CLAUDE_SESSION_ID" --test "$CLAUDE_SESSION_ID"
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

4. **Check for Tasks:**
   If a plan exists, also check for associated tasks:

   ```bash
   cc-plan tasks list --session-id "$CLAUDE_SESSION_ID"
   ```

   Display task summary:

   - Total number of tasks
   - Completed vs pending tasks
   - Current or next task to work on

5. **Handle User Questions:**
   If arguments are provided (user asked a specific question):

   - Analyze the question in context of the found plan and tasks
   - Provide specific answers based on the plan content
   - Reference specific tasks or plan sections when relevant
   - If the question cannot be answered from the plan, say so clearly

6. **Response Format:**

   **When no arguments provided (general info):**

   ```
   📋 Current Session Plan: [Plan Title/ID]

   Overview: [Brief description of what the plan accomplishes]

   Status: [Active/Inactive] | Tasks: [X completed, Y pending]

   Key Areas:
   - [Component/file 1]
   - [Component/file 2]

   Next Action: [What should be done next]
   ```

   **When specific question asked:**

   ```
   Question: [User's question]

   Answer: [Specific answer based on plan and tasks]

   Related Tasks:
   - [Relevant task 1]
   - [Relevant task 2]

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
