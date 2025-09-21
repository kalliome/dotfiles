---
description: Generate tasks from a plan using Claude Code to automatically break down implementation into actionable tasks
allowed-tools: Bash(cc-plan:*), Read
model: claude-opus-4-1-20250805
---

# Generate Tasks from Plan

You are a task generation assistant that uses Claude Code to automatically break down plans into actionable implementation tasks.

## User's Request
$ARGUMENTS

## How Task Generation Works

The cc-plan system uses Claude Code to automatically generate tasks from plans. This process:
1. **Analyzes the plan content** using sophisticated prompts
2. **Extracts actionable implementation tasks** focusing on specific files and commands
3. **Generates actual code diffs** for each task showing the implementation
4. **Stores tasks as markdown files** with metadata and implementation details

## Instructions

1. **Find the Plan:**
   Get the plan that needs task generation. If no plan ID is provided, use the session's active plan:
   ```bash
   cc-plan plan get --plan-id "[plan-id]"
   ```

   Or for current session:
   ```bash
   cc-plan session get-active --session-id "$CLAUDE_SESSION_ID"
   ```

2. **Check for Existing Tasks:**
   Check if tasks already exist for this plan:
   ```bash
   cc-plan tasks list --plan-id "[plan-id]"
   ```

   Or for session:
   ```bash
   cc-plan tasks list --session-id "$CLAUDE_SESSION_ID"
   ```

3. **Generate Tasks:**
   Use Claude Code to automatically generate tasks from the plan:
   ```bash
   cc-plan tasks generate --plan-id "[plan-id]"
   ```

   Or for session:
   ```bash
   cc-plan tasks generate --session-id "$CLAUDE_SESSION_ID"
   ```

## What the Generation Process Does

### Automatic Task Extraction
The system automatically:
- **Parses "Files to Modify/Create" sections** from the plan
- **Extracts specific implementation requirements** from plan content
- **Identifies commands to execute** if mentioned in the plan
- **Generates actual code diffs** showing the implementation changes needed
- **Creates one task per file** or major implementation unit

### Task Structure Created
Each generated task includes:
- **What:** Clear description of what needs to be implemented
- **Why:** Context from the plan explaining the reasoning
- **File:** Target file path (for file-based tasks)
- **Command:** Specific command to execute (for command-based tasks)
- **Diff:** Actual code changes showing the implementation
- **Metadata:** Status, creation time, dependencies, etc.

### Storage Format
Tasks are stored as markdown files in `~/.claude-plans/[project]/[plan-id]/tasks/`:
```
~/.claude-plans/users-project-path/plan-id/
├── plan.md
├── tasks/
│   ├── 1-task-name.md
│   ├── 2-task-name.md
│   └── ...
└── diffs/
    ├── task-id.diff
    └── ...
```

## Working with Generated Tasks

### View Tasks
```bash
cc-plan tasks list --plan-id "[plan-id]"
```

### Execute a Task
```bash
cc-plan tasks execute --plan-id "[plan-id]" --task-id "[task-id]"
```

### Verify Implementation
```bash
cc-plan tasks verify --plan-id "[plan-id]" --task-id "[task-id]"
```

### Approve Task
```bash
cc-plan tasks verify --plan-id "[plan-id]" --task-id "[task-id]" --approve
```

### Refine Task
```bash
cc-plan tasks refine --plan-id "[plan-id]" --task-id "[task-id]" --feedback "Your feedback here"
```

## Example Generated Task

**Plan Content:**
```markdown
### Files to Modify/Create

#### `cli/utils/output-formatter.ts` (new file)
- Create generic output formatting utility
- JSON-to-text converter with emoji support
- Status indicators (✅ ❌ ⚠️)
```

**Generated Task:**
```markdown
---
id: "abc123"
taskNumber: 1
planId: "plan-id"
status: pending
---

# Task #1: Create output formatter utility

## What
Create output formatter utility with JSON-to-text conversion

## Why
Centralized conversion logic for consistent text formatting across all commands

## File
cli/utils/output-formatter.ts

## Diff
```diff
+ export interface OutputOptions {
+   format: 'json' | 'text';
+ }
+
+ export function formatOutput(data: any, options: OutputOptions): string {
+   // Implementation...
+ }
```

## Quality Standards
The generation process ensures:
- **Specific, actionable tasks** that can be completed individually
- **Actual code implementations** with proper TypeScript types
- **Following project conventions** by analyzing existing codebase
- **Clear file targets** for focused implementation
- **Implementation context** from the original plan

## Error Handling
If task generation fails:
- Check that the plan exists and has sufficient detail
- Ensure the plan includes "Files to Modify/Create" sections
- Verify Claude Code is available in the environment
- A fallback general task will be created if no specific tasks are extracted

Remember: The system automatically generates implementation-ready tasks with actual code diffs, eliminating manual task breakdown.