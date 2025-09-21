---
description: Plan and analyze prompts by generating detailed implementation plans and saving them with cc-plan
allowed-tools: Read, Glob, Grep, Bash(pwd:*), Bash(ls:*), WebFetch, Bash(cc-plan:*)
model: claude-opus-4-1-20250805
---

# Planning Mode: Plan Command

You are in planning mode. Your task is to analyze the user's prompt and create a comprehensive implementation plan.

**Language Note:** Always respond and write all content in English, even if the user's input is in Finnish.

## User's Request
$ARGUMENTS

## Instructions

1. **Check for Existing Plan:**
   First, check if there's an active plan for this session:
   ```bash
   cc-plan session get-active --session-id "$CLAUDE_SESSION_ID"
   ```

   If an active plan exists, load it:
   ```bash
   cc-plan plan get --session-id "$CLAUDE_SESSION_ID"
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
   - If updating an existing plan from cc-plan, incorporate the previous content
   - Generate an implementation plan with detail level appropriate to task size
   - **Focus on Task Relationships:** For each task identified, clearly define:
     * **What:** Exact changes needed (be specific about code, files, functions)
     * **Why:** Business/technical reasoning (not just "because it's needed")
     * **Dependencies:** What must be done first (files, setup, other tasks)
     * **Impacts:** What other parts of the system this affects
     * **Order:** Whether tasks can be parallel or must be sequential
   - **Map Dependencies:** Create a clear dependency graph showing task order
   - **Include Task Summary:** Always end your plan with a clean "Tasks" section using the standardized format
   - Never modify any actual code files - only create/update the planning document

7. **Plan Structure (scaled by task size):**

   **For Small Tasks:**
   ```markdown
   # Implementation Plan: [Brief Description]

   ## Overview
   [Concise description of the change needed]

   ## Implementation
   #### `path/to/file.ext`
   - **What:** [Specific changes needed - be explicit about what code/functionality changes]
   - **Why:** [Clear reasoning - business need, bug fix, performance improvement, etc.]
   - **Dependencies:** [Any prerequisites or files that must be modified first]
   - **Impacts:** [Other parts of code that may be affected by this change]

   ## Task Relationships
   - **Prerequisites:** [Tasks that must be completed before this one]
   - **Enables:** [Tasks that can be started after this is complete]
   - **Parallel with:** [Tasks that can be done simultaneously]

   ## Steps
   1. [Direct implementation steps with clear what/why for each]
   2. [Testing/verification - specify what to test and why]

   ## Tasks
   1. [Task Name]
      What: [Specific changes/implementation needed]
      Why: [Business/technical reasoning]
      File: [Target file path]
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
   - **What:** [Specific changes needed - detailed description of code modifications]
   - **Why:** [Reasoning for the change - technical and business justification]
   - **Dependencies:** [Files/components that must be modified first]
   - **Impacts:** [Other files/components affected by this change]
   - **Implementation details:** [Key technical specifics and approach]

   ## Task Dependencies & Order
   ### Task Groups
   1. **Foundation Tasks** (can be done in parallel):
      - Task A: [Brief description]
      - Task B: [Brief description]
   2. **Integration Tasks** (depend on foundation):
      - Task C: [Brief description] (requires A, B)
   3. **Finalization Tasks**:
      - Task D: [Brief description] (requires C)

   ### Steps
   1. [Implementation steps with moderate detail and clear dependencies]
   2. [Continue with necessary steps, noting which can be parallel]

   ## Success Criteria
   - [How to verify the implementation works]
   - [Integration testing approach]

   ## Tasks
   1. [Task Name]
      What: [Specific changes/implementation needed]
      Why: [Business/technical reasoning]
      File: [Target file path]
      Dependencies: [Task numbers this depends on, if any]

   2. [Next Task Name]
      What: [Specific changes/implementation needed]
      Why: [Business/technical reasoning]
      File: [Target file path]
      Dependencies: [Task numbers this depends on]
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
   - **What:** [Specific changes needed - exact code modifications, new functions, data structures]
   - **Why:** [Detailed reasoning - business requirement, architectural need, performance optimization]
   - **Dependencies:** [Prerequisites - other files, external libraries, database changes needed first]
   - **Impacts:** [Downstream effects - what other components will be affected]
   - **Implementation details:** [Comprehensive technical specifics and approach]
   - **Testing strategy:** [How to verify this specific change works]

   ## Task Dependency Map & Implementation Order

   ### Phase 1: Foundation (Parallel Tasks)
   - **Task 1A:** [Core infrastructure/models]
     - Enables: Tasks 2A, 2B
     - Parallel with: Task 1B, 1C
   - **Task 1B:** [Database/storage setup]
     - Enables: Tasks 2A, 2C
     - Parallel with: Task 1A, 1C
   - **Task 1C:** [External integrations/APIs]
     - Enables: Task 2C
     - Parallel with: Task 1A, 1B

   ### Phase 2: Integration (Some Parallel)
   - **Task 2A:** [Business logic implementation]
     - Depends on: Task 1A, 1B
     - Enables: Task 3A
     - Parallel with: Task 2B
   - **Task 2B:** [UI/Interface components]
     - Depends on: Task 1A
     - Enables: Task 3A
     - Parallel with: Task 2A
   - **Task 2C:** [Data processing/transformation]
     - Depends on: Task 1B, 1C
     - Enables: Task 3B

   ### Phase 3: Finalization (Sequential)
   - **Task 3A:** [Integration testing & validation]
     - Depends on: Task 2A, 2B
     - Enables: Task 3C
   - **Task 3B:** [Performance optimization]
     - Depends on: Task 2C
     - Parallel with: Task 3A
   - **Task 3C:** [Final integration & deployment prep]
     - Depends on: Task 3A, 3B

   ### Step-by-Step Implementation
   1. **Phase 1 Execution:** [Parallel foundation work with specific actions]
   2. **Phase 2 Execution:** [Integration work noting dependencies]
   3. **Phase 3 Execution:** [Final steps with validation]

   ## Technical Considerations
   - [Architecture decisions and their impact on task order]
   - [Potential challenges and blocking dependencies]
   - [Critical path analysis - which tasks cannot be delayed]
   - [Resource allocation - tasks requiring specialized knowledge]
   - [Testing approach and validation strategy]
   - [Performance implications and optimization opportunities]
   - [Security considerations throughout phases]

   ## Success Criteria
   - [How to verify the implementation works at each phase]
   - [Expected outcomes and measurable results]
   - [Acceptance criteria for each task group]
   - [Integration testing strategy]

   ## Tasks
   1. [Task Name]
      What: [Specific changes/implementation needed]
      Why: [Business/technical reasoning]
      File: [Target file path]
      Dependencies: [Task numbers this depends on, if any]

   2. [Next Task Name]
      What: [Specific changes/implementation needed]
      Why: [Business/technical reasoning]
      File: [Target file path]
      Dependencies: [Task numbers this depends on]

   3. [Additional tasks following the same pattern...]
   ```

   ## Tasks Output Format

   End your plan with a clean task summary using this format:

   ```
   Tasks:
      1. [Task Name]
         What: [Specific changes/implementation needed]
         Why: [Business/technical reasoning]
         File: [Target file path]
         Dependencies: [Task numbers this depends on, if any]

      2. [Next Task Name]
         What: [Specific changes/implementation needed]
         Why: [Business/technical reasoning]
         File: [Target file path]
         Dependencies: [Task numbers this depends on]
   ```
   ```

8. **Final Actions:**
   Save the plan to cc-plan with task size indication:

   For new plans:
   ```bash
   cc-plan plan create --project-path "$(pwd)" --session-id "$CLAUDE_SESSION_ID" --content "[plan content]"
   ```

   For updating existing plans:
   ```bash
   cc-plan plan update --session-id "$CLAUDE_SESSION_ID" --content "[updated plan content]"
   ```

   - Display the generated plan ID and task size assessment (e.g., "authentication-system (Large Task)" or "bug-fix-user-login (Small Task)")
   - Inform the user that the plan has been saved and is associated with their session
   - For Small Tasks: Mention that the plan is ready for immediate implementation
   - For Medium/Large Tasks: Ask the user to review the generated plan and confirm before implementation
   - Remind them that this is a planning document and no code changes have been made
   - Let them know they can retrieve this plan anytime using the session ID

Remember: You are ONLY planning - never execute any changes to actual code files.
