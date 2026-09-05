---
name: grilling
description: Grill the user through a dependency-ordered design tree, present the resolved plan for approval, then turn the approved plan into tickets. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

# Grilling

Interview the user until every relevant branch of the decision tree is resolved. The result is an approved plan and a set of tickets, not product-code changes.

## Invariants

- **Facts are the agent's job.** Resolve anything available from the repository, tools, documentation, or external research. Never ask the user for a fact you can find.
- **Decisions are the user's job.** Ask rather than silently choosing a load-bearing product, scope, or trade-off decision.
- **Dependencies determine order.** A question is ready only when every answer it depends on is settled.
- **Every question carries a recommendation.** The user should be approving or redirecting an informed choice, never choosing from a blank slate.

## 1. Map the design tree

Map decisions as a tree: every answer may expose decisions that hang from it. The **frontier** is the complete set of unresolved decisions whose prerequisites are already settled.

Research factual prerequisites before computing the frontier. If research for one branch is still running, leave that branch blocked and continue with any independent ready branches. Delegate independent fact-finding only when useful; do not make the user do it.

## 2. Ask one frontier per round

When the `ask` tool is available, MUST use it instead of printing a wall of questions in chat. Make one `ask` call containing every question on the current frontier. The Work App presents a multi-question call as a step-by-step wizard with a review screen.

For every question:

- Use a stable semantic `id` and a short `header`.
- State the decision and the relevant constraint or trade-off in `question`.
- Offer 2–5 concrete options. Put concise consequences in each option's `description`.
- Set `recommended` to the zero-based index of the recommended option.
- Set `multi: true` only when more than one option can validly apply.
- Do not add a redundant “Other” option; the tool already permits a custom answer.

A question whose answer depends on another open question does not belong in the same call. If the user cancels the tool, stop without guessing or advancing the tree.

Only when `ask` is unavailable, fall back to numbered chat questions. Include the choices and a clearly labelled recommended answer for each question, then wait for all answers in that frontier.

## 3. Recompute the frontier

Apply the answers, reshape the tree, research any newly exposed factual prerequisites, and ask the next frontier. Repeat until the frontier is empty: every relevant branch has been visited and nothing remains silently assumed.

Do not ask for a separate “shared understanding” confirmation. The final plan is the confirmation and approval gate.

## 4. Present the resolved plan

Before drafting the plan, MUST read `skill://to-tickets`. It is hidden from automatic model matching, so the explicit read is required. Use its current exploration, vertical-slice, blocking-edge, and final verify-and-fix rules to draft the ticket breakdown that appears in the plan.

The plan must be self-contained and include:

- the problem, desired outcome, and relevant current-state evidence;
- every settled decision and constraint;
- the implementation approach, scope, non-goals, risks, and verification;
- a numbered ticket breakdown showing each title, blockers, and complete behavior delivered.

There must be no unresolved decision in the plan. If synthesis exposes one, return to `ask`, resolve it, and regenerate the plan.

When the `plan` tool is available, MUST write the required self-contained HTML under `.work/plans/<slug>/` and call `plan`. Handle its result as follows:

- **Feedback or reply:** incorporate it, reopen the design tree if it introduces a decision, and present the revised plan again.
- **Dismissal:** stop. Do not create tickets.
- **Approval:** continue immediately to ticket creation below.

Only when `plan` is unavailable, present the same plan in chat and obtain explicit approval there. Use `ask` for that approval when it is available.

## 5. Materialize the approved tickets

Plan approval also approves the exact ticket breakdown shown in that plan. Continue under the loaded `to-tickets` skill, treating its ticket-breakdown quiz and approval step as already complete. Do not ask for a second ticket approval.

Follow the current `to-tickets` instructions to write the ticket files and return its implementation handoff. If the plan tool's generic approval result says “Implement it now,” this workflow overrides that wording: create tickets only. Do not edit product code or invoke `implement-tickets`.

Stop after the `to-tickets` handoff prompt.
