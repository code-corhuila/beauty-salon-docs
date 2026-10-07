# Test Case — TC-002 · Un cupo no se agenda dos veces

> Copia de [`_template-test-case.md`](../_template-test-case.md). Prueba automatizada: sonda
> `POST /appointments cupo tomado` del smoke test. La garantía la da el índice único parcial de la
> tabla `appointment` en PostgreSQL, no una verificación previa en el código.

- **ID:** TC-002
- **Related story:** HU-004 agendar la cita sobre un cupo real ([booking](../../01-architecture/features/booking.md))
- **Feature / screen:** booking · [Agendar cita](../../01-architecture/screens/agendar-cita.md)
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** dos clientas no pueden quedar citadas a la misma hora con la misma
profesional. Es la regla que justifica que la app exista.

---

## Preconditions

- Un servicio publicado con al menos un cupo libre en una fecha futura (ver TC-001).
- Dos cuentas de clienta, A y B, con sesión iniciada.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | La clienta A agenda el cupo (`POST /v1/appointments` con `serviceId`, `slotId` y un `clientRequestId` nuevo) | 201, cita en estado `pending` |
| 2 | La clienta B intenta agendar **el mismo cupo** con otro `clientRequestId` | 409 `SLOT_TAKEN` |
| 3 | En la app, con la clienta B en la pantalla de agendar, tomar el cupo desde otra sesión y luego confirmar | La pantalla muestra el aviso de cupo tomado y **recarga los cupos sola**; no queda ninguna cita creada |
| 4 | Agendar un cupo que no existe (`slt_20000101_0900`) | 422 `VALIDATION_FAILED`, no 409: "nunca existió" no es lo mismo que "se lo llevaron" |
| 5 | El negocio rechaza la cita de A y B vuelve a intentar el cupo | 201: el cupo de una cita rechazada o cancelada se libera |

---

## Result

- **Status:** Pendiente de ejecución manual
- **Build:** —
- **Device / OS:** —
- **Notes / defects:** —
