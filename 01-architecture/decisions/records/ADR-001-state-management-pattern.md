# ADR-001 — State management pattern

> Example ADR shipped with the framework. Replace it with your own decision, or supersede it.

- **ID:** ADR-001
- **Date:** 2026-08-28
- **Status:** Accepted
- **Authors:** [team]

---

## Context

The app needs a single, consistent way to manage UI state across features. Without a
decided pattern, each developer picks their own, producing inconsistent, hard-to-test
screens and mixed mental models during review.

**Known constraints:**
- Team is small; the pattern must be simple to learn.
- State must be testable without rendering UI.
- The app targets both platforms from one codebase (stack-agnostic).

---

## Decision

**We decided:** adopt a single **unidirectional, immutable-state** pattern (MVVM-style
state holder exposing one immutable state object per screen) for the whole app.

**Justification:**
Unidirectional flow with immutable state makes transitions explicit and screens trivial to
unit-test. Choosing one pattern app-wide removes per-feature debate and keeps reviews fast.

---

## Evaluated alternatives

| Alternative | Pros | Cons | Reason for discarding |
|-------------|------|------|-----------------------|
| MVVM + immutable state (chosen) | Simple, testable, framework-agnostic | Some boilerplate | — (chosen) |
| MVI (intent/reducer) | Very explicit, great for complex flows | Heavier for simple screens | Overkill for current scope |
| Mutable state in views | Fast to write | Untestable, inconsistent | Rejected — violates layering |

---

## Consequences

**Positive:**
- Consistent, testable screens.
- Faster onboarding and review.

**Negative / Trade-offs:**
- Some boilerplate per screen.

**Impact on the system:**
- Affected features/screens: all.
- Documents to update: [`../../layers-and-state.md`](../../layers-and-state.md).

---

## References

- Related to: [`../../layers-and-state.md`](../../layers-and-state.md)
