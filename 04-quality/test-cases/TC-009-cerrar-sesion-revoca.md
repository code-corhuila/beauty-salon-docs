# Test Case — TC-009 · Cerrar sesión invalida el token y limpia el dispositivo

> Copia de [`_template-test-case.md`](../_template-test-case.md). Pruebas automatizadas: sondas
> `POST /auth/refresh` y `POST /auth/logout` del smoke test. El paso 6 se ejecuta cuando exista el
> cierre de sesión en la app (HU-12 del tablero).

- **ID:** TC-009
- **Related story:** HU-007 registro e inicio de sesión ([auth](../../01-architecture/features/auth.md))
- **Feature / screen:** auth
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** si una clienta presta el celular o lo pierde, cerrar sesión debe dejar el
token inservible y no dejar su historial de citas en el dispositivo.

---

## Preconditions

- Una clienta con sesión iniciada (tiene `accessToken` y `refreshToken`).

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Refrescar la sesión (`POST /v1/auth/refresh`) | 200 con un `refreshToken` **nuevo** |
| 2 | Refrescar otra vez con el `refreshToken` **viejo** | 401 `INVALID_REFRESH_TOKEN`: el refresco rota |
| 3 | Cerrar sesión con el token vigente (`POST /v1/auth/logout`) | 204 |
| 4 | Cerrar sesión otra vez con el mismo token | 204: cerrar sesión es idempotente |
| 5 | Refrescar con el token del paso 3 | 401 `INVALID_REFRESH_TOKEN` |
| 6 | En la app, cerrar sesión e inspeccionar el dispositivo con `chrome://inspect` | No quedan tokens en el almacenamiento seguro ni citas en SQLite |

---

## Result

- **Status:** Pendiente de ejecución manual
- **Build:** —
- **Device / OS:** —
- **Notes / defects:** —
