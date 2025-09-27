---
description: Research and investigate potential implementation plans by exploring high-level milestones and detailed investigation
allowed-tools: Read, Glob, Grep, Bash(pwd:*), Bash(ls:*), WebFetch, Bash(cc-plan:*), Task
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

   **Special Case - No Arguments with Active Research Plan Notes:**
   If `/research` is called without arguments AND an active research plan exists with notes, automatically process those notes:

   - Notes are formatted in a single `<Notes>` XML container with multiple `<Note>` tags inside at the end of the research plan file
   - Read the referenced files and line numbers mentioned in each note
   - Analyze what changes are needed to the research plan based on all the notes
   - Make the necessary updates to the research plan (approach changes, milestone modifications, etc.)
   - **Remove the entire `<Notes>` section after processing** - all notes are consumed during refinement
   - If clarification is needed about any notes or changes, ask the user
   - This allows for iterative research plan refinement based on feedback or discoveries

   **Standard Case - Research Plan Exists:**
   If a research plan exists (and no automatic note processing occurred), check the plan status:

   **If Research Plan Exists - Initial Phase:**
   If a plan marked as "Research" exists but milestones haven't been investigated yet, proceed to Phase 2 (Detailed Milestone Investigation).

   **If Research Plan Exists - Investigation Complete:**
   If all milestones have been investigated, display the research summary and ask if they want to:
   - Review and modify the research findings
   - Add additional milestones for investigation
   - Transition to implementation planning using `/plan`
   - Create new research for a different feature

   **If No Research Plan Exists:**
   Proceed with creating a new research plan (continue with steps 2-5).

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

3. **UltraThink Clarification and Alternative Exploration:**

   Apply systematic questioning and comprehensive alternative analysis to understand all dimensions:

   **Strategic Clarification Questions (ask 5-7 deep questions):**
   - What are the primary use cases, user workflows, and success metrics this feature should achieve?
   - What specific performance, scalability, availability, and security requirements must be satisfied?
   - How should this integrate with existing systems, and what are the data consistency and transaction requirements?
   - Are there preferred technologies, architectural patterns, or strategic technology directions to align with?
   - What are the timeline expectations, resource constraints, and acceptable risk levels?
   - Who are the primary users, stakeholders, and what are their technical capabilities and business requirements?
   - What compliance, accessibility, regulatory, or governance requirements must be addressed?
   - How does this feature align with the overall business strategy and technology roadmap?
   - What are the expected usage patterns, growth projections, and scalability requirements?

   **UltraThink Alternative Approaches Investigation:**
   Systematically explore 3-4 comprehensive approaches using multi-dimensional analysis:

   **Approach A: [Evolutionary Enhancement]**
   - Build upon existing systems with strategic architectural improvements
   - **Technical Pros:** Lower risk, faster delivery, leverages existing infrastructure and team knowledge
   - **Technical Cons:** May inherit architectural debt, limited scalability potential, constraint by existing patterns
   - **Business Impact:** Faster time-to-market, lower initial investment, reduced operational disruption
   - **Risk Profile:** Low implementation risk, moderate technical debt accumulation, limited future flexibility
   - **Best for:** Tight timelines, budget constraints, risk-averse environments, proven existing architecture

   **Approach B: [Modern Greenfield Implementation]**
   - Build new system components using contemporary architecture patterns and technologies
   - **Technical Pros:** Maximum flexibility, scalability, maintainability, modern technology stack
   - **Technical Cons:** Higher complexity, longer development time, integration challenges, learning curve
   - **Business Impact:** Higher initial investment, longer time-to-market, potential for competitive advantage
   - **Risk Profile:** Higher implementation risk, lower technical debt, maximum future adaptability
   - **Best for:** Long-term strategic initiatives, competitive differentiation, scalability requirements

   **Approach C: [Strategic Hybrid Solution]**
   - Selectively modernize critical components while enhancing existing stable systems
   - **Technical Pros:** Balanced risk-reward, preserves working systems, enables gradual evolution
   - **Technical Cons:** Complex integration, dual-system maintenance, potential architectural inconsistency
   - **Business Impact:** Moderate investment, balanced timeline, incremental value delivery
   - **Risk Profile:** Moderate risk, controlled technical debt, good adaptability
   - **Best for:** Large existing systems, phased transformation strategies, mixed technology environments

   **Approach D: [Platform-Centric Solution]** (if applicable)
   - Build upon or extend existing platform capabilities with standardized integration patterns
   - **Technical Pros:** Leverages platform investments, standardized patterns, operational consistency
   - **Technical Cons:** Platform lock-in, limited customization, dependency on platform evolution
   - **Business Impact:** Platform ROI maximization, operational efficiency, vendor relationship leverage
   - **Risk Profile:** Platform dependency risk, moderate flexibility, strong operational stability
   - **Best for:** Platform-heavy environments, standardization goals, operational efficiency priorities

   **Direction Selection:**
   After presenting alternatives, ask the user to select their preferred approach:
   - "Based on your requirements and constraints, which approach aligns best with your goals?"
   - "Are there aspects from multiple approaches you'd like to combine?"
   - "Do any of these approaches raise concerns or require modification?"

   Wait for user response before proceeding to milestone identification.

4. **High-Level Milestone Identification:**

   Create 3-6 major milestones that represent significant phases of the implementation:

   - **Milestone 1:** Foundation/Infrastructure setup
   - **Milestone 2:** Core functionality implementation
   - **Milestone 3:** Integration with existing systems
   - **Milestone 4:** User interface and experience
   - **Milestone 5:** Testing and validation
   - **Milestone 6:** Performance and optimization

   Each milestone should represent a major phase of work that could potentially be split into separate implementation plans.

4. **UltraThink Research Plan Generation:**

   After user selects their preferred approach, generate a comprehensive research plan using UltraThink methodology:

   ```markdown
   # UltraThink Research Plan: [Feature Name]

   **Status: UltraThink Research Phase**
   **Research Depth:** Maximum Cognitive Analysis
   **Methodology:** Multi-Dimensional Systems Thinking

   ## Strategic Overview

   [Comprehensive description of what needs to be researched and implemented, including business value, technical scope, and strategic alignment]

   ## Selected Approach Analysis

   **Chosen Direction:** [Selected approach name]
   **Strategic Rationale:** [Multi-dimensional reasoning for approach selection including technical, business, risk, and timeline factors]
   **Critical Success Factors:** [Key elements that must be achieved for approach success]
   **Approach Validation Criteria:** [How we will confirm this approach remains optimal during research]

   ## Comprehensive Requirements Analysis

   **Primary Use Cases & User Journeys:** [Detailed user workflows and success scenarios]
   **Performance & Scalability Profile:** [Specific metrics, load patterns, and growth projections]
   **Integration Architecture:** [System integration patterns, data flow, and API requirements]
   **Technical Constraints & Opportunities:** [Limitations, preferences, and optimization possibilities]
   **Timeline & Resource Framework:** [Delivery expectations, team capabilities, and constraint analysis]
   **Compliance & Governance Requirements:** [Regulatory, security, and organizational requirements]

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

   ## UltraThink Research Milestones

   ### Milestone 1: [Foundation Architecture Analysis]
   - **Multi-Dimensional Scope:** [Comprehensive coverage across technical, business, and operational domains]
   - **Strategic Questions:** [Deep investigative questions addressing root causes and systemic implications]
   - **Expected Insights:** [Specific knowledge, decisions, and strategic recommendations to be gained]
   - **Success Criteria:** [Measurable outcomes and validation checkpoints]
   - **Risk Factors:** [Potential challenges and mitigation approaches]
   - **Dependencies:** [Prerequisites and parallel investigation requirements]
   - **Status:** Pending UltraThink Investigation

   ### Milestone 2: [Core Implementation Strategy]
   - **Multi-Dimensional Scope:** [Technical implementation patterns, integration architecture, and performance optimization]
   - **Strategic Questions:** [Implementation approach validation, technology selection, and architectural pattern analysis]
   - **Expected Insights:** [Technical approach recommendations, implementation methodology, and risk mitigation strategies]
   - **Success Criteria:** [Technical feasibility confirmation and approach validation]
   - **Risk Factors:** [Implementation complexity and integration challenges]
   - **Dependencies:** [Foundation analysis completion and approach validation]
   - **Status:** Pending UltraThink Investigation

   [Continue with UltraThink-enhanced milestone structure for all remaining milestones...]

   ## Next Steps

   1. Conduct detailed investigation of each milestone
   2. Create detailed implementation plans for each milestone
   3. Determine if milestones should be separate plans or combined
   4. Transition to implementation planning phase

   ## Investigation Status

   - [ ] Milestone 1 Investigation
   - [ ] Milestone 2 Investigation
   - [ ] Milestone 3 Investigation
   - [ ] Milestone 4 Investigation
   - [ ] Milestone 5 Investigation
   - [ ] Milestone 6 Investigation
   ```

   Save this research plan using cc-plan:

   ```bash
   cc-plan plan create --project-path "$(pwd)" --session-id "$CLAUDE_SESSION_ID" --content "[research plan content]"
   ```

### Phase 2: Detailed Milestone Investigation

If a research plan already exists, proceed with detailed investigation of each milestone:

1. **Load Existing Research Plan:**

   ```bash
   cc-plan plan get --session-id "$CLAUDE_SESSION_ID"
   ```

2. **Process Research Plan Notes (if present):**

   Before proceeding with milestone investigation, check if the research plan contains notes:

   **Notes Detection:**
   - Look for `<Notes>` XML container at the end of the research plan
   - If notes are found, process them before continuing with milestone investigation

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

   **Notes Analysis Steps:**
   - Read all referenced files and line numbers mentioned in notes
   - Analyze what changes are needed to the research plan based on notes
   - Update approach selection if notes suggest different direction
   - Modify milestones based on new insights from notes
   - Adjust user requirements summary if notes provide clarification
   - Update research objectives based on note feedback

   **Research Plan Updates:**
   Apply necessary changes to the research plan:
   - Approach modifications (if notes suggest better alternatives)
   - Milestone adjustments (scope changes, new milestones, removed milestones)
   - Requirement clarifications (updated based on note insights)
   - Investigation priority changes (based on note findings)

   **Complete Notes Processing:**
   - Update the research plan with all note-based changes
   - **Remove the entire `<Notes>` section** after processing
   - Save the updated research plan using cc-plan
   - Continue with milestone investigation using updated plan

   ```bash
   cc-plan plan update --session-id "$CLAUDE_SESSION_ID" --content "[updated research plan content]"
   ```

   **If No Notes Found:**
   Continue directly to approach validation and milestone investigation.

3. **Approach Validation:**

   Before investigating milestones, validate the selected approach through initial codebase analysis:

   ```
   => Validating Selected Approach: [Approach Name]

   Analyzing current codebase to validate approach feasibility...
   Checking integration points and existing patterns...
   Identifying potential challenges with selected approach...
   ```

   If significant issues are discovered with the selected approach, present alternative recommendations:

   ```
   ⚠️  Approach Validation Results:

   Selected Approach: [Approach Name]
   Issues Discovered:
   - [Issue 1 with impact assessment]
   - [Issue 2 with impact assessment]

   Alternative Recommendations:
   - Consider [Alternative Approach] because [reasoning]
   - Modified approach: [Suggested modifications to selected approach]

   Would you like to:
   1. Continue with selected approach and plan mitigation strategies
   2. Switch to recommended alternative approach
   3. Modify the selected approach based on findings
   ```

   Wait for user decision before proceeding to milestone investigation.

3. **Investigate Each Milestone:**

   For each milestone that hasn't been investigated yet, launch the Plan Researcher agent:

   ```
   => Investigating Milestone [N]: [Milestone Name]

   Selected Approach: [Approach name and key considerations]
   Milestone Scope: [detailed scope description]
   Key Research Questions: [list of questions to investigate]
   Validation Context: [any approach-specific considerations from validation]
   Notes Context: [any milestone-specific insights from processed notes]

   Launching Plan Researcher agent...
   ```

   **Notes Integration for Agent:**
   If notes were processed that relate to specific milestones, include this context in the agent prompt to ensure the research considers any user feedback or discoveries captured in the notes.

3. **UltraThink Plan Researcher Agent Tasks:**

   For each milestone, use the Task tool to launch a "plan-researcher" agent with this UltraThink-enhanced prompt:

   ```
   ULTRATHINK MODE: Conduct maximum cognitive depth research and planning for the following milestone within the context of the selected approach. Apply multi-dimensional analysis, systems thinking, and comprehensive investigation techniques.

   ## UltraThink Milestone Context
   Milestone: [Milestone Name]
   Multi-Dimensional Scope: [Comprehensive scope across technical, business, operational domains]
   Strategic Questions: [Deep investigative questions addressing systemic implications]
   Success Criteria: [Measurable outcomes and validation checkpoints]
   Risk Factors: [Potential challenges requiring mitigation strategies]

   ## Strategic Approach Context
   Chosen Approach: [Selected approach name with strategic rationale]
   Multi-Dimensional Rationale: [Technical, business, risk, and timeline factors in approach selection]
   Comprehensive Requirements: [Full user requirements matrix from clarification analysis]
   Validation Framework: [Criteria for confirming approach optimality]
   Notes Context: [Strategic insights from processed research plan notes]

   ## UltraThink Research Objectives
   1. **Multi-Dimensional Codebase Analysis:** Systematically examine current implementations using technical, architectural, performance, and maintainability lenses within approach context
   2. **Comprehensive Component Mapping:** Identify all files, components, interfaces, and dependencies requiring changes with impact analysis
   3. **Systems Integration Analysis:** Map integration points, data flows, and dependencies with emphasis on systemic effects and emergent behaviors
   4. **Strategic Implementation Evaluation:** Analyze 3-5 implementation options using quantitative and qualitative criteria within approach constraints
   5. **Advanced Task Architecture:** Create detailed, dependency-aware implementation tasks with resource allocation and complexity modeling
   6. **Risk-Informed Assessment:** Evaluate risks across technical, operational, business, and organizational dimensions with comprehensive mitigation strategies
   7. **Innovation with Stability Analysis:** Explore cutting-edge implementation methods while ensuring architectural consistency and operational reliability
   8. **Approach Validation & Optimization:** Confirm approach feasibility and identify optimization opportunities specific to this milestone

   ## Expected UltraThink Output
   - **Strategic Analysis:** Comprehensive current system state analysis with architectural pattern recognition
   - **Technical Specification:** Detailed files, components, interfaces, and integration requirements with evolution planning
   - **Multi-Method Evaluation:** 3-5 implementation approaches with detailed trade-off analysis and decision matrices
   - **Advanced Task Planning:** Hierarchical task breakdown with dependency modeling, resource allocation, and timeline projections
   - **Comprehensive Risk Management:** Multi-dimensional risk assessment with layered mitigation strategies and contingency planning
   - **Systems Integration Plan:** Cross-milestone dependencies and integration requirements with validation checkpoints
   - **Approach Optimization:** Feasibility confirmation with strategic recommendations for approach enhancement

   ## UltraThink Research Guidelines
   - **Single Milestone Deep Focus:** Apply maximum cognitive depth to this milestone without diluting analysis across the entire feature set
   - **Strategic Approach Alignment:** Ensure all recommendations optimize for the selected overall approach while identifying improvement opportunities
   - **Multi-Stakeholder Value:** Consider how this milestone delivers value to users, developers, operators, and business stakeholders
   - **Evidence-Based Integration:** Incorporate insights from processed research plan notes with validation through codebase investigation
   - **Opportunity & Constraint Balance:** Identify approach-specific opportunities while honestly assessing constraints and limitations
   - **Adaptive Planning:** Design milestone-level alternatives and pivot strategies if systemic issues emerge with the overall approach
   - **Comprehensive Context:** Address all milestone-specific concerns from processed notes while maintaining systems thinking perspective
   - **Future-Oriented Design:** Plan for extensibility, scalability, and evolution beyond immediate milestone requirements
   ```

4. **Update Research Plan:**

   After each milestone investigation, update the research plan with findings:

   ```bash
   cc-plan plan update --session-id "$CLAUDE_SESSION_ID" --content "[updated research plan with findings]"
   ```

5. **Research Progress Tracking:**

   ```
   🔍 Research Progress

   Research Plan: [Plan Title]
   Progress: [X/Y] milestones investigated

   ✅ Milestone 1: [Name] - Investigation Complete
   ✅ Milestone 2: [Name] - Investigation Complete
   🔍 Milestone 3: [Name] - Under Investigation
   ⏳ Milestone 4: [Name] - Pending
   ⏳ Milestone 5: [Name] - Pending

   Current Focus: [current milestone being investigated]
   ```

6. **Final Research Summary:**

   After all milestones are investigated, create a comprehensive summary:

   ```
   🎯 Research Complete!

   Research Plan: [Plan Title]
   Total Milestones: [N]
   Investigated: [N]

   Key Findings:
   - [major discovery 1]
   - [major discovery 2]
   - [major discovery 3]

   Recommended Implementation Approach:
   - [approach recommendation]

   Suggested Plan Breakdown:
   Plan 1: [Milestone groups] - [reasoning]
   Plan 2: [Milestone groups] - [reasoning]
   Plan 3: [Milestone groups] - [reasoning]

   Next Steps:
   1. Review research findings
   2. Create implementation plans using /plan command
   3. Begin implementation with /plan-execute
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

**Agent Failures:**
- Handle Plan Researcher agent errors gracefully
- Fall back to manual investigation
- Continue with remaining milestones

## Usage Examples

**Start new research:**
`/research "Implement user authentication system with OAuth integration"`

**Continue existing research:**
`/research` (with active research plan)

**Research specific feature:**
`/research "Add real-time collaborative editing to the document editor"`

**Process research plan with notes:**
`/research` (when research plan contains Notes XML section)

## Key Features

- **High-Level Exploration:** Creates milestone-based research approach
- **Detailed Investigation:** Uses specialized agent for deep milestone analysis
- **Architectural Focus:** Emphasizes system design and integration points
- **Implementation Planning:** Prepares for transition to detailed implementation plans
- **Risk Assessment:** Identifies challenges and unknowns early

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

Remember: **UltraThink Research mode** leverages maximum cognitive capabilities for exploratory and investigative analysis - no actual code implementation occurs during research phase.

**UltraThink Research Promise:**
- **Maximum Analytical Depth:** Every investigation applies multi-dimensional analysis, systems thinking, and comprehensive pattern recognition
- **Strategic Insight Generation:** Research deliverables provide strategic value beyond technical analysis, including business alignment and competitive positioning
- **Evidence-Based Recommendations:** All conclusions are grounded in systematic codebase investigation and validated through multiple analytical frameworks
- **Risk-Informed Planning:** Comprehensive risk identification across all dimensions with proactive mitigation strategies and adaptive planning capabilities
- **Future-Oriented Thinking:** Solutions designed for long-term success, scalability, and evolution rather than just immediate implementation needs
- **Stakeholder Value Optimization:** Research outcomes serve developers, users, operators, and business stakeholders through balanced recommendation frameworks

The UltraThink Research command provides the most comprehensive, strategically sound, and implementation-ready research foundation for complex feature development initiatives.