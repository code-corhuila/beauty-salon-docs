# Offline & Sync

## Per-feature strategy

Decide and document the strategy for each feature:

| Strategy | When to use |
|----------|-------------|
| Online-only | Data must be fresh; offline use is not required |
| Read-through cache | Read offline, write online |
| Offline-first | Full read/write offline, sync on reconnect |

## Offline-first rules

- Queue local mutations while offline; assign each a client-generated id.
- Reconcile on reconnect with an explicit **conflict policy**:
  - `last-write-wins`, `server-wins`, or a domain-specific merge — pick one per entity.
- Make sync **idempotent**: replaying a queued mutation must not double-apply.
- Surface sync/staleness state in the UI when data may be out of date.

## Connectivity

- Treat connectivity as a stream, not a one-time check.
- Retry queued work with backoff; cap attempts and expose a manual "retry" action.

## Checklist

- [ ] Strategy documented per feature.
- [ ] Conflict policy defined per synced entity.
- [ ] Sync is idempotent.
- [ ] UI shows offline / syncing / stale states.
