# Performance Budgets

Set budgets, measure them, and treat a regression as a bug that blocks release.

## Budgets (guidelines — tune per app)

| Metric | Budget |
|--------|--------|
| Cold start to first frame | ≤ 2 s |
| Frame rendering | 60 fps, no jank on scroll |
| App install size | Tracked; every increase justified |
| Memory on core flows | No leaks; stable under navigation churn |
| Network payload (list screens) | Paginated; first page small |

## Rules

- **Measure before optimizing** — profile with the platform tools; do not guess.
- Lazy-load heavy screens and images; paginate long lists.
- Avoid rebuilding large UI subtrees; render from immutable state.
- Track app size per release; a large jump requires review.

## In CI / release

- Capture startup time and app size in the pre-release job.
- Compare against the previous release; flag regressions in the release checklist.
