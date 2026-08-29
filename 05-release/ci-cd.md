# CI/CD

## Principles

- Reproducible builds **from CI only** — no store uploads from a developer laptop.
- Separate build flavors/schemes per environment: `dev`, `staging`, `prod`.
- All environment values (base URL, keys, flags) injected at build time — never hardcoded.

## Pipeline stages

1. **Lint + static analysis** — fails on warnings.
2. **Unit + widget tests** — must pass.
3. **Build signed artifacts** — `.aab`/`.apk` (Android), `.ipa` (iOS).
4. **Distribute to internal testers** — Firebase App Distribution / TestFlight.
5. **Pre-release checks** — startup time + app size captured and compared.
6. **Promote to store review** — after sign-off (see `_template-release-checklist.md`).

## Triggers

- PRs run stages 1–2.
- Merges to `main` run stages 1–4 to internal testers.
- A `vX.Y.Z` tag runs the full pipeline and creates the GitHub release
  (`.github/workflows/release.yml`).

## Environments

| Flavor | Backend | Distribution |
|--------|---------|--------------|
| dev | dev API | debug installs |
| staging | staging API | internal testers |
| prod | prod API | store |
