# Observability

## Crash reporting

- Integrate crash reporting from day one.
- Track **crash-free users** and **crash-free sessions**; target ≥ 99.5%.
- Symbolicate/deobfuscate builds so stack traces are readable.
- A crash-free drop below threshold is a rollback trigger.

## Analytics

- Capture key funnel events (activation, core action, conversion) — not everything.
- Define events with names and properties up front; avoid free-form event spam.
- Respect consent and privacy: no PII in analytics payloads.

## Feature flags

- Gate risky features behind flags so they can be disabled **without a new release**.
- Every flag has an owner and a removal date; remove stale flags.
- Default a new flag to **off** in production until validated.

## Health signals to watch per release

| Signal | Target |
|--------|--------|
| Crash-free sessions | ≥ 99.5% |
| ANR rate (Android) | Below platform threshold |
| Key funnel completion | No regression vs. previous release |
| API error rate (client-observed) | Stable |
