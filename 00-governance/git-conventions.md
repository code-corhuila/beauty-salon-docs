# Git Conventions

## Branching

- Trunk-based development with short-lived branches off `main`.
- Branch names: `feat/<scope>`, `fix/<scope>`, `chore/<scope>`, `docs/<scope>`.
  - Example: `feat/checkout-apple-pay`, `fix/login-token-refresh`.
- A branch lives no longer than a few days. Rebase on `main` before opening the PR.

## Commits

- [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): summary`.
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `build`, `ci`.
- Imperative mood, ≤ 72 chars in the summary line.
  - Example: `feat(cart): persist cart across app restarts`

## Pull Requests

- One PR = one story or one fix. Keep it reviewable (< ~400 lines when possible).
- PR description links the story and lists what to test on device.
- CI must be green (lint + unit + widget tests) before review.
- At least one approval. **Squash-merge** into `main`.

## Releases

- App version follows [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`.
- Build number is a monotonic integer, incremented on every store upload.
- Tag releases `vX.Y.Z` on `main` — the tag triggers `.github/workflows/release.yml`.
