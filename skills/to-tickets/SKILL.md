---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, written as local markdown files under .work/tickets — then hand back a copy-paste prompt that makes a fresh agent implement them all.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it.

Tickets are plain markdown files in the current project at `.work/tickets/`. There is no external tracker: the frontmatter in each file *is* the status.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, a doc, a URL) as an argument, read its full contents first.

### 2. Explore the codebase

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's own vocabulary and respect the conventions and decisions already documented in the repo (`CLAUDE.md`, `docs/`, ADRs) in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Always end with a final verify-and-fix ticket.** The last ticket is blocked by every other ticket. It walks every preceding ticket's acceptance criteria against the actual code, and verifies the *whole* — end-to-end behaviour that only emerges once all slices land, plan requirements no single ticket owned, and integration seams between slices. Any gap it finds it **fixes right there, in this ticket** — the ticket is only done when the plan is actually delivered, not when the gaps are catalogued. Only a gap too large to close in this ticket's context window gets recorded under `## Notes` as concrete follow-up work instead. The plan often exists only in the conversation that produced the tickets, so this ticket must be self-contained: write the full plan into its body under a `## Plan` section — every requirement, decision, and constraint the implementation must satisfy — so a fresh agent can verify against it without any other source. Its acceptance criteria list the plan's top-level outcomes, not per-ticket ones.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown. Do not write any files before approval.

### 5. Write the ticket files

Create `.work/tickets/` in the current project if it does not exist. Write **one file per ticket** — never a single combined file — named `<NN>-<slug>.md`, numbered in dependency order (blockers first).

If `.work/tickets/` already contains tickets, continue numbering from the highest existing id. Never renumber or overwrite existing tickets; `blocked_by` may point at them.

<ticket-file-template>

```markdown
---
id: "03"
title: Short descriptive name
status: todo
blocked_by: ["01", "02"]
---

# 03 — Short descriptive name

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Notes

Context an implementing agent needs that isn't obvious from the codebase. Omit if there is none.
```

</ticket-file-template>

<status-vocabulary>

- `todo` — not started. Every ticket you write starts here.
- `in-progress` — claimed by an implementing agent.
- `done` — implemented, reviewed, and committed.
- `blocked` — cannot proceed; the reason is recorded under `## Notes`.

`blocked_by` is a list of ticket ids as quoted strings, or `[]` for "can start immediately".

</status-vocabulary>

Avoid specific file paths or code snippets in the body — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts.

Check whether `.work/` is gitignored and tell the user which way it is — committed ticket files give the status changes a history, ignored ones keep them out of the repo.

### 6. Hand back the implementation prompt

Finish by printing a fenced block the user can copy verbatim into a fresh agent. Nothing else after it.

<handoff-prompt-template>

````
```
/implement-tickets

Repo: <absolute path to the repo>
Branch: <current branch>
Tickets: .work/tickets — <NN>–<NN> (<count> tickets)
Goal: <one line describing what the whole set delivers>
```
````

</handoff-prompt-template>

The `implement-tickets` skill is the orchestrator: it works the dependency frontier, delegates each ticket to a fresh agent, thermo-reviews the diff, fixes the findings, and commits per ticket without asking questions.
</content>
