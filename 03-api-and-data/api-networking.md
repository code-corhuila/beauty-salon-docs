# API / Networking

## Client

- **One** configured HTTP client in `core/network/` — base URL, timeouts, and interceptors
  defined once. No ad hoc clients per feature.
- Set **timeouts** on every request (connect + read). No unbounded calls.

## Requests & retries

- **Retries** only on idempotent requests (GET), with exponential backoff and a max cap.
- Never auto-retry a non-idempotent request (POST/PATCH) — surface the error to the user.
- Attach correlation/request IDs via an interceptor for traceability.

## Serialization

- Serialize/deserialize through **DTOs**; map DTO → domain entity in the data layer.
- The UI never sees a raw API payload.
- Fail loudly on unexpected/malformed payloads — map to a domain error, do not guess.

## Status handling

| Range | Meaning | App behavior |
|-------|---------|--------------|
| 2xx | Success | Map to domain model |
| 401 | Unauthenticated | Trigger token refresh; on failure, sign out |
| 4xx | Client/validation error | Map to a domain error, show actionable message |
| 5xx / timeout | Transient | Backoff + retry (idempotent), then surface error |

## Logging

- Never log tokens, credentials, or full auth headers.
- Redact PII in request/response logs.
