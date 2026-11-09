# Test Case — TC-005 · Pausar no es borrar

> Copia de [`_template-test-case.md`](../_template-test-case.md). Pruebas automatizadas: sondas
> `PATCH /business/services/{id}/status` y `GET /services/{id} pausado` del smoke test.

- **ID:** TC-005
- **Related story:** HU-001 publicar el servicio ([business](../../01-architecture/features/business.md))
- **Feature / screen:** business · [Mis servicios](../../01-architecture/screens/negocio-servicios.md) y catalog · [Catálogo](../../01-architecture/screens/catalogo.md)
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** la manicurista pausa un servicio cuando sale de vacaciones o se le acaba un
material; las clientas que ya tenían cita no pueden perderla por eso.

---

## Preconditions

- Un servicio publicado con una cita `confirmed` en una fecha futura.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Pausar el servicio (`PATCH /v1/business/services/{id}/status` con `isPublished: false`) | 200 |
| 2 | Listar el catálogo público (`GET /v1/services`) | El servicio **no aparece** |
| 3 | Abrir el detalle del servicio (`GET /v1/services/{id}`) | 410 `SERVICE_PAUSED` |
| 4 | Consultar la agenda del negocio en la fecha de la cita | La cita **sigue apareciendo**, en `confirmed` |
| 5 | Consultar "Mis citas" de la clienta | La cita sigue ahí |
| 6 | Volver a publicar el servicio | Reaparece en el catálogo con el mismo `id` |

---

## Result

- **Status:** ✅ Pasó
- **Build:** API `1116727` (`dev` más los PR #7 y #9 a #13), en Docker con PostgreSQL 16
- **Device / OS:** Windows 11 con Docker Desktop 28.3.2; emulador Android 16 (API 36, x86_64, WebView 133)
- **Notes / defects:** Pasos de API: [`ejecutar-pasos-api.ps1`](./ejecutar-pasos-api.ps1) el 2026-11-08. Pasos de app: en el emulador, manejando el WebView por DevTools Protocol (lo mismo que `chrome://inspect`) y `adb`. Paso 2: se revisó la primera página del catálogo (hasta 50 servicios). Sin defectos.
