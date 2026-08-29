# Persistence (Local Database)

## Choice

- Choose **one** local store per app (SQLite/Room/Drift, Realm, or a key-value store) and
  wrap it behind a repository interface. Record the choice in an ADR.
- Keep persisted models **separate** from domain entities; map between them.

## Naming

- Tables/collections: `snake_case`, plural — `orders`, `order_items`.
- Primary key: `id`.
- Foreign keys: `<entity_singular>_id` — `order_id`.
- Timestamps on mutable records: `created_at`, `updated_at`.
- Booleans: prefix `is_` / `has_`.

## Rules

- Store only what the app needs offline — do not mirror the entire backend.
- All DB access goes through the data layer; screens never touch the DB.
- Wrap multi-step writes in a transaction.
- Define each entity with [`_template-entity.md`](./_template-entity.md).

## Migrations

- Every schema change ships a **versioned, forward-only** migration — never mutate an existing one.
- Bump the local schema version on every structural change.
- Test migrations against a **populated** database, not an empty one.
