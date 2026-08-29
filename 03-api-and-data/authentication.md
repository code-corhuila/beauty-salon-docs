# Authentication

## Token storage

- Store access and refresh tokens **only** in platform secure storage (Keychain / Keystore).
- Never store tokens in plain preferences, local files, or unencrypted databases.

## Attaching tokens

- Attach the access token via a **single interceptor**, not per call.
- Keep auth logic out of individual repositories and screens.

## Refresh

- Refresh an expired access token **transparently** on a 401, then retry the original request once.
- Serialize concurrent refreshes so only one refresh runs at a time.
- On refresh failure (expired/invalid refresh token), sign the user out cleanly and route to login.

## Sign-out

- Clear all tokens and sensitive cached data on sign-out.
- Cancel in-flight authenticated requests.

## Rules

- Never log tokens or credentials.
- Do not embed long-lived secrets in the app; the client holds user tokens only.
- Treat biometric unlock as a gate to stored tokens, not as a replacement for them.
