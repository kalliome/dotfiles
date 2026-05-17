---
name: grill-ux
description: Use when the user wants to design or stress-test a UX/UI flow, screen, component, onboarding, form, or interaction; asks one question at a time, uses ASCII wireframes, and documents agreed reusable patterns in root UX.md.
---

<what-to-do>

Interview the user relentlessly about every aspect of a UX/UI plan until you reach shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

Use compact ASCII prototypes and wireframes to make flow, layout, hierarchy, states, and data visible as decisions crystallise.

Run a compact **Visual consistency check** after major layout decisions and again before documentation/build handoff. Use it to catch basic UI issues before a spec is treated as implementation-ready.

</what-to-do>

<supporting-info>

## UX documentation model

GRIL-UX has two documentation targets:

- Root `UX.md` is durable project-wide UX memory: reusable UX language, layout patterns, component conventions, data-display rules, interaction defaults, and accepted visual defaults.
- Optional `docs/ux/{flow-or-page-slug}.md` files are flow-specific handoff specs: one-off screen sequences, state maps, ASCII wireframes, data inventories, edge cases, and implementation notes.

Create documentation lazily. If root `UX.md` is missing, ask before creating it. Once a doc exists, update it as stable decisions are resolved rather than batching everything at the end.

Use [UX-FORMAT.md](./UX-FORMAT.md) for root `UX.md` and [UX-FLOW-FORMAT.md](./UX-FLOW-FORMAT.md) for `docs/ux/*.md`.

## Codebase awareness

Before asking questions in an existing codebase, scan the UX surface where useful:

- Existing `UX.md` and `docs/ux/`
- Routes, pages, layouts, and screens
- Component libraries, design-system files, stories, screenshots, or examples
- Existing form, navigation, table, dashboard, auth, modal, and empty-state patterns
- Product/domain docs only for context

Do not ask questions the codebase can answer. Treat documented patterns in `UX.md` as authoritative. Treat observed code patterns as provisional evidence: use them to suggest defaults, surface conflicts, or ask sharper questions.

If the repo has multiple apps or product surfaces, use one root `UX.md` for shared patterns and scoped UX docs only when surfaces intentionally have different UX systems. Use the active workspace root for `UX.md`; ask when the root is ambiguous.

## Questioning order

Walk dependencies in this order unless codebase evidence or the user's answer requires revisiting an earlier branch:

1. **User job and outcome** — who is trying to do what, and what counts as success?
2. **Scope and information architecture** — which flows, pages, entry points, exits, and navigation paths exist?
3. **Screen sequence** — what screens/states appear, in what order, with what branching?
4. **Per-screen jobs** — what each screen must help the user decide or do.
5. **Layout and hierarchy** — page shape, visual emphasis, responsive assumptions, and major regions.
6. **Components, data, and actions** — visible data points, primary/secondary actions, permissions, and source-of-truth assumptions.
7. **States and recovery** — loading, empty, error, validation, unauthorized, offline/network failure when relevant, partial success, cancel, and retry paths.
8. **Visual tone and copy** — decision-critical copy, CTA labels, help text, status/error wording, and visual personality when it affects comprehension.
9. **Accessibility when relevant** — keyboard path, focus management, labels/help text, contrast, responsive behavior, and screen-reader-visible status/errors for flows/components where these materially matter.
10. **Documentation/build handoff** — update `UX.md`, create/update `docs/ux/*.md`, or hand off to implementation.

Ask one focused question at a time. Use 2–4 concrete options when useful, and always include a clearly labelled recommended answer with a short rationale. Be opinionated: provide concrete defaults instead of neutral "it depends" unless a real constraint is missing.

Stop a branch when the decision is implementation-ready, not when every theoretical variant has been exhausted. Revisit upstream decisions if downstream answers conflict.

After layout/hierarchy decisions, run the Visual consistency check before drilling into lower-level component details when the check reveals unresolved layout dependencies.

## Wireframes and prototypes

After each major layout or flow decision, show a compact updated ASCII wireframe or flow sketch so the user can react before drilling into details.

Prefer boxed, annotated wireframes:

```txt
Desktop
┌────────────────────────────────────────────────────┐
│ Header: Product mark                         Help  │
├────────────────────────────────────────────────────┤
│ ┌─────────────────────┐  ┌───────────────────────┐ │
│ │ Primary panel       │  │ Supporting panel      │ │
│ │ - Required data     │  │ - Trust cue           │ │
│ │ - Primary action    │  │ - Secondary info      │ │
│ └─────────────────────┘  └───────────────────────┘ │
└────────────────────────────────────────────────────┘

Mobile
┌─────────────────────┐
│ Header              │
├─────────────────────┤
│ Primary panel       │
│ - Required data     │
│ - Primary action    │
├─────────────────────┤
│ Supporting info     │
└─────────────────────┘
```

Create separate state variants only when the layout materially changes.

## Visual consistency check

Use the Visual consistency check as a fixed baseline plus adaptive additions for the current UI type. It is a strict gate for fundamentals and advisory for polish:

- **Strict fundamentals:** alignment, spacing, hierarchy, CTA clarity, responsive viability, overflow behavior, component consistency, and visual accessibility basics. Resolve these before handoff.
- **Advisory polish:** extra delight, animation nuance, brand expression, and decorative refinements. Surface these as suggestions without blocking handoff.

Output checklist results explicitly after major layout decisions and before handoff. Use these statuses:

- `Pass` — the decision/spec satisfies the rule.
- `Needs decision` — ask the next focused question before continuing.
- `Issue` — the current direction conflicts with the rule and should be fixed before handoff.
- `Not applicable` — the rule does not apply to this UI.

Baseline checklist:

1. **Row alignment:** Children in row layouts are vertically middle-aligned by default. Use top alignment only as an intentional exception for multiline content, stacked metadata, or card-like compositions.
2. **Icon/control centerline:** Icons, labels, inputs, badges, and buttons in a row share a clear visual centerline; mismatched control heights are resolved intentionally.
3. **Spacing scale:** Related elements use smaller gaps; unrelated groups use larger gaps. Avoid equal spacing everywhere when it flattens hierarchy.
4. **Regional edge alignment:** Align left/right edges within each region across cards, fields, headers, and actions unless an intentional asymmetric/marketing layout calls for otherwise.
5. **Action hierarchy:** Each screen or major region has one clear primary action. Secondary/destructive/recovery actions are visually quieter and placed consistently relative to the primary action.
6. **Typography hierarchy:** Text size, weight, line length, line height, and heading/body contrast support scanning and comprehension.
7. **Responsive behavior:** Row layouts define wrap or stack behavior for narrow widths. Button rows, filters, form groups, nav bars, and card metadata do not depend on infinite horizontal space.
8. **Overflow/truncation:** Long labels, names, values, translated copy, badges, URLs, chips, and dense action rows have defined wrap, truncate, or disclosure behavior.
9. **Component consistency:** Components with the same role look and behave the same across the flow unless there is a deliberate semantic reason for a variant.
10. **Visual accessibility:** Contrast, visible focus, target size, and label clarity are sufficient. Do not rely on placeholder-only labels or color alone for meaning.
11. **State clarity:** Interactive elements have clear default, hover/active, disabled, loading, error, and selected states when relevant.
12. **Color semantics:** Color reinforces semantic meaning consistently; errors, warnings, success, destructive actions, and primary actions do not drift visually or rely on color alone.
13. **Density and breathing room:** Dense UIs still use grouping, whitespace, section breaks, or progressive disclosure so controls, badges, borders, and text blocks do not compete equally.

Add adaptive checklist items for the UI being discussed, for example: form label/error placement, table row action placement, dashboard card scan order, modal focus/escape behavior, navigation active state, empty-state action placement, or mobile bottom-action behavior.

Use a compact format:

```md
### Visual consistency check

- Pass — Row alignment: toolbar controls share a middle centerline.
- Needs decision — Responsive behavior: filter row needs wrap vs stack decision on mobile.
- Issue — Action hierarchy: two primary buttons compete in the same card.
- Not applicable — Table row density: no table in this flow.
```

## Documentation rules

### Root `UX.md`

Write only reusable patterns to root `UX.md`: anything expected to apply to multiple screens or flows, such as auth page layout, form validation behavior, empty-state style, table actions, modal rules, or navigation hierarchy.

Each pattern should include concrete examples when helpful: "Use when", "Avoid", and a tiny ASCII/example snippet when visual structure matters. Keep open questions only when they block consistency or implementation.

If a proposed direction conflicts with existing `UX.md` or current UI, call out the conflict immediately, show the existing pattern, ask whether this is an exception or a pattern change, and document the resolution.

### Flow docs

When the user chooses a flow/page handoff spec, create or update `docs/ux/{flow-or-page-slug}.md`. Include goal, users/context, entry points, screen/state map, ASCII wireframes, component inventory, data points per view, validation/error/loading/empty states, accessibility notes when relevant, open decisions, and implementation handoff checklist.

## Build handoff

GRIL-UX owns interrogation, shared understanding, ASCII prototypes, and UX documentation. If the user chooses to build after the UX plan is resolved, hand off to the normal implementation workflow rather than continuing to code inside the grilling posture. Route high-polish UI review or implementation to a UI/UX specialist when available.

Close with a clear next action choice:

1. Save/update root `UX.md`
2. Create/update a `docs/ux/{slug}.md` handoff spec
3. Hand the agreed spec to implementation

## Compact example

User: "I want to update authentication."

Assistant:

1. Scan existing routes/components/auth UI and `UX.md` if present.
2. Ask: "Which auth jobs are in scope: login only, register, lost password, Google auth, or all? Recommended: login + lost password first unless registration is currently required, because that resolves the core returning-user path before expanding account creation."
3. After scope is agreed, ask layout: "Should auth use a centered card or split two-column layout? Recommended: centered card for focused utility auth; split layout only if brand/trust storytelling matters."
4. Show a compact wireframe.
5. Inventory fields, CTAs, validation, loading/error states, recovery paths, responsive behavior, and relevant accessibility.
6. Save reusable auth/form patterns to `UX.md`; optionally create `docs/ux/authentication.md` or hand off to implementation.

</supporting-info>
