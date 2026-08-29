# Security Rules

Non-negotiable, code-level security rules for every mobile build.

## Secrets & credentials

- Never commit API keys, tokens, or credentials to the repository or bundle them in plain text.
- Inject build-time secrets from CI; keep signing credentials in CI secret storage.
- Store user tokens only in platform **secure storage** (Keychain / Keystore) — never in
  plain preferences, local files, or unencrypted databases.

## Transport

- All network traffic over TLS. No cleartext HTTP in release builds.
- Enable **certificate pinning** for sensitive APIs (auth, payments).

## Data at rest

- Encrypt sensitive local data. Do not cache PII you do not need.
- Clear sensitive data on logout.

## Permissions

- Request the minimum runtime permissions, just-in-time, with a clear rationale.
- Never request a permission "in case we need it later".

## Build hardening

- Obfuscate/minify release builds; strip debug logs from release.
- Disable debugging flags and verbose logging in production.

## Handling vulnerabilities

- Report suspected vulnerabilities privately to the tech lead — never in a public issue.
- Patch known-vulnerable dependencies within one sprint of disclosure.
