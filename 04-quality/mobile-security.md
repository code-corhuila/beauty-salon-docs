# Mobile Security (Runtime Checklist)

Complements [`00-governance/security-rules.md`](../00-governance/security-rules.md) with
checks run before each release.

## Storage

- [ ] Tokens and secrets only in secure storage (Keychain / Keystore).
- [ ] Sensitive local data encrypted; cleared on logout.
- [ ] No PII cached that the app does not need.

## Transport

- [ ] All traffic over TLS; no cleartext in release builds.
- [ ] Certificate pinning enabled for sensitive APIs (auth, payments).

## Permissions

- [ ] Only minimum runtime permissions requested, just-in-time, with rationale.
- [ ] No unused permissions declared in the manifest/plist.

## Build

- [ ] Release build obfuscated/minified; debug logs stripped.
- [ ] Debug flags and verbose logging disabled in production.
- [ ] No API keys or credentials in the bundle or repository.

## Dependencies

- [ ] Dependency vulnerability scan run; known-vulnerable packages patched.
- [ ] Third-party SDKs reviewed for what data they collect.
