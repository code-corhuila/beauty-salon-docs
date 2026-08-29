# Coding Standards

## Principles

- **Immutability first** — prefer immutable models and `const`/`final`/`val` over mutable state.
- **Small units** — a function does one thing; a file declares one primary type.
- **No magic values** — extract to named constants or design tokens.
- **Fail fast** — validate inputs at boundaries; never swallow errors silently.

## Naming

| Kind | Convention |
|------|------------|
| Types / classes | `PascalCase` |
| Members / variables | `camelCase` |
| Constants | `UPPER_SNAKE_CASE` |
| Files | match the primary type |
| Booleans | prefix `is` / `has` / `should` |

## Error handling

- Wrap fallible operations in a typed result (`Result` / `Either`) or well-defined exceptions.
- Map low-level errors (network, parsing) to **domain errors** before they reach the UI.
- Every user-facing failure has a message **and** a recovery action (retry, dismiss).

## Async

- Always handle the error branch of an async call.
- Cancel in-flight work when a screen/state holder is disposed.
- Never block the UI thread; move heavy work off the main thread.

## Linting

- The project ships a linter/formatter config. **CI fails on warnings.**
- Do not disable a lint rule inline without a comment explaining why.
