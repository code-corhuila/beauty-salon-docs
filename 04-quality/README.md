# 04 — Quality

> **What is this?** How the app is tested, how fast and lean it must be, and how it is kept
> secure at runtime.

## Why this section exists

Quality is defined and measured, not hoped for. This section turns "it works on my device"
into explicit, enforceable gates: tests, performance budgets, and a security checklist.

---

## Documents in this section

| File | Purpose |
|------|---------|
| [testing-strategy.md](./testing-strategy.md) | Test pyramid, naming, coverage targets |
| [performance-budgets.md](./performance-budgets.md) | Startup, frame rate, size, memory budgets |
| [mobile-security.md](./mobile-security.md) | Runtime security checklist |
| [_template-test-case.md](./_template-test-case.md) | Template to write a manual/exploratory test case |

---

## Correlations with other sections

| This section depends on... | Why |
|----------------------------|-----|
| `00-governance/definition-of-done.md` | Tests are part of Done |
| `01-architecture/` | Layers define unit vs. UI test boundaries |
| `03-api-and-data/` | Networking/persistence need integration tests |

---

## Questions this section must answer

- What is tested, at which level, and how much?
- What are the performance budgets, and how are regressions caught?
- What security checks run before a release?
