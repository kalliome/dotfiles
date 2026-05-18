# UX.md Format

Root `UX.md` is durable project-wide UX memory. It should capture reusable UX patterns that future screens should follow, not one-off screen specs.

## Structure

~~~md
# UX

Reusable UX/UI patterns for this project. Use this file to keep future flows, pages, and components consistent.

## Product UX principles

### {Principle name}

{Short rule and rationale.}

Use when:
- {Situation where this principle applies}

Avoid:
- {Common conflicting choice to avoid}

### Intentional visual restraint

Default to restrained, purposeful, product-specific UI. Avoid generic AI/SaaS visual tropes unless the user explicitly asks for them, `UX.md` or design-system tokens require them, a clearly consistent existing pattern uses them, or the UI purpose genuinely depends on them.

Use when:
- Defining page layouts, components, dashboards, forms, empty states, marketing/editorial surfaces, and visual handoff specs.
- Interpreting vague style requests like "modern," "polished," "premium," "sleek," or "delightful"; treat them as requests for hierarchy, spacing, alignment, typography, clarity, and consistency, not automatic permission for decorative effects.

Prefer:
- Spacing, alignment, typography, subtle borders, separators, semantic color, realistic product data, clear labels, visible affordances, and tokenized visual choices.

Avoid:
- Unexplained gradients, aurora/glow/glass effects, prominent shadows, unnecessary cardification, large radius or pill shapes, generic bento/hero/3-card SaaS layouts, decorative dashboards, stock imagery, fake avatars, 3D blobs, emoji filler, vague SaaS copy, fake-perfect metrics, decorative motion, hidden controls, and sterile low-affordance minimalism.

Exceptions:
- Record the rationale inline: the user request, token/design-system source, consistent existing pattern, or functional/art-direction reason that makes the expressive treatment better than a flatter restrained alternative.

## Navigation patterns

### {Pattern name}

{Reusable navigation rule.}

## Page layouts

### {Layout pattern name}

{When to use this page shape and why.}

```txt
┌─────────────────────┐
│ Example layout      │
└─────────────────────┘
```

## Forms & validation

### {Pattern name}

{Reusable form behavior, validation timing, error placement, and recovery rule.}

## Empty, loading, and error states

### {Pattern name}

{Reusable state pattern and tone.}

## Data display

### {Pattern name}

{Reusable table/card/detail/list rule, including action placement where relevant.}

## Component conventions

### {Component or convention name}

{Reusable usage rule, variants, and avoidances.}

## Copy and tone

### {Pattern name}

{Decision-critical copy rule: labels, CTAs, helper text, errors, empty states.}

## Accessibility

### {Pattern name}

{Reusable accessibility rule for relevant flows/components.}

## Open questions

- {Only questions that block consistency or implementation}
~~~

## Rules

- **Reusable only.** Add patterns expected to apply to multiple screens or flows. Put one-off flow details in `docs/ux/*.md`.
- **Be concrete.** Include “Use when” and “Avoid” when they clarify boundaries.
- **Include examples when visual.** Add tiny ASCII snippets for layout/component patterns where structure matters.
- **Capture rationale briefly.** Explain why the pattern exists in one or two sentences.
- **Resolve conflicts explicitly.** If a new decision changes an old pattern, update the pattern and note the resolution.
- **Keep open questions sparse.** Only include unresolved items that block consistency or implementation.
- **Avoid implementation details unless they constrain UX.** Component names/design tokens are allowed when they are the project’s actual UX vocabulary; low-level code details do not belong.
