---
description: Create implementation plans from research milestones using specialized plan generation
allowed-tools: Read, Glob, Grep, Bash(pwd:*), Bash(ls:*), WebFetch, Bash(cc-plan:*), Task
model: claude-sonnet-4-5-20250929
---

# Research Implement Command

Creates detailed implementation plans for ALL milestones from a research plan using the specialized plan-generator agent. This command processes each milestone individually, creating separate implementation plans for each one.

**Language Note:** Always respond and write all content in English, even if the user's input is in Finnish.

## User's Request

$ARGUMENTS

## Instructions

### Phase 1: Research Context Loading

1. **Load Active Research Plan:**
   First, check if there's an active research plan for this session:

   ```bash
   cc-plan session get-active --session-id "$CLAUDE_SESSION_ID"
   ```

   If an active plan exists, load it:

   ```bash
   cc-plan plan get --session-id "$CLAUDE_SESSION_ID"
   ```

   **Validate Research Plan:**

   - Confirm the loaded plan is a research plan (should contain milestones)
   - Check that research has been completed (milestones should have been investigated)
   - Verify that the plan contains implementation-ready milestone breakdowns

2. **Parse Research Context:**
   Extract key information from the research plan:

   - **Overall Project Scope:** What the entire feature/system is about
   - **Selected Approach:** Which implementation approach was chosen during research
   - **Available Milestones:** List of research milestones that can be implemented
   - **Milestone Dependencies:** How milestones relate to each other
   - **User Requirements:** Original user requirements and constraints

3. **Extract Research Plan ID and Maturity:**
   Save the research plan ID and maturity level for linking milestone plans:

   ```bash
   RESEARCH_PLAN_ID=$(echo "$plan_response" | jq -r '.plan.id')
   RESEARCH_MATURITY=$(echo "$plan_response" | jq -r '.plan.maturity')
   echo "Source Research Plan ID: $RESEARCH_PLAN_ID"
   echo "Research Maturity Level: $RESEARCH_MATURITY"
   ```

4. **Process All Milestones:**
   Extract and process all available milestones from the research plan:

   ```
   => Research Implement: Processing All Milestones

   Research Plan: [Plan Title]
   Selected Approach: [Approach from research]
   Total Milestones: [Number of milestones]

   Milestones to Process:
   1. [Milestone 1 Name] - [Brief description]
   2. [Milestone 2 Name] - [Brief description]
   3. [Milestone 3 Name] - [Brief description]

   Beginning milestone-by-milestone plan generation...
   ```

   Process each milestone sequentially to create individual implementation plans.

### Phase 2: Multi-Milestone Processing Loop

For each milestone found in the research plan, execute the following process:

1. **Extract Milestone Details:**
   From the research plan, extract complete context for the current milestone:

   - **Milestone Description:** What this milestone accomplishes
   - **Research Findings:** Technical analysis and recommendations from research
   - **Implementation Method:** Recommended approach from research investigation
   - **Risk Assessment:** Identified challenges and mitigation strategies
   - **Dependencies:** Other milestones this depends on or enables
   - **Success Criteria:** How to measure completion

2. **Prepare Implementation Context:**
   Compile comprehensive context for the plan-generator agent:

   ```
   => Processing Milestone [N/Total]: [Milestone Name]

   Research Context Summary:
   - Overall Project: [Project description]
   - Selected Approach: [Implementation approach]
   - Milestone Focus: [This specific milestone]
   - Implementation Method: [Recommended method from research]
   - Key Dependencies: [Critical dependencies]

   Launching plan-generator agent...
   ```

### Phase 3: Plan Generation via Agent (Per Milestone)

1. **Launch Plan Generator Agent for Current Milestone:**
   Use the Task tool to launch the plan-generator agent with comprehensive context for the current milestone:

   ```
   Create a detailed implementation plan for a specific milestone from completed research.

   ## Research Context

   **Overall Project Scope:**
   [Full description of what the entire feature/system is about]

   **Selected Implementation Approach:**
   [The approach chosen during research phase - e.g., "Modern Greenfield Implementation", "Strategic Hybrid Solution", etc.]

   **User Requirements Summary:**
   [Key requirements and constraints from original user request]

   **Maturity Level:**
   [Maturity level from research plan: proof-of-concept, mvp, production, or enterprise]

   ## Target Milestone

   **Milestone Name:** [Specific milestone name]
   **Milestone Description:** [What this milestone accomplishes]

   **Research Findings for This Milestone:**
   [Technical analysis, current state assessment, and recommendations from research]

   **Recommended Implementation Method:**
   [Specific method recommended for this milestone from research investigation]

   **Research-Identified Risks:**
   [Challenges and mitigation strategies identified during research]

   **Dependencies and Integration:**
   [How this milestone relates to other milestones and existing systems]

   **Success Criteria from Research:**
   [How to measure successful completion of this milestone]

   ## Planning Instructions

   Based on this research context, create a comprehensive implementation plan that:

   1. **Analyzes Current Codebase:** Understand the existing structure, patterns, and conventions
   2. **Assesses Task Complexity:** Determine if this is a Small/Medium/Large task
   3. **Focuses on This Specific Milestone:** Don't plan the entire project, just this milestone
   4. **Applies Research Findings:** Use the technical analysis and recommendations from research
   5. **Follows Selected Approach:** Align with the overall implementation approach chosen
   6. **Considers Dependencies:** Account for prerequisites and what this enables
   7. **Implements Recommended Method:** Use the specific implementation method from research
   8. **Addresses Identified Risks:** Include mitigation strategies from research analysis
   9. **Addresses Integration:** Include integration points and impacts on existing systems
   10. **Adjusts for Maturity Level:** Scope tasks and testing appropriately for the specified maturity:
       - proof-of-concept: Core functionality only, minimal testing
       - mvp: Essential features with basic testing
       - production: Full testing and error handling
       - enterprise: Comprehensive testing, compliance, documentation

   The plan should be implementation-ready with specific tasks, file modifications, and technical details that can be executed by the plan-execute command.

   Please generate a complete implementation plan for this milestone that includes tasks in proper XML format.

   CRITICAL: The implementation plan MUST include all tasks formatted using XML with proper structure. Each task should be enclosed in XML tags with all required attributes for execution.
   ```

2. **Agent Coordination for Current Milestone:**
   Monitor the plan-generator agent's work and ensure it produces a complete plan for the current milestone:
   - Plan includes specific tasks with file paths formatted in XML
   - Dependencies are properly mapped
   - Implementation approach aligns with research
   - Tasks are actionable and executable
   - All tasks must be in XML format for proper execution by plan-execute

### Phase 4: Plan Storage and Progress Tracking (Per Milestone)

1. **Review Generated Plan for Current Milestone:**
   Analyze the plan generated by the agent and verify it meets quality standards:

   ```
   => Plan Generation Complete for Milestone [N/Total]: [Milestone Name]

   Generated Plan Summary:
   - Tasks Created: [Number of tasks]
   - Files to Modify: [Number of files]
   - Estimated Complexity: [Complexity assessment]
   - Dependencies: [Task dependencies]
   - XML Format: [Verification that all tasks are in XML format]

   Plan Details:
   [Brief summary of what the plan accomplishes]
   ```

   **Plan Quality Verification:**
   - Confirm all tasks are formatted in proper XML structure
   - Verify tasks include required attributes (id, description, dependencies, etc.)
   - Ensure implementation approach aligns with research findings
   - Check that file paths and technical details are specific and actionable

2. **Save Implementation Plan for Current Milestone:**
   Save the generated plan using cc-plan with milestone-specific naming:

   ```bash
   # Create milestone plan with parent linkage and maturity from research plan
   cc-plan plan create \
     --project-path "$(pwd)" \
     --session-id "${CLAUDE_SESSION_ID}_milestone_${milestone_number}" \
     --maturity "${RESEARCH_MATURITY}" \
     --content "[implementation plan content]" \
     --parent-plan-id "${RESEARCH_PLAN_ID}" \
   ```

   **Plan Naming Convention:**

   - Title: "Implementation: [Milestone Name] - [Project Name]"
   - Session ID: "${CLAUDE_SESSION_ID}_milestone_${milestone_number}"
   - Include reference to source research plan
   - Mark as implementation plan (not research plan)

3. **Track Progress and Continue:**

   ```
   ✅ Milestone [N/Total] Plan Created: [Milestone Name]

   Plan Details:
   - Plan ID: [Generated plan ID]
   - Tasks: [Number] implementation tasks
   - Complexity: [Assessment from agent]
   - Session ID: ${CLAUDE_SESSION_ID}_milestone_${milestone_number}

   [If more milestones remaining]
   Continuing with next milestone...

   [If this was the last milestone]
   All milestone plans generated successfully!
   ```

### Phase 5: Final Summary and Execution Guidance

After processing all milestones, provide comprehensive summary:

```
🎉 All Implementation Plans Created Successfully!

Source Research: [Research plan name]
Total Milestones Processed: [Number]
Total Implementation Plans Created: [Number]

Generated Plans:
1. Implementation: [Milestone 1 Name] - Session: ${CLAUDE_SESSION_ID}_milestone_1
2. Implementation: [Milestone 2 Name] - Session: ${CLAUDE_SESSION_ID}_milestone_2
3. Implementation: [Milestone 3 Name] - Session: ${CLAUDE_SESSION_ID}_milestone_3

Each implementation plan includes:
✅ Specific file modifications with clear requirements
✅ Task dependencies properly mapped
✅ Research-informed technical approach
✅ Risk mitigation strategies
✅ Success criteria and validation steps
✅ All tasks formatted in proper XML structure for execution

Next Steps:
1. Review individual plans: Use cc-plan commands with specific session IDs
2. Execute milestone by milestone: Use `/plan-execute` with specific session IDs
3. Execute in dependency order as identified in research
4. Each plan follows the [Selected Approach] approach as defined in research

All plans are saved and ready for execution.

Hierarchy Features:
✅ All milestone plans linked to source research plan
✅ Parent-child relationships maintained automatically
✅ Progress tracking available in web UI
✅ Navigation between related plans enabled

Hierarchy Commands:
- View complete structure: cc-plan research get --plan-id [research-id] --with-children
- List research plans: cc-plan research list --with-children
```

### Phase 6: Error Handling and Guidance

**Missing Research Plan:**

```
❌ No Active Research Plan Found

To use research-implement, you need an active research plan with completed milestones.

Suggested Steps:
1. Use `/research "[feature description]"` to create a research plan
2. Use `/deep-research` to investigate the research milestones
3. Once research is complete, use `/research-implement` to create implementation plans

Or load an existing research plan using cc-plan commands.
```

**Incomplete Research:**

```
⚠️  Research Plan Found but Incomplete

The active research plan exists but milestones haven't been fully investigated.

Current Status:
- Research Plan: [Plan name]
- Milestones: [Total count]
- Investigated: [Investigated count]
- Remaining: [Pending count]

Please complete the research using `/deep-research` before creating implementation plans.
```

**Milestone Processing Failures:**

```
⚠️  Milestone Processing Failed

Failed to process milestone "[milestone name]".

Error Details: [Specific error information]

Options:
1. Retry processing this milestone
2. Skip this milestone and continue with others
3. Manual plan creation for this milestone

Continuing with remaining milestones...
```

**Agent Failure:**

```
⚠️  Plan Generation Failed

The plan-generator agent encountered an issue for milestone "[milestone name]".

Attempting fallback approach...

[If fallback succeeds, continue with generated plan]
[If fallback fails, provide manual guidance for plan creation]
```

## Usage Examples

**Process all milestones from active research plan:**

```
/research-implement
[Automatically processes all milestones from the active research plan]
```

**Result:**

```
=> Research Implement: Processing All Milestones

Research Plan: User Authentication System Research
Selected Approach: Modern Greenfield Implementation
Total Milestones: 3

Milestones to Process:
1. Foundation Architecture Setup
2. Core Authentication Implementation
3. User Interface Components

=> Processing Milestone 1/3: Foundation Architecture Setup
[Generates implementation plan]
✅ Milestone 1/3 Plan Created: Foundation Architecture Setup

=> Processing Milestone 2/3: Core Authentication Implementation
[Generates implementation plan]
✅ Milestone 2/3 Plan Created: Core Authentication Implementation

=> Processing Milestone 3/3: User Interface Components
[Generates implementation plan]
✅ Milestone 3/3 Plan Created: User Interface Components

🎉 All Implementation Plans Created Successfully!
```

## Key Features

- **Multi-Milestone Processing:** Automatically processes ALL milestones from research plan
- **Individual Plan Generation:** Creates separate implementation plans for each milestone
- **Research-Driven Planning:** Creates plans based on completed research analysis
- **Context-Aware:** Considers overall project scope while planning each specific milestone
- **Agent-Powered:** Uses specialized plan-generator agent for comprehensive planning
- **Research Integration:** Applies research findings, risk assessments, and approach validation
- **Session Management:** Creates separate session IDs for each milestone plan
- **Execution-Ready:** Generates plans that can be immediately executed by plan-execute command

## Integration with Research Workflow

The research-implement command is designed to work seamlessly with the research workflow:

1. **Research Phase:** `/research` creates strategic research plan with high-level milestones
2. **Implementation Planning:** `/research-implement` creates executable plans for ALL milestones
3. **Execution Phase:** `/plan-execute` executes individual milestone implementation tasks

This creates a complete workflow from high-level research to detailed implementation:

```
/research → /research-implement → /plan-execute (per milestone)
```

## Quality Assurance

**Plan Quality Checks:**

- Implementation plan aligns with research findings
- Tasks are specific and actionable with proper XML formatting
- Dependencies are properly mapped
- Technical approach follows research recommendations
- Risk mitigation strategies are included
- All tasks include required XML attributes for execution

**Research Alignment:**

- Selected implementation approach is maintained
- Milestone scope matches research definition
- User requirements are preserved throughout
- Research-identified challenges are addressed

**Execution Readiness:**

- Plans can be executed by plan-execute command
- Tasks include specific file paths and requirements
- Validation criteria are clearly defined
- Success metrics align with research criteria

**Multi-Milestone Coordination:**

- All milestones processed from single research plan
- Individual plans maintain overall project coherence
- Session management allows independent execution
- Dependencies between milestones preserved

Remember: This command bridges research and implementation by creating detailed, executable plans for ALL milestones based on completed research analysis, with each milestone getting its own dedicated implementation plan.
