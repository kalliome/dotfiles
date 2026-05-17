# UX Flow Handoff Format

Flow docs live in `docs/ux/{flow-or-page-slug}.md`. They capture implementation-ready details for a specific flow, page, or component experience.

## Template

~~~md
# {Flow or Page Name}

## Goal

{What the user is trying to accomplish and what success means.}

## Users and context

- Primary user: {who this is for}
- Relevant roles/permissions: {only if they affect UI}
- Entry points: {where the user starts}
- Exit/success destination: {where the user lands after success}

## Scope

In scope:
- {Flow/job/screen included}

Out of scope:
- {Explicit non-goals}

## Screen and state map

```txt
Entry
  ↓
Screen A ── valid submit ──▶ Success
  │
  ├─ validation error ─────▶ Screen A with inline errors
  └─ forgot/cancel ────────▶ Recovery/exit path
```

## Wireframes

### Desktop

```txt
┌────────────────────────────────────────────────────┐
│ {Region / navigation / header}                     │
├────────────────────────────────────────────────────┤
│ {Primary content, data, actions}                   │
│                                                    │
│ [Primary action]   [Secondary action]              │
└────────────────────────────────────────────────────┘
```

### Mobile

```txt
┌─────────────────────┐
│ {Header}            │
├─────────────────────┤
│ {Primary content}   │
│ [Primary action]    │
└─────────────────────┘
```

## View inventory

### {Screen/state name}

Visible data:
- {Field/data point} — {source or assumption}

Actions:
- Primary: {action}
- Secondary: {action}
- Destructive/cancel/recovery: {action if relevant}

Permissions/visibility:
- {Who can see or use what, only if relevant}

## Components

- {Component/pattern} — {role in the flow}

## States and recovery

- Loading: {what the user sees and can/cannot do}
- Empty: {empty-state message/action if relevant}
- Error: {message placement and recovery action}
- Validation: {timing, placement, and copy rule}
- Unauthorized/permission: {if relevant}
- Offline/network failure: {if relevant}
- Partial success: {if relevant}
- Cancel/back/retry: {paths and consequences}

## Copy notes

- Primary CTA: {label}
- Secondary CTA: {label}
- Decision-critical helper/error/empty text: {text or rule}

## Accessibility notes

{Keyboard path, focus management, labels/help text, contrast, responsive behavior, and screen-reader-visible status/errors when relevant.}

## Visual consistency check

Use `Pass`, `Needs decision`, `Issue`, or `Not applicable` for each relevant item. Resolve strict fundamentals before implementation handoff.

- Row alignment: {status and note; row children vertically middle-aligned by default unless intentionally top-aligned}
- Icon/control centerline: {status and note}
- Spacing scale: {status and note}
- Regional edge alignment: {status and note}
- Action hierarchy: {status and note}
- Typography hierarchy: {status and note}
- Responsive wrap/stack behavior: {status and note}
- Overflow/truncation behavior: {status and note}
- Component consistency: {status and note}
- Visual accessibility: {status and note}
- State clarity: {status and note}
- Color semantics: {status and note}
- Density and breathing room: {status and note}
- Adaptive checks for this flow: {status and note}

## Reusable patterns to update in UX.md

- {Pattern that should be added or changed in root UX.md}

## Open decisions

- {Only unresolved decisions that block implementation or consistency}

## Implementation handoff checklist

- [ ] Screens/routes identified
- [ ] Components identified
- [ ] Data points and source assumptions identified
- [ ] Loading/empty/error/validation states identified
- [ ] Responsive behavior identified
- [ ] Relevant accessibility behavior identified
- [ ] Visual consistency check completed and strict fundamentals resolved
- [ ] Reusable UX.md updates captured
~~~

## Rules

- **Specific to one flow/page.** Do not duplicate global patterns unless they are directly applied here.
- **Implementation-ready.** A builder should know the screen sequence, data, actions, and state behavior without re-running the whole conversation.
- **Use ASCII for structure, not pixel perfection.** Show hierarchy, regions, actions, and state changes.
- **Mark assumptions.** If codebase exploration did not confirm a data source or route, label it as an assumption or open decision.
