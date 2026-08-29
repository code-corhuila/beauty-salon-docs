# Testing Strategy

## Test Pyramid

| Type | Scope | Speed | Share |
|------|-------|-------|-------|
| Unit | Use cases, state holders, mappers — no UI, no I/O | Fast | ~70% |
| Widget / UI | A single screen/component in isolation | Medium | ~20% |
| Integration / E2E | Full flow on a simulator/emulator or device | Slow | ~10% |

## Rules

- Every use case and state holder has unit tests; mock only **direct** dependencies.
- Test **behavior and state transitions**, not implementation details.
- Keep tests deterministic: no real network, no wall-clock sleeps, fixed clock/seed.
- Arrange-Act-Assert; one logical assertion per test where possible.

## Naming

- `<unit>_<condition>_<expectedResult>`
  - Example: `login_whenTokenExpired_showsSessionError`

## Coverage

- **80% minimum** on `domain/` (use cases) and state holders.
- Coverage is a floor, not a goal — a covered line is not a tested behavior.

## CI

- Unit + widget suites run on **every PR**; the PR cannot merge if they fail.
- Integration/E2E run on a nightly and pre-release job on at least one iOS and one Android device/emulator.
