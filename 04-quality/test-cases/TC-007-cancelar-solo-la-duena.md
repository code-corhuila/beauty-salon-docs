# Test Case — TC-007 · Solo la dueña cancela su cita, y una sola vez

> Copia de [`_template-test-case.md`](../_template-test-case.md). Pruebas automatizadas: sondas
> `PATCH /appointments/{id}/cancel` (de otra clienta, inexistente y repetido) del smoke test.

- **ID:** TC-007
- **Related story:** HU-005 consultar y cancelar mis citas ([appointments](../../01-architecture/features/appointments.md))
- **Feature / screen:** appointments · [Detalle de la cita](../../01-architecture/screens/detalle-cita.md)
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** nadie más que la clienta puede liberar su cupo, y una cita cancelada queda
en el historial en vez de borrarse.

---

## Preconditions

- La clienta A tiene una cita `confirmed`; la clienta B tiene sesión iniciada.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | La clienta B intenta cancelar la cita de A | 403 `FORBIDDEN_RESOURCE` |
| 2 | La clienta A cancela su cita | 200, estado `cancelled` |
| 3 | La clienta A intenta cancelarla otra vez | 409 `APPOINTMENT_NOT_CANCELLABLE` |
| 4 | Cancelar una cita que no existe (`apt_nope`) | 404 `APPOINTMENT_NOT_FOUND` |
| 5 | Consultar "Mis citas" | La cita sigue en el historial como cancelada; no desaparece |
| 6 | En la app, cancelar sin conexión | La app avisa que no se puede cancelar sin conexión y **no** guarda la cancelación para enviarla después |

---

## Result

- **Status:** 🟡 Pasó con observación
- **Build:** API `1116727` (`dev` más los PR #7 y #9 a #13), en Docker con PostgreSQL 16; app `debug` de `fix/app-http-debug` (PR app #26), contra la API local
- **Device / OS:** Windows 11 con Docker Desktop 28.3.2; emulador Android 16 (API 36, x86_64, WebView 133)
- **Notes / defects:** Pasos de API: [`ejecutar-pasos-api.ps1`](./ejecutar-pasos-api.ps1) el 2026-11-08. Pasos de app: en el emulador, manejando el WebView por DevTools Protocol (lo mismo que `chrome://inspect`) y `adb`. Paso 6: con modo avión, la app **no** guardó la cancelación: al confirmar avisó "No pudimos cancelar tu cita. Revisa tu conexión y reintenta: la cita no cambió." y 15 s después de reconectar la cita seguía `pending`. Pero el botón Cancelar no se deshabilitó antes de intentar. **Defecto D-A:** en Android el WebView no actualiza `navigator.onLine` (sigue en `true` con modo avión: Android reporta `Active default network: none`), así que `useIsOnline` nunca avisa "sin conexión" antes de intentar. Afecta a todos los avisos previos de la app en un celular. Propuesta: usar `@capacitor/network`. Sin corregir.
