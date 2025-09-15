---
description: Plan and analyze prompts by generating detailed implementation plans in POHDINTA.md
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(pwd:*), Bash(ls:*), WebFetch
model: claude-opus-4-1-20250805
---

# Planning Mode: Pohdi Command

You are in planning mode. Your task is to analyze the user's prompt and create a comprehensive implementation plan.

**Language Note:** Always respond and write all content in English, even if the user's input is in Finnish.

## User's Request
$ARGUMENTS

## Instructions

1. **Investigation Phase:**
   - Consider CLAUDE.md instructions from user's global configuration
   - Examine the current project structure and codebase
   - Analyze the user's request to identify:
     * Ambiguous requirements
     * Missing technical details
     * Potential architectural decisions needed
     * Unclear scope boundaries

2. **Clarification Phase:**
   Based on your investigation, ask 3-5 targeted clarifying questions such as:
   - What specific technologies/frameworks should be used?
   - Are there performance or scalability requirements?
   - Should this integrate with existing systems? If so, which ones?
   - What error handling approach is preferred?
   - Are there specific coding patterns or conventions to follow?
   - What is the expected timeline or priority level?
   - Are there any constraints or limitations to consider?

   Wait for user responses before proceeding to the planning phase.

3. **Planning Phase:**
   Once the user has responded to your questions, proceed with generating the plan using both the original request and their clarifications.

4. **Generate/Update Plan:**
   - If POHDINTA.md exists in project root, read it first and refine based on new input
   - If POHDINTA.md doesn't exist, create a new detailed plan
   - Never modify any actual code files - only create/update the planning document

5. **Plan Structure:**
   Create a comprehensive plan in POHDINTA.md with these sections:

   ```markdown
   # Implementation Plan: [Brief Description]

   ## Overview
   [High-level description of what needs to be accomplished]

   ## Context Analysis
   - Relevant CLAUDE.md instructions
   - Current codebase structure

   ## Detailed Implementation Plan

   ### Files to Modify/Create
   For each file that needs changes:
   #### `path/to/file.ext`
   - **What to change:** [Specific changes needed]
   - **Why:** [Reasoning for the change]
   - **Implementation details:** [Technical specifics]

   ### Step-by-Step Implementation
   1. [First step with specific actions]
   2. [Second step with specific actions]
   3. [Continue with all necessary steps...]

   ## Technical Considerations
   - [Architecture decisions]
   - [Potential challenges]
   - [Dependencies or prerequisites]
   - [Testing approach]

   ## Success Criteria
   - [How to verify the implementation works]
   - [Expected outcomes]
   ```

6. **Final Actions:**
   - Save the plan to POHDINTA.md in the project root
   - Ask the user to review the generated plan
   - Remind them that this is a planning document and no code changes have been made

Remember: You are ONLY planning - never execute any changes to actual code files.
