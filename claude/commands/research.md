---
description: Research and investigate potential implementation plans by exploring high-level milestones and detailed investigation
allowed-tools: Read, Glob, Grep, Bash(pwd:*), Bash(ls:*), WebFetch, Bash(cc-plan:*)
model: claude-opus-4-1-20250805
---

# Research Mode: UltraThink Research Command

You are in **UltraThink research mode** - leveraging maximum cognitive capabilities to investigate and explore potential implementation approaches for significant features or systems. Your task is to create high-level milestones and conduct extraordinarily detailed, multi-dimensional research on each milestone using advanced analytical frameworks.

## UltraThink Research Methodology

**UltraThink Research** represents the application of maximum analytical depth, systematic reasoning, and comprehensive investigation techniques to research planning. In this mode, you:

- **Think Multi-Dimensionally:** Consider technical, architectural, business, user experience, operational, and strategic implications simultaneously
- **Apply Systems Thinking:** View each feature as part of interconnected systems with ripple effects and emergent behaviors
- **Use Evidence-Based Analysis:** Ground all recommendations in systematic investigation and validate through multiple perspectives
- **Consider Multiple Stakeholder Perspectives:** Analyze from developer, user, operator, business, and security viewpoints
- **Plan for Future Evolution:** Design approaches that anticipate technology changes and evolving requirements
- **Apply Risk-Informed Decision Making:** Identify risks early with comprehensive mitigation strategies

**Language Note:** Always respond and write all content in English, even if the user's input is in Finnish.

## User's Request

$ARGUMENTS

## Maturity Level Assessment

Before beginning research, determine the appropriate maturity level for this implementation:

- **proof-of-concept**: Quick validation research, focus on feasibility analysis, minimal architecture planning
- **mvp**: Customer-focused research, essential feature analysis, basic integration planning
- **production**: Comprehensive research, full architecture analysis, performance and security considerations
- **enterprise**: Extensive research, compliance analysis, complete risk assessment, strategic alignment

If the maturity level is not clear from the user's request, ensure the research plan includes it as a Question in the Questions XML section with `type="maturity"` attribute.

## Instructions

### Phase 1: Initial Research Setup

1. **Check for Existing Research Plan:**
   First, check if there's an active plan for this session:

   ```bash
   cc-plan session get-active --session-id "$CLAUDE_SESSION_ID"
   ```

   If an active plan exists, load it:

   ```bash
   cc-plan plan get --session-id "$CLAUDE_SESSION_ID"
   ```

   **Special Case - No Arguments with Active Research Plan Questions/Notes:**
   If `/research` is called without arguments AND an active research plan exists with questions or notes, automatically process them:

   **Questions Processing:**
   - Questions are formatted in a `<Questions>` XML container with multiple `<Item>` tags containing `<Question>` and `<Answer>` pairs
   - If Questions section has filled Answer fields, process those answers to refine the research plan
   - **Remove the entire `<Questions>` section after processing answers** - all answered questions are consumed during refinement
   - Questions with empty answers remain in the research plan for user completion

   **Notes Processing:**
   - Notes are formatted in a single `<Notes>` XML container with multiple `<Note>` tags inside at the end of the research plan file
   - Read the referenced files and line numbers mentioned in each note
   - Analyze what changes are needed to the research plan based on all the notes
   - Make the necessary updates to the research plan (approach changes, milestone modifications, etc.)
   - **Remove the entire `<Notes>` section after processing** - all notes are consumed during refinement
   - If clarification is needed about any notes or changes, ask the user
   - This allows for iterative research plan refinement based on feedback or discoveries

   **Standard Case - Research Plan Exists:**
   If a research plan exists (and no automatic note processing occurred), check the plan status:

   **If Research Plan Exists - Ready for Implementation:**
   If a research plan exists and is complete, display the research summary and ask if they want to:
   - Review and modify the research findings
   - Add additional milestones for research
   - Transition to implementation planning using `/research-implement`
   - Create new research for a different feature


   **If No Research Plan Exists:**
   Proceed with creating a new research plan (continue with steps 2-4).

2. **UltraThink Initial Investigation Phase:**

   Apply maximum cognitive capabilities to systematically understand the current state and requirements:

   **Multi-Dimensional Context Analysis:**
   - Consider CLAUDE.md instructions from user's global configuration through multiple analytical lenses
   - Examine project structure and codebase using systems thinking and architectural pattern recognition
   - Apply deep analysis to understand not just what exists, but why it exists and how it evolved

   **Comprehensive Impact Assessment:**
   - High-level architectural areas that would be impacted (direct and indirect effects)
   - Major system components requiring changes (functional, structural, and behavioral modifications)
   - Integration points with existing systems (data flow, control flow, and dependency analysis)
   - Cross-cutting concerns (security, performance, scalability, maintainability implications)
   - Business capability impacts and stakeholder effect analysis
   - Technology stack implications and vendor relationship considerations

   **Advanced Challenge Identification:**
   - Technical challenges and unknowns (categorized by risk level and mitigation complexity)
   - Organizational and process challenges (team capabilities, timeline constraints)
   - Architectural debt and technical constraints that may limit implementation options
   - Compliance, security, and regulatory considerations
   - Performance and scalability bottlenecks that could emerge
   - Integration complexity with external systems and third-party dependencies

3. **Deliverable-Focused Milestone Identification:**

   Create 3-6 major milestones that represent concrete deliverables with clear scope based on initial understanding.

4. **UltraThink Research Plan Generation:**

   Generate a comprehensive research plan using UltraThink methodology with mandatory clarification questions:

   ```markdown
   # UltraThink Research Plan: [Feature Name]

   **Status: UltraThink Research Phase**
   **Maturity Level:** [Insert determined maturity level]
   **Research Depth:** [Adjusted based on maturity - Maximum for enterprise/production, Focused for mvp, Essential for proof-of-concept]
   **Methodology:** Multi-Dimensional Systems Thinking

   ## Strategic Overview

   [Comprehensive description of what needs to be researched and implemented, including business value, technical scope, and strategic alignment]


   ## Comprehensive Requirements Analysis

   **Primary Use Cases & User Journeys:** [To be clarified through questions]
   **Performance & Scalability Profile:** [To be clarified through questions]
   **Integration Architecture:** [To be clarified through questions]
   **Technical Constraints & Opportunities:** [To be clarified through questions]
   **Timeline & Resource Framework:** [To be clarified through questions]
   **Compliance & Governance Requirements:** [To be clarified through questions]

   <Questions>
     <Item>
       <Question type="maturity">What maturity level should this implementation target? (proof-of-concept, mvp, production, enterprise)</Question>
       <Answer></Answer>
     </Item>
     <Item>
       <Question>What are the primary use cases, user workflows, and success metrics this feature should achieve?</Question>
       <Answer></Answer>
     </Item>
     <Item>
       <Question>What specific performance, scalability, availability, and security requirements must be satisfied?</Question>
       <Answer></Answer>
     </Item>
     <Item>
       <Question>How should this integrate with existing systems, and what are the data consistency and transaction requirements?</Question>
       <Answer></Answer>
     </Item>
     <Item>
       <Question>Are there preferred technologies, architectural patterns, or strategic technology directions to align with?</Question>
       <Answer></Answer>
     </Item>
     <Item>
       <Question>What are the timeline expectations, resource constraints, and acceptable risk levels?</Question>
       <Answer></Answer>
     </Item>
     <Item>
       <Question>Who are the primary users, stakeholders, and what are their technical capabilities and business requirements?</Question>
       <Answer></Answer>
     </Item>
   </Questions>

   ## UltraThink Research Objectives

   **Technical Architecture Research:**
   - Systematically map current system architecture and all integration touchpoints
   - Identify technical challenges using multiple risk assessment frameworks
   - Validate selected approach through comprehensive codebase analysis and pattern recognition
   - Model implementation complexity using quantitative and qualitative metrics

   **Strategic Analysis Research:**
   - Analyze alignment with business strategy and technology roadmap
   - Evaluate resource allocation and team capability requirements
   - Assess competitive landscape and technology evolution implications
   - Estimate total cost of ownership and return on investment

   **Risk & Mitigation Research:**
   - Identify risks across technical, operational, business, and organizational dimensions
   - Develop comprehensive mitigation strategies with fallback options
   - Plan validation checkpoints and course-correction mechanisms
   - Design monitoring and early warning systems

   ## Implementation-Focused Research Milestones

   ### Milestone 1: [Concrete Deliverable Name - What We Build]
   - **What We Build:** [Specific code artifacts, files, and deliverables to be created]
   - **Where We Build:** [Target directories, file paths, and codebase locations]
   - **Why We Build:** [Business objective and how this milestone enables subsequent work]
   - **Success Criteria:** [Measurable completion indicators - tests pass, features work, integration successful]
   - **Implementation Scope:** [Specific components, APIs, database changes, or UI elements to create]
   - **Dependencies:** [What must exist before this milestone can be started]

   ### Milestone 2: [Concrete Deliverable Name - What We Build]
   - **What We Build:** [Specific code artifacts, files, and deliverables to be created]
   - **Where We Build:** [Target directories, file paths, and codebase locations]
   - **Why We Build:** [Business objective and how this milestone enables subsequent work]
   - **Success Criteria:** [Measurable completion indicators - tests pass, features work, integration successful]
   - **Implementation Scope:** [Specific components, APIs, database changes, or UI elements to create]
   - **Dependencies:** [What must exist before this milestone can be started]

   [Continue with implementation-focused milestone structure for all remaining milestones...]

   ## Next Steps

   1. Answer the strategic questions above using cc-plan
   2. Research command will automatically process answers and refine the plan
   3. Transition to implementation planning using `/research-implement`

   ## Research Status

   ✅ Strategic milestone definition and architectural analysis complete
   ✅ High-level approach validation and risk assessment complete
   ✅ System integration points and technology alignment verified

   **Ready for Implementation Planning:** Use `/research-implement` to create detailed implementation plans for all milestones
   ```

   Save this research plan using cc-plan:

   ```bash
   cc-plan plan create --project-path "$(pwd)" --session-id "$CLAUDE_SESSION_ID" --maturity "[maturity-level]" --content "[research plan content]"
   ```

### Phase 2: UltraThink Investigation and Analysis

The research command performs comprehensive investigation of each milestone using UltraThink methodology. This is the complete investigation phase - no separate deep research is required.

**Research Command Investigation Scope:**
- High-level architectural analysis and milestone relationships
- Strategic approach validation and risk assessment
- System integration points and cross-cutting concerns
- Technology stack alignment and strategic considerations

**Plan Generator Agent Scope (handled later):**
- File-level implementation details and specific code changes
- Detailed task breakdown and technical specifications
- Individual component integration and testing strategies

### Phase 2: Research Plan Refinement

If a research plan already exists, focus on note processing and plan refinement:

1. **Load Existing Research Plan:**

   ```bash
   cc-plan plan get --session-id "$CLAUDE_SESSION_ID"
   ```

2. **Process Research Plan Questions/Notes (if present):**

   Check if the research plan contains questions or notes for iterative refinement:

   **Questions Detection:**
   - Look for `<Questions>` XML container in the research plan
   - If questions with answers are found, process them to refine the research plan

   **Questions Processing:**
   ```
   => Processing Research Plan Questions

   Found [N] answered questions in the research plan:

   Question 1: [Question summary]
   Answer: [User's answer]

   Question 2: [Question summary]
   Answer: [User's answer]

   Analyzing answers and updating research plan...
   ```

   **Notes Detection:**
   - Look for `<Notes>` XML container at the end of the research plan
   - If notes are found, process them to refine the research plan

   **Notes Processing:**
   ```
   => Processing Research Plan Notes

   Found [N] notes in the research plan:

   Note 1: [Note content summary]
   Referenced files: [files mentioned in note]

   Note 2: [Note content summary]
   Referenced files: [files mentioned in note]

   Analyzing notes and updating research plan...
   ```

   **Questions Analysis Steps:**
   - Parse all answered questions to extract user requirements and constraints
   - Analyze how answers impact milestone definition and research focus
   - Modify milestones based on clarifications from answers
   - Adjust user requirements summary based on answered questions
   - Update research objectives based on question responses
   - Update maturity level based on maturity question answer

   **Notes Analysis Steps:**
   - Read all referenced files and line numbers mentioned in notes
   - Analyze what changes are needed to the research plan based on notes
   - Modify milestones based on new insights from notes
   - Adjust user requirements summary if notes provide clarification
   - Update research objectives based on note feedback

   **Research Plan Updates:**
   Apply necessary changes to the research plan:
   - Milestone adjustments (scope changes, new milestones, removed milestones)
   - Requirement clarifications (updated based on question answers and note insights)
   - Investigation priority changes (based on question responses and note findings)
   - Maturity level updates (if maturity question provides new information)

   **Complete Questions/Notes Processing:**
   - Update the research plan with all question/note-based changes
   - **Remove the entire `<Questions>` section** after processing answers
   - **Remove the entire `<Notes>` section** after processing
   - Save the updated research plan using cc-plan

   ```bash
   cc-plan plan update --session-id "$CLAUDE_SESSION_ID" --maturity "[maturity-level]" --content "[updated research plan content]"
   ```

   **If No Questions or Notes Found:**
   Research plan is ready for detailed investigation.

3. **Research Plan Ready for Investigation:**

   After processing any questions/notes and refining the research plan, indicate readiness for detailed investigation:

   ```
   ✅ Research Plan Ready!

   Research Plan: [Plan Title]
   Status: Ready for Implementation Planning
   Approach: [Selected approach]
   Milestones: [N] milestones defined

   The research plan has been created/refined and is ready for implementation planning.

   Next Steps:
   1. Answer questions in the research plan using cc-plan
   2. Use `/research` again to process answers and refine the plan
   3. Use `/research-implement` to create detailed implementation plans for all milestones
   4. Use `/plan-execute` to execute individual milestone implementations
   ```

## Error Handling

**Missing Arguments:**
- Show helpful error message
- Explain research command usage
- Provide examples of valid research requests

**Codebase Analysis Failures:**
- Log specific error details
- Continue with high-level planning
- Note areas requiring manual investigation

**Plan Processing Failures:**
- Handle cc-plan errors gracefully
- Continue with manual planning if needed
- Provide clear error messages for plan issues

## Usage Examples

**Start new research:**
`/research "Implement user authentication system with OAuth integration"`

**Continue existing research:**
`/research` (with active research plan)

**Research specific feature:**
`/research "Add real-time collaborative editing to the document editor"`

**Process research plan with notes:**
`/research` (when research plan contains Notes XML section)

**Transition to implementation:**
`/research-implement` (after research plan is complete)

## Key Features

- **High-Level Exploration:** Creates milestone-based research approach
- **Comprehensive Investigation:** Performs complete milestone analysis using UltraThink methodology
- **Architectural Focus:** Emphasizes system design and integration points
- **Implementation Planning:** Prepares for transition to detailed implementation plans
- **Risk Assessment:** Identifies challenges and unknowns early

## Questions XML Format for Research Plans

Research plans support iterative refinement through Questions XML sections. Users can add questions to research plans using cc-plan, and the research command will automatically process answered questions.

**Questions Format:**
```xml
<Questions>
  <Item>
    <Question>1. What specific performance requirements do we need to meet?</Question>
    <Answer>Must support 10,000 concurrent users with sub-200ms response times</Answer>
  </Item>
  <Item>
    <Question>2. Should this integrate with existing authentication systems?</Question>
    <Answer>Yes, integrate with current OAuth service at src/auth/oauth.service.ts</Answer>
  </Item>
  <Item>
    <Question>3. Are there specific technology constraints or preferences?</Question>
    <Answer>Prefer TypeScript and existing React framework, avoid new dependencies</Answer>
  </Item>
</Questions>
```

**Questions Processing:**
- Questions are automatically detected and processed when `/research` is called without arguments
- Only questions with filled Answer fields are processed
- Research plan is updated based on question answers
- Questions section is removed after processing answers
- Empty questions remain in plan for user completion

**Common Question Types:**
- **Performance Requirements:** "What performance/scalability requirements are needed?"
- **Integration Points:** "Should this integrate with existing systems?"
- **Technology Preferences:** "Are there specific technologies or frameworks to use?"
- **Business Constraints:** "What are the timeline or resource constraints?"
- **User Requirements:** "Who are the primary users and what are their needs?"

## Notes XML Format for Research Plans

Research plans support iterative refinement through Notes XML sections. Users can add notes to research plans using cc-plan, and the research command will automatically process them.

**Notes Format:**
```xml
<Notes>
  <Note>
    After reviewing the codebase at src/auth/auth.service.ts:45, I think we should
    consider OAuth integration approach instead of custom authentication.
  </Note>
  <Note>
    The real-time features in src/websocket/socket.service.ts:120-180 suggest we
    already have WebSocket infrastructure that could be leveraged for Milestone 3.
  </Note>
  <Note>
    Performance requirements have changed - we need to support 10,000 concurrent
    users instead of 1,000. This affects the scalability approach for Milestone 2.
  </Note>
</Notes>
```

**Notes Processing:**
- Notes are automatically detected and processed when `/research` is called without arguments
- Referenced files and line numbers are read and analyzed
- Research plan is updated based on note insights
- Notes section is removed after processing
- Agent investigations use note context for enhanced research

**Common Note Types:**
- **Approach Changes:** "After reviewing X, consider Y approach instead"
- **New Requirements:** "Requirements have changed to include Z"
- **Codebase Discoveries:** "Found existing implementation at file:line that changes our approach"
- **Milestone Adjustments:** "Milestone N should be split/combined/modified because..."
- **Integration Insights:** "System X at file:line suggests different integration approach"

## UltraThink Research Commitment

Remember: **UltraThink Research mode** leverages maximum cognitive capabilities for comprehensive investigation and strategic planning. The research command completes the full investigation phase, providing strategic milestones ready for detailed implementation planning by the plan generator agent.

**UltraThink Research Promise:**
- **Maximum Analytical Depth:** Every investigation applies multi-dimensional analysis, systems thinking, and comprehensive pattern recognition
- **Strategic Insight Generation:** Research deliverables provide strategic value beyond technical analysis, including business alignment and competitive positioning
- **Evidence-Based Recommendations:** All conclusions are grounded in systematic codebase investigation and validated through multiple analytical frameworks
- **Risk-Informed Planning:** Comprehensive risk identification across all dimensions with proactive mitigation strategies and adaptive planning capabilities
- **Future-Oriented Thinking:** Solutions designed for long-term success, scalability, and evolution rather than just immediate implementation needs
- **Stakeholder Value Optimization:** Research outcomes serve developers, users, operators, and business stakeholders through balanced recommendation frameworks

The UltraThink Research command provides the most comprehensive, strategically sound, and implementation-ready research foundation for complex feature development initiatives.