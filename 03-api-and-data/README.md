# 03 — API & Data

> **What is this?** The rules for how the app talks to backends (API) and how it stores and
> syncs state locally (data).

## Why this section exists

Networking and persistence are where most mobile bugs and security issues live: token
handling, retries, offline behavior, and schema migrations. Decide the rules once and apply
them in every feature's data layer.

---

## Documents in this section

| File | Purpose |
|------|---------|
| [api-networking.md](./api-networking.md) | HTTP client, timeouts, retries, error mapping |
| [authentication.md](./authentication.md) | Token storage, refresh, sign-out |
| [persistence.md](./persistence.md) | Local database rules and naming |
| [offline-sync.md](./offline-sync.md) | Offline strategy and conflict resolution |
| [_template-endpoint-integration.md](./_template-endpoint-integration.md) | Template to document consuming one endpoint |
| [_template-entity.md](./_template-entity.md) | Template to define a local persistence entity |

---

## Correlations with other sections

| This section feeds... | Why |
|-----------------------|-----|
| `01-architecture/` | Implements repository interfaces from the domain layer |
| `00-governance/security-rules.md` | Token/transport rules are governed there |
| `04-quality/` | Networking and persistence need integration tests |

---

## Questions this section must answer

- How does the app make and retry requests?
- Where are tokens stored and how are they refreshed?
- What is stored locally, and how are schema changes migrated?
- What happens when the device is offline?
