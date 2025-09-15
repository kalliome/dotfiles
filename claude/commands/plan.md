---
description: Plan and analyze prompts by generating detailed implementation plans and saving them with claude-memory
allowed-tools: Read, Glob, Grep, Bash(pwd:*), Bash(ls:*), WebFetch, Bash(claude-memory:*)
model: claude-opus-4-1-20250805
---

# Planning Mode: Pohdi Command

You are in planning mode. Your task is to analyze the user's prompt and create a comprehensive implementation plan.

**Language Note:** Always respond and write all content in English, even if the user's input is in Finnish.

## User's Request
$ARGUMENTS

## Instructions

1. **Check for Existing Plan:**
   First, check if there's an active plan for this session:
   ```bash
   claude-memory session get-active --session-id "${CLAUDE_SESSION_ID}"
   ```

   If an active plan exists, load it:
   ```bash
   claude-memory plan get --project-path "$(pwd)" --session-id "${CLAUDE_SESSION_ID}"
   ```

   If a plan exists, display it to the user and ask if they want to:
   - Update/refine the existing plan
   - Create a completely new plan
   - Continue with the existing plan

2. **Investigation Phase:**
   - Consider CLAUDE.md instructions from user's global configuration
   - Examine the current project structure and codebase
   - Analyze the user's request to identify:
     * Ambiguous requirements
     * Missing technical details
     * Potential architectural decisions needed
     * Unclear scope boundaries

3. **Task Size Assessment:**
   Evaluate the complexity and scope of the requested task:

   **Small Task** (1-2 files, clear requirements):
   - Simple bug fixes
   - Adding a single function or component
   - Minor configuration changes
   - Clear, well-defined single-purpose changes
   → Skip clarification questions, proceed directly to planning

   **Medium Task** (3-5 files, some complexity):
   - Feature additions with moderate scope
   - Refactoring existing functionality
   - Integration with existing systems
   - Changes requiring some architectural decisions
   → Ask 1-3 targeted clarifying questions if needed

   **Large Task** (5+ files, significant complexity):
   - Major feature implementations
   - System-wide changes
   - New architectural components
   - Complex integrations or migrations
   → Always ask 3-5 detailed clarifying questions

4. **Clarification Phase (based on task size):**

   **For Medium Tasks (ask 1-3 questions if unclear):**
   - What specific integration points are needed?
   - Are there preferred implementation approaches?
   - What testing approach should be used?

   **For Large Tasks (always ask 3-5 questions):**
   - What specific technologies/frameworks should be used?
   - Are there performance or scalability requirements?
   - Should this integrate with existing systems? If so, which ones?
   - What error handling approach is preferred?
   - Are there specific coding patterns or conventions to follow?
   - What is the expected timeline or priority level?
   - Are there any constraints or limitations to consider?

   Wait for user responses before proceeding to the planning phase (for Medium/Large tasks only).

5. **Planning Phase (adjusted for task size):**

   **For Small Tasks:**
   - Proceed directly to plan generation
   - Create a concise, focused plan
   - Minimal investigation required

   **For Medium Tasks:**
   - Use clarification responses if questions were asked
   - Create a moderately detailed plan
   - Include key implementation steps

   **For Large Tasks:**
   - Always incorporate user responses to clarification questions
   - Generate comprehensive, detailed plan
   - Include extensive technical considerations

6. **Generate/Update Plan:**
   - If updating an existing plan from claude-memory, incorporate the previous content
   - Generate an implementation plan with detail level appropriate to task size
   - Never modify any actual code files - only create/update the planning document

7. **Plan Structure (scaled by task size):**

   **For Small Tasks:**
   ```markdown
   # Implementation Plan: [Brief Description]

   ## Overview
   [Concise description of the change needed]

   ## Implementation
   #### `path/to/file.ext`
   - **What to change:** [Specific changes needed]
   - **Why:** [Brief reasoning]

   ## Steps
   1. [Direct implementation steps]
   2. [Testing/verification]
   ```

   **For Medium Tasks:**
   ```markdown
   # Implementation Plan: [Brief Description]

   ## Overview
   [Moderate description of what needs to be accomplished]

   ## Context Analysis
   - Relevant considerations from investigation

   ## Implementation Plan
   ### Files to Modify/Create
   #### `path/to/file.ext`
   - **What to change:** [Specific changes needed]
   - **Why:** [Reasoning for the change]
   - **Implementation details:** [Key technical specifics]

   ### Steps
   1. [Implementation steps with moderate detail]
   2. [Continue with necessary steps...]

   ## Success Criteria
   - [How to verify the implementation works]
   ```

   **For Large Tasks:**
   ```markdown
   # Implementation Plan: [Brief Description]

   ## Overview
   [Comprehensive description of what needs to be accomplished]

   ## Context Analysis
   - Relevant CLAUDE.md instructions
   - Current codebase structure
   - User clarifications and requirements

   ## Detailed Implementation Plan

   ### Files to Modify/Create
   For each file that needs changes:
   #### `path/to/file.ext`
   - **What to change:** [Specific changes needed]
   - **Why:** [Detailed reasoning for the change]
   - **Implementation details:** [Comprehensive technical specifics]

   ### Step-by-Step Implementation
   1. [First step with specific actions]
   2. [Second step with specific actions]
   3. [Continue with all necessary steps...]

   ## Technical Considerations
   - [Architecture decisions]
   - [Potential challenges]
   - [Dependencies or prerequisites]
   - [Testing approach]
   - [Performance implications]
   - [Security considerations]

   ## Success Criteria
   - [How to verify the implementation works]
   - [Expected outcomes]
   - [Acceptance criteria]
   ```

8. **Final Actions:**
   Save the plan to claude-memory with task size indication:

   For new plans:
   ```bash
   claude-memory plan create --project-path "$(pwd)" --session-id "${CLAUDE_SESSION_ID}" --content "[plan content]"
   ```

   For updating existing plans:
   ```bash
   claude-memory plan update --project-path "$(pwd)" --session-id "${CLAUDE_SESSION_ID}" --content "[updated plan content]"
   ```

   - Display the generated plan ID and task size assessment (e.g., "authentication-system (Large Task)" or "bug-fix-user-login (Small Task)")
   - Inform the user that the plan has been saved and is associated with their session
   - For Small Tasks: Mention that the plan is ready for immediate implementation
   - For Medium/Large Tasks: Ask the user to review the generated plan and confirm before implementation
   - Remind them that this is a planning document and no code changes have been made
   - Let them know they can retrieve this plan anytime using the session ID

Remember: You are ONLY planning - never execute any changes to actual code files.
