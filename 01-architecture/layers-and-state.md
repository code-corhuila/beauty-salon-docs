# Layers & State

## Layers

| Layer | Responsibility | Allowed Dependencies |
|-------|----------------|----------------------|
| Presentation | Render UI, hold view state, dispatch intents | Domain |
| Domain | Use cases, entities, repository interfaces | None |
| Data | Repository impls, remote/local sources, mapping | Domain |

## Dependency Direction

```
Presentation  ─▶  Domain  ◀─  Data
```

- Domain has **zero** outward dependencies — no HTTP, no database, no framework imports.
- Presentation never imports a data source directly; it goes through a use case or a
  repository interface.
- Data depends on Domain (implements its interfaces), never the reverse.

## State Management

- Pick **one** unidirectional pattern for the whole app and record it in an ADR:
  - **MVVM** — ViewModel exposes an observable, immutable state object.
  - **MVI** — intent → reducer → state.
  - **Store** (Bloc / Redux-style) — events dispatched to a single store.
- Do **not** mix patterns across features.
- View state is **immutable**; a screen renders exactly one state object.
- No business logic inside widgets/views — delegate to the state holder / use case.

## Use Cases

- One use case = one business action (`PlaceOrder`, `RefreshProfile`).
- Use cases are pure and independently testable; they orchestrate repositories.
- Keep them thin — no UI concerns, no framework types.
