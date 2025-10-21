---
description: Plan and analyze prompts by generating detailed implementation plans and saving them with cc-plan
allowed-tools: Read, Glob, Grep, Bash(pwd:*), Bash(ls:*), WebFetch, Bash(cc-plan:*), Task
model: claude-sonnet-4-5-20250929
---

# Planning Mode: Plan Command

You are in planning mode. Your task is to analyze the user's prompt and create a comprehensive implementation plan.

**Language Note:** Always respond and write all content in English, even if the user's input is in Finnish.

## User's Request

$ARGUMENTS

## Maturity Level Assessment

Before generating the plan, determine the appropriate maturity level for this implementation:

- **proof-of-concept**: Quick validation of core concept, minimal testing, focus on demonstrating feasibility
- **mvp**: Initial customer-facing version, basic testing, essential features for user validation
- **production**: Full production release, comprehensive testing, performance optimization, complete error handling
- **enterprise**: Maximum robustness, compliance requirements, extensive documentation, audit trails

If the maturity level is not clear from the user's request, ensure the plan-generator agent includes it as a Question in the plan's Questions XML section with `type="maturity"` attribute.

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

   **Special Case - No Arguments with Active Plan Questions/Notes:**
   If `/plan` is called without arguments AND an active plan exists with questions or notes, automatically process them:

   **Questions Processing:**
   - Questions are formatted in a `<Questions>` XML container with multiple `<Item>` tags containing `<Question>` and `<Answer>` pairs
   - If Questions section has filled Answer fields, process those answers to refine the plan
   - **Remove the entire `<Questions>` section after processing answers** - all answered questions are consumed during refinement
   - Questions with empty answers remain in the plan for user completion

   **Notes Processing:**
   - Notes are formatted in a single `<Notes>` XML container with multiple `<Note>` tags inside at the end of the plan file
   - Read the referenced files and line numbers mentioned in each note
   - Analyze what changes are needed based on all the notes
   - Make the necessary updates to the plan
   - **Remove the entire `<Notes>` section after processing** - all notes are consumed during refinement
   - If clarification is needed about any notes or changes, ask the user
   - This allows for iterative plan refinement based on feedback or discoveries

   **Standard Case - Plan Exists:**
   If a plan exists (and no automatic note processing occurred), display it to the user and ask if they want to:

   - Update/refine the existing plan
   - Create a completely new plan
   - Continue with the existing plan

2. **Plan Generation via Agent:**
   If no existing plan or after processing notes, use the plan-generator agent to create the implementation plan:

   ```
   => Launching Plan Generator Agent

   User Request: [User's requirements]
   Context: [Any existing plan context or clarifications]

   Generating comprehensive implementation plan...
   ```

   Use the Task tool to launch the plan-generator agent with the user's request:

   ```
   Create a comprehensive implementation plan for the following user request.

   ## User Requirements
   [Insert the user's request from $ARGUMENTS]

   ## Maturity Level
   [Insert the determined maturity level: proof-of-concept, mvp, production, or enterprise]

   ## Context
   [Include any context from existing plans, user clarifications, questions/notes processing]

   ## Planning Instructions

   Based on this context, create a comprehensive implementation plan that:

   1. **Analyzes Current Codebase:** Understand the existing structure, patterns, and conventions
   2. **Assesses Task Complexity:** Determine if this is a Small/Medium/Large task
   3. **Applies User Requirements:** Address all specified requirements and constraints
   4. **Follows Maturity Level:** Adjust task detail and requirements based on maturity level:
      - proof-of-concept: Core functionality only, minimal testing
      - mvp: Essential features with basic testing
      - production: Full testing and error handling
      - enterprise: Comprehensive testing, compliance, documentation
   5. **Considers Dependencies:** Account for prerequisites and what this enables
   6. **Addresses Integration:** Include integration points and impacts on existing systems
   7. **Adjusts for Maturity Level:** Scope tasks and testing appropriately for the specified maturity

   The plan should be implementation-ready with specific tasks, file modifications, and technical details that can be executed by the plan-execute command.

   CRITICAL: The implementation plan MUST include all tasks formatted using XML with proper structure. Each task should be enclosed in XML tags with all required attributes for execution.
   ```

   **Agent Response Handling:**
   - Monitor the plan-generator agent's progress
   - Ensure the generated plan is complete and actionable
   - Verify that all user requirements are addressed
   - Confirm that tasks are properly structured with dependencies

3. **Final Actions:**
   Save the plan to cc-plan with task size indication:

   For new plans:

   ```bash
   cc-plan plan create --project-path "$(pwd)" --session-id "$CLAUDE_SESSION_ID" --maturity "[maturity-level]" --content "[plan content]"
   ```

   For updating existing plans:

   ```bash
   cc-plan plan update --session-id "$CLAUDE_SESSION_ID" --maturity "[maturity-level]" --content "[updated plan content]"
   ```

   - Display the generated plan ID and task size assessment (e.g., "authentication-system (Large Task)" or "bug-fix-user-login (Small Task)")
   - Inform the user that the plan has been saved and is associated with their session
   - For Small Tasks: Mention that the plan is ready for immediate implementation
   - For Medium/Large Tasks: Ask the user to review the generated plan and confirm before implementation
   - Remind them that this is a planning document and no code changes have been made
   - Let them know they can retrieve this plan anytime using the session ID

Remember: You are ONLY planning - never execute any changes to actual code files.

## CRITICAL: Do NOT Start Implementation

After completing the planning phase:

- **DO NOT begin implementing any code changes**
- **DO NOT start executing the plan automatically**
- **DO NOT use tools like Edit, Write, or MultiEdit**
- The planning phase is complete once the plan is saved to cc-plan
- Implementation should only begin when the user explicitly requests it or uses plan execution commands
- Your role in planning mode is purely analytical and organizational
