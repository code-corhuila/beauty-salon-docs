# Agile Conventions

## Cadence

| Ceremony | Frequency | Timebox | Output |
|----------|-----------|---------|--------|
| Sprint planning | Per sprint (1–2 weeks) | 1–2 h | Committed sprint backlog |
| Daily standup | Daily | ≤ 15 min | Blockers surfaced |
| Backlog refinement | Weekly | 1 h | Stories estimated and Ready |
| Sprint review | End of sprint | 1 h | Demo on a real device/build |
| Retrospective | End of sprint | 45 min | Action items with owners |

## Estimation

- Story points on a Fibonacci scale: `1, 2, 3, 5, 8, 13`.
- A story larger than `8` must be split before it enters a sprint.
- Estimate relative effort, not hours.

## Backlog hygiene

- Every story has a clear user value and acceptance criteria (see [definition-of-ready.md](./definition-of-ready.md)).
- Stories that touch UI link a design reference.
- Stories that call a backend link or stub the API contract.

## Roles (adapt to your team)

| Role | Owns |
|------|------|
| Product owner | Priorities, acceptance |
| Tech lead | Architecture, ADRs, DoD enforcement |
| Mobile devs | Implementation, tests, docs |
| QA | Test plan, exploratory testing on devices |
