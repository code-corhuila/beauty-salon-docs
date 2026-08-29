# 02 — Code & UI

> **What is this?** The coding standards and the UI rules — how code is written and how the
> interface is built, styled, made accessible, and localized.

## Why this section exists

Consistency at the code and UI level is what makes a mobile app feel like one product built
by one team. These rules are enforced in review and by the linter.

---

## Documents in this section

| File | Purpose |
|------|---------|
| [coding-standards.md](./coding-standards.md) | Naming, immutability, error handling, async rules |
| [design-system.md](./design-system.md) | Tokens, components, theming |
| [accessibility.md](./accessibility.md) | WCAG-aligned mobile accessibility rules |
| [i18n.md](./i18n.md) | Localization and RTL rules |
| [_template-component.md](./_template-component.md) | Template to document a shared UI component |

---

## Correlations with other sections

| This section feeds... | Why |
|-----------------------|-----|
| `01-architecture/` | Standards apply within the layer boundaries defined there |
| `04-quality/` | Lint and accessibility rules are checked in CI |

---

## Questions this section must answer

- How is code named, structured, and error-handled?
- Where do colors, spacing, and typography come from?
- How do we guarantee the app is accessible?
- How is user-facing text localized?
