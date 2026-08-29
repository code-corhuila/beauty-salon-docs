# Project Structure

Organize by **feature**, not by technical type. Each feature owns its layers.

```
lib|src/
├── core/                 Shared across features
│   ├── di/               Dependency injection / composition root
│   ├── network/          HTTP client, interceptors
│   ├── storage/          Local DB / secure storage wrappers
│   └── theme/            Design tokens, typography
├── features/
│   └── <feature>/
│       ├── presentation/ Screens, widgets/views, state holders
│       ├── domain/       Entities, use cases, repository interfaces
│       └── data/         Repository impls, data sources, DTOs, mappers
├── shared/               Reusable UI components used by many features
└── app.<ext>             Root app + routing table
```

## Rules

- One feature = one folder under `features/`. No cross-feature imports; share through
  `core/` or `shared/`.
- A file declares one primary type; the filename matches it.
- `shared/` holds only presentation-agnostic, reusable UI. Business logic never lives there.
- No feature reaches into another feature's `data/` or `domain/`.

## Naming

| Thing | Convention | Example |
|-------|------------|---------|
| Feature folder | `kebab-case` | `order-history/` |
| Type | `PascalCase` | `OrderRepository` |
| File | matches type | `order_repository.*` |
