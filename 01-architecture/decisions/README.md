# ADRs — Architecture Decision Records

ADRs document important architectural decisions. Each file = one decision.

## How to create an ADR

1. Copy `_template-adr.md`.
2. Name it `records/ADR-NNN-short-title.md` (e.g. `ADR-002-state-management.md`).
3. Fill it in completely — especially the evaluated alternatives.
4. Once accepted, the status is **permanent** (it is not deleted; it is "Superseded" by another ADR).

## Possible statuses

- `Proposed` — under discussion
- `Accepted` — approved by the team
- `Rejected` — evaluated and discarded (document why)
- `Superseded` — replaced by ADR-NNN (indicate which)

## ADR register

| # | Title | Status | Date |
|---|-------|--------|------|
| [ADR-001](./records/ADR-001-state-management-pattern.md) | State management pattern | Accepted | 2026-08-28 |

> Add a row here as you create ADRs in `records/`.
