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

## Intentional visual restraint check

Use `Pass`, `Needs decision`, `Issue`, or `Not applicable` for each relevant item. Use this check to prevent generic AI/SaaS visual tropes and keep visual choices intentional, product-specific, and justified. Resolve or explicitly justify all `Issue`s before implementation handoff.

- Decorative effects: {status and note; avoid unexplained gradients, aurora blobs, neon glows, glassmorphism, rainbow washes, and decorative color effects}
- Elevation and surfaces: {status and note; avoid prominent shadows, hover-lift everywhere, floating cards, stacked panels, and unnecessary cardification}
- Shape and radius: {status and note; use existing tokens or small radius by default; avoid pill/large-rounded surfaces unless justified}
- Generic SaaS layout tropes: {status and note; avoid bento grids, centered hero stacks, 3-card rows, alternating marketing sections, arbitrary stat cards, fake dashboards, and desktop-only screenshot layouts unless the content model calls for them}
- Typography and controls: {status and note; avoid oversized hero type, all-centered utility layouts, dramatic type contrast, oversized pill CTAs, gradient/glowing buttons, icon-stuffed controls, and competing loud actions}
- Copy and content: {status and note; avoid vague SaaS/AI phrases, filler subtitles, fake testimonials, generic names, perfect fake metrics, and lorem ipsum; prefer concrete product-specific copy and realistic marked demo data}
- Media, icons, and decoration: {status and note; avoid stock imagery, fake avatars, abstract people illustrations, decorative laptop mockups, floating icons, 3D blobs, emoji filler, and icon clutter}
- Motion and states: {status and note; use motion for cause/effect, state changes, loading, or spatial relationships; avoid decorative transitions, excessive shimmer, confetti for ordinary actions, cute filler empty states, and vague errors}
- Minimalism guardrails: {status and note; preserve hierarchy, affordances, contrast, labels, visible focus, target size, state text, and product character; avoid sterile template minimalism and hidden/icon-only controls}
- Responsive realism: {status and note; avoid fragile wide grids, hover-dependent controls, dense horizontal toolbars, tiny touch targets, and mobile views that degrade into endless repeated cards}
- Exceptions and rationale: {status and note; if using a normally flagged treatment, state the explicit user request, UX.md/design-token source, consistent existing pattern, or functional/art-direction reason inline}

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
- [ ] Intentional visual restraint check completed and issues resolved or justified
- [ ] Reusable UX.md updates captured
- [ ] Open decisions resolved
- [ ] Implementation prompt included

## Implementation prompt

Copy this into a fresh agent:

```md
Implement this plan: docs/ux/{flow-or-page-slug}.md

Follow the plan exactly enough to preserve its intent. Also follow repository `UX.md`, relevant `docs/ux/*`, existing design-system tokens and component patterns, the Visual consistency check, and the Intentional visual restraint check.

Do not re-grill unless the plan has a blocking contradiction or missing decision. If blocked, ask one focused question. Otherwise implement, verify, and report checks run plus any concrete gaps.
```
~~~

## Rules

- **Specific to one flow/page.** Do not duplicate global patterns unless they are directly applied here.
- **Implementation-ready.** A builder should know the screen sequence, data, actions, and state behavior without re-running the whole conversation.
- **Use ASCII for structure, not pixel perfection.** Show hierarchy, regions, actions, and state changes.
- **Mark assumptions.** If codebase exploration did not confirm a data source or route, label it as an assumption or open decision.
- **Include the exact implementation trigger.** The implementation prompt must start with `Implement this plan: <markdown-path>`. A markdown path alone is only for plan review/handoff and must not start coding.
