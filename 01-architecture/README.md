# 01 — Architecture

> **What is this?** How the app is organized: folder structure, layering, state management,
> navigation, and the record of architectural decisions.

## Why this section exists

Architecture is the set of constraints that keep the codebase consistent as it grows and as
people rotate. Decide it once, write it down, and enforce it in review.

---

## Documents in this section

| File | Purpose |
|------|---------|
| [project-structure.md](./project-structure.md) | Feature-first folder layout and module rules |
| [layers-and-state.md](./layers-and-state.md) | Presentation/Domain/Data layers + state pattern |
| [navigation.md](./navigation.md) | Routing model and navigation rules |
| [_template-feature.md](./_template-feature.md) | Template to document one feature end to end |
| [_template-screen.md](./_template-screen.md) | Template to spec a single screen |
| [decisions/](./decisions/) | Architecture Decision Records (ADRs) |

---

## How to work here

1. Read `project-structure.md` and `layers-and-state.md` and adopt them.
2. For each significant choice (state library, local DB, DI), record an ADR in `decisions/`.
3. For each feature you build, copy `_template-feature.md` and fill it in.

---

## Correlations with other sections

| This section feeds... | Why |
|-----------------------|-----|
| `02-code-and-ui/` | The layer boundaries constrain where UI and logic live |
| `03-api-and-data/` | The data layer implements networking and persistence rules |
| `04-quality/` | Layers define what is unit-tested vs. UI-tested |

---

## Questions this section must answer

- Where does a new feature's code go?
- Which layer may depend on which?
- What single state pattern does the app use?
- How do screens navigate, and how is that decision recorded?
