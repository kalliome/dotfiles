---
name: implement-tickets
description: Orchestrate implementation of the local tickets in .work/tickets — work the dependency frontier, delegate each ticket to a fresh agent, commit per ticket, then thermo-review the whole run once at the end and land the fixes as a final commit. Runs autonomously to completion without asking questions.
disable-model-invocation: true
---

# Implement Tickets

You are the **orchestrator**. You do not ask the user questions and you do not stop halfway. You drive every actionable ticket in `.work/tickets/` to `done`, committing on the current branch as you go.

Optional argument: one or more ticket ids (`/implement-tickets 03 04`) restricts the run to those tickets and their unfinished blockers. With no argument, run every ticket that isn't `done`.

## Autonomy rules

<autonomy>

- **Never ask the user a question.** When a decision is ambiguous, pick the option most consistent with the existing codebase, proceed, and record the choice under `## Notes` in the ticket file.
- Only stop early if the repo is not a git repo, `.work/tickets/` is missing or empty, or every remaining ticket is `blocked`.
- If a ticket genuinely cannot be completed (missing credentials, an external dependency that does not exist, a contradiction with the code that no reasonable assumption resolves), set its `status: blocked`, append the reason under `## Notes`, commit that status change, and move on to the next ticket. Never leave a ticket `in-progress`.
- Work through to the end of the frontier, then run the single final thermo-review, then report. The user reads the summary once, at the end.

</autonomy>

## 0. Preflight

1. Confirm you are in a git repo and note the **current branch** and the **base sha** (`git rev-parse HEAD`) — all work commits on that branch, and the base sha is what the final review diffs against. Never create branches, never push, never open a PR.
2. Run `git status --porcelain` and record any **pre-existing** modified files. They are not yours: never stage them, and exclude them from every commit you make.
3. Learn this project's commit conventions: read the project `CLAUDE.md` (and `~/.claude/CLAUDE.md`) and skim `git log --oneline -20` for the message style actually in use.
4. Identify the project's verification commands (test / typecheck / lint / build) from `package.json`, `Makefile`, `CLAUDE.md`, or CI config. You will run them after every ticket.

## 1. Build the graph

Read every `.work/tickets/*.md` and parse its frontmatter (`id`, `title`, `status`, `blocked_by`).

The **frontier** is every ticket with `status: todo` (or `in-progress` left over from an interrupted run) whose `blocked_by` ids are all `done`. Work the frontier one ticket at a time, lowest id first — sequential, not parallel, so each ticket's commit lands on a clean base.

After each ticket completes, recompute the frontier. Stop when it is empty.

## 2. Per ticket

<ticket-loop>

**a. Claim it.** Set `status: in-progress` in the ticket's frontmatter.

**b. Implement it in a fresh agent.** Delegate to a subagent (`general-purpose`) with a self-contained prompt: the full ticket body, the acceptance criteria, the project conventions you learned in preflight, and these instructions — implement the whole ticket including tests, do not commit anything, do not touch files unrelated to this ticket, report the files changed and how each acceptance criterion is met. A fresh context per ticket is the point; do not implement it inline yourself.

**c. Verify.** Run the project's test / typecheck / lint commands yourself. If anything fails, fix it (directly, or via another subagent) until it passes. Never mark a ticket done on a red build.

**d. Close it.** Set `status: done` and append a short `## Result` section to the ticket file: what was built and any assumptions taken.

**e. Commit.** Stage only the files this ticket touched plus its ticket file (`git add <paths>` — never `git add -A`, which would sweep in the pre-existing changes from preflight). Commit on the current branch.

No review here — the frontier runs straight through. Review happens once, in step 3.

</ticket-loop>

## Commit rules

- Follow the project's own conventions first — the style in `git log`, and anything `CLAUDE.md` mandates. Conventional-commit prefixes (`feat:`, `fix:`, `docs:`, `chore:`) unless the repo clearly does otherwise.
- **Small and focused.** One commit per ticket is the default; split into a few focused commits when the ticket contains genuinely separable steps (e.g. prefactor, then feature). A ticket never spans more than one branch and never leaves uncommitted work behind. The review fixes from step 3 land as their own final commit on top.
- Add a `Ticket: <NN>-<slug>` trailer so each commit traces back to its ticket.
- Include whatever trailers the harness or project requires (e.g. the `Co-Authored-By` line Claude Code appends).
- Commit only. No `git push`, no PR, no branch creation, no rebasing or amending of commits you did not make in this run.

## 3. Final thermo-review

Once the frontier is empty, review the **whole run at once** — one review, not one per ticket.

1. Compute the run's diff: `git diff <base-sha>..HEAD` using the base sha from preflight, excluding the pre-existing modified files you recorded there. If the diff is very large, split it by area (not by ticket) across a few reviewer subagents running in parallel.
2. Read `~/.claude/skills/thermo-review/SKILL.md` and hand its full content plus the diff to the reviewer subagent(s). Ask for concrete findings, most severe first, each anchored to `file:line`.
3. **Fix everything** in scope of the tickets just implemented — including the ambitious structural ones, that is what the review is for. A finding that spans several tickets is still in scope: it is the run's diff being reviewed, not one ticket's.
4. A finding that is real but genuinely outside the run's scope does not get smuggled in: write it as a **new ticket file** in `.work/tickets/` (next free id, `status: todo`) and note it in the summary. Do not implement it in this run.
5. Re-run the project's verification commands. Never finish on a red build.
6. Commit the fixes as a **single final commit** on the current branch (split only if the fixes are genuinely separable). Stage only the files you touched. Use a `Ticket: review` trailer instead of a ticket id, and list the tickets the fixes cover in the body.

## 4. Report

When the final review commit has landed, print a compact summary — nothing else needed:

- One line per ticket: id, title, final status, commit sha.
- Any tickets left `blocked`, with the reason.
- The final thermo-review: number of findings, what was fixed, its commit sha.
- Any follow-up tickets spun out of thermo-review.
- The verification commands you ran and their final result.
</content>
</invoke>
