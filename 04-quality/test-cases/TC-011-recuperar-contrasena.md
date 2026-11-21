# Test Case — TC-011 · Recuperar la contraseña con un código sin delatar cuentas

> Copia de [`_template-test-case.md`](../_template-test-case.md). Agregado el 2026-11-16. Pruebas
> automatizadas: las 5 sondas de `POST /auth/password/forgot` y `POST /auth/password/reset` del smoke
> test, `passwordReset.service.test.js` (12 pruebas de la API) y, en la app, `passwordReset.test.ts` y
> `ForgotPasswordScreen.test.tsx`.

- **ID:** TC-011
- **Related story:** recuperar la contraseña, HU-23 en el código de la app ([auth](../../01-architecture/features/auth.md))
- **Feature / screen:** auth · [Login](../../01-architecture/screens/login.md) y [Recuperar contraseña](../../01-architecture/screens/recuperar-clave.md)
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** quien olvidó la contraseña la cambia sola con un código que solo llega a su
correo, sin que el endpoint sirva para averiguar qué correos tienen cuenta y sin que una sesión
abierta en otro celular siga renovándose con la contraseña vieja.

---

## Preconditions

- Sistema levantado con `beauty-salon-infra`, con Mailpit en `http://localhost:8025`.
- Una clienta registrada, con su sesión abierta (tiene `refreshToken`).

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Pedir el código con el correo de la clienta (`POST /v1/auth/password/forgot`) | 202 "Si el correo tiene una cuenta, le enviamos un código." |
| 2 | Pedir el código con un correo que no tiene cuenta | **El mismo** 202 con el mismo mensaje |
| 3 | Abrir Mailpit | Llegó un correo "Tu código de ManiCita: NNNNNN" con 6 números, que vence en 15 minutos |
| 4 | Cambiar la contraseña con un código errado (`POST /v1/auth/password/reset`) | 400 `INVALID_RESET_CODE` |
| 5 | Cambiar la contraseña con el código correcto | 204 |
| 6 | Entrar con la contraseña vieja y con la nueva | Vieja: 401 `INVALID_CREDENTIALS`. Nueva: 200 |
| 7 | Refrescar con el `refreshToken` que tenía antes del cambio | 401 `INVALID_REFRESH_TOKEN`: se cerraron las sesiones |
| 8 | Repetir el paso 5 con el mismo código | 400 `INVALID_RESET_CODE`: el código sirve una vez |
| 9 | En la app: en Login escribir el correo, tocar "¿Olvidaste tu contraseña?", pedir el código, escribirlo con la contraseña nueva dos veces y tocar **Cambiar contraseña** | La pantalla llega con el correo escrito; **Reenviar código** espera 60 s; al terminar vuelve a Login con el correo lleno y el aviso "Listo, cambiaste tu contraseña. Entra con la nueva." |

---

## Result

- **Status:** ⏳ Pasos 1 a 8 ✅ pasaron; paso 9 **pendiente de ejecutar en dispositivo**
- **Build:** API `0452218` (rama `fix/servicios-y-clave`) e infra `114d4e7` (misma rama, con Mailpit `v1.21.8`), en Docker con PostgreSQL 16
- **Device / OS:** Windows 11 con Docker Desktop (Docker 29.9.3)
- **Notes / defects:** Pasos de API: [`ejecutar-pasos-api.ps1`](./ejecutar-pasos-api.ps1) el 2026-11-16, que lee el código del asunto del correo en la API de Mailpit. El paso 9 lo cubre por ahora `ForgotPasswordScreen.test.tsx` (Vitest). Observación: el cierre de sesiones compara segundos enteros (`iat` del token contra `password_changed_at`), así que un `refreshToken` emitido **en el mismo segundo** del cambio sigue sirviendo; el script espera un segundo después del registro. En uso real no pasa (entre iniciar sesión y cambiar la contraseña hay que leer el correo), pero queda anotado.
