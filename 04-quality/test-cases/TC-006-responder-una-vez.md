# Test Case — TC-006 · El negocio responde una cita una sola vez

> Copia de [`_template-test-case.md`](../_template-test-case.md). Prueba automatizada: sonda
> `PATCH respond ya respondida` del smoke test.

- **ID:** TC-006
- **Related story:** HU-006 agenda del negocio ([business](../../01-architecture/features/business.md))
- **Feature / screen:** business · [Agenda del negocio](../../01-architecture/screens/negocio-agenda.md)
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** una clienta que recibió "confirmada" no puede despertar con "rechazada"
porque la manicurista tocó después el botón equivocado.

---

## Preconditions

- Una cita `pending` de una clienta en un servicio del negocio.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Confirmar la cita (`PATCH /v1/business/appointments/{id}/respond` con `status: "confirmed"`) | 200, estado `confirmed` |
| 2 | Intentar rechazarla después | 409 `APPOINTMENT_ALREADY_RESPONDED` |
| 3 | Responder con un estado en español (`"confirmada"`) | 422 `VALIDATION_FAILED` |
| 4 | Responder una cita de **otro** negocio | 403 `FORBIDDEN_RESOURCE` |

---

## Result

- **Status:** ✅ Pasó (4 de 4 pasos de API)
- **Build:** API `1116727` (`dev` más los PR #7 y #9 a #13), en Docker con PostgreSQL 16
- **Device / OS:** Windows 11 con Docker Desktop 28.3.2. Sin dispositivo ni emulador Android
- **Notes / defects:** Pasos de API ejecutados el 2026-11-08 con [`ejecutar-pasos-api.ps1`](./ejecutar-pasos-api.ps1). Sin defectos encontrados.
