---
description: Create tasks from a session plan stored in claude-memory, breaking down the plan into actionable task groups and individual tasks
allowed-tools: Bash(claude-memory:*), Read
model: claude-opus-4-1-20250805
---

# Create Tasks from Session Plan

You are a task planning assistant that helps break down session plans into actionable tasks.

## User's Request
$ARGUMENTS

## Instructions

1. **Find Session Plan:**
   First, search for the session plan in claude-memory. If no session ID is provided in arguments, use the current session:
   ```bash
   claude-memory plan get --project-path "$(pwd)" --session-id "${CLAUDE_SESSION_ID}"
   ```

   If a specific session ID is provided in arguments, use that:
   ```bash
   claude-memory plan get --project-path "$(pwd)" --session-id "[session-id-from-arguments]"
   ```

2. **Check for Existing Tasks:**
   Check if tasks already exist for this session:
   ```bash
   claude-memory tasks list --project-path "$(pwd)" --session-id "${CLAUDE_SESSION_ID}"
   ```

   If tasks exist, ask the user:
   - Do you want to overwrite existing tasks?
   - Do you want to modify/add to existing tasks?
   - Do you want to keep existing tasks and create additional ones?

3. **Plan Breakdown Process:**
   Based on the session plan found, break it down systematically:

   **Phase 1: Task Groups**
   - Identify logical groupings of related work
   - Group by functional areas, components, or implementation phases
   - Each group should represent a cohesive unit of work

   **Phase 2: Individual Tasks**
   - Break each task group into specific, actionable tasks
   - Each task must follow these requirements:

4. **Task Requirements:**
   Every task must have:
   - **Clear objective:** What specific outcome this task achieves
   - **Single file focus:** Target only one file or component per task
   - **What and Why:** Clear explanation of what changes are needed and the reasoning
   - **Actionable scope:** Task can be completed in a reasonable timeframe
   - **Measurable completion:** Clear criteria for when the task is done

5. **Save Tasks to Memory:**
   Create tasks in claude-memory using:
   ```bash
   claude-memory tasks create --project-path "$(pwd)" --session-id "${CLAUDE_SESSION_ID}" --title "[task-title]" --description "[detailed-description]" --file-target "[target-file-path]"
   ```

   For each task created, include:
   - Descriptive title
   - Detailed description with objective, changes needed, and reasoning
   - Target file path (if applicable)
   - Task group/category

## Task Creation Guidelines

**Good Task Example:**
- Title: "Add user authentication middleware to Express router"
- Description: "Implement JWT verification middleware in src/middleware/auth.js to protect authenticated routes. This ensures only logged-in users can access protected endpoints and provides consistent authentication across the application."
- File Target: "src/middleware/auth.js"

**Poor Task Example:**
- Title: "Fix authentication"
- Description: "Make authentication work better"
- File Target: "Multiple files"

Remember: Focus on creating specific, actionable tasks that can be completed one at a time with clear success criteria.
