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

4. **Parse and Display Tasks:**
   If a plan exists, parse the XML Tasks section using the utility:

   ```bash
   # Get the plan content
   plan_content=$(cc-plan plan get --session-id "$CLAUDE_SESSION_ID")

   # Parse tasks using the XML parser utility
   tasks_json=$(echo "$plan_content" | utils/parse-tasks.sh)

   # Build dependency graph if needed
   dependency_graph=$(echo "$plan_content" | utils/parse-tasks.sh "" "graph")
   ```

   Display task summary:

   - Total number of tasks from parsed XML
   - Completed vs pending tasks by status attribute
   - Current or next task to work on based on dependencies
   - Task dependency relationships

5. **Handle User Questions:**
   If arguments are provided (user asked a specific question):

   - Analyze the question in context of the found plan and parsed XML tasks
   - Provide specific answers based on the plan content and parsed task data
   - Reference specific tasks from XML with IDs, titles, dependencies when relevant
   - Use parsed task data to answer questions about files, types, dependencies
   - If the question cannot be answered from the plan, say so clearly

6. **Response Format:**

   **When no arguments provided (general info):**

   ```
   📋 Current Session Plan: [Plan Title/ID]

   Overview: [Brief description of what the plan accomplishes]

   Status: [Active/Inactive] | Tasks: [X completed, Y pending, Z in-progress]

   Task Progress:
   ✅ [Task ID]: [Task Title] (completed)
   🔄 [Task ID]: [Task Title] (in-progress)
   ⏳ [Task ID]: [Task Title] (pending)

   Dependencies:
   - Task [ID] depends on: [dep1, dep2]
   - Task [ID] enables: [dependent1, dependent2]

   Key Areas:
   - [Component/file 1 from <File> elements]
   - [Component/file 2 from <File> elements]

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
