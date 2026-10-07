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

- **Status:** Pendiente de ejecución manual
- **Build:** —
- **Device / OS:** —
- **Notes / defects:** —
