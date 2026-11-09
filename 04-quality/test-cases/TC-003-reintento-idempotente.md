# Test Case — TC-003 · Reintentar el envío no crea una segunda cita

> Copia de [`_template-test-case.md`](../_template-test-case.md). Prueba automatizada: sonda
> `POST /appointments mismo clientRequestId` del smoke test.

- **ID:** TC-003
- **Related story:** HU-004 agendar la cita ([booking](../../01-architecture/features/booking.md))
- **Feature / screen:** booking · [Agendar cita](../../01-architecture/screens/agendar-cita.md)
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** con datos móviles, la respuesta del servidor se puede perder aunque la cita
sí se haya creado. Si la app reintenta, la clienta no puede terminar con dos citas.

---

## Preconditions

- Un servicio con un cupo libre y una clienta con sesión iniciada.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Agendar con un `clientRequestId` nuevo | 201 con el `id` de la cita |
| 2 | Repetir **exactamente** la misma petición, con el mismo `clientRequestId` | 201 con **el mismo `id`** del paso 1 |
| 3 | Consultar `GET /v1/appointments/mine?scope=upcoming` | Una sola cita para ese cupo |
| 4 | En la app, activar el modo avión justo después de tocar "Confirmar", desactivarlo y reintentar | Se ve una sola cita en "Mis citas" |

> Hueco conocido: si se reutiliza el `clientRequestId` con un cuerpo **distinto**, la API devuelve la
> cita original en vez de un 409 (H-06 de [`api-contract.md`](../../03-api-and-data/api-contract.md)).
> No es parte de este caso.

---

## Result

- **Status:** 🟡 API ✅ (pasos 1 a 3); paso 4 de la app sin ejecutar
- **Build:** API `1116727` (`dev` más los PR #7 y #9 a #13), en Docker con PostgreSQL 16
- **Device / OS:** Windows 11 con Docker Desktop 28.3.2. Sin dispositivo ni emulador Android
- **Notes / defects:** Pasos de API ejecutados el 2026-11-08 con [`ejecutar-pasos-api.ps1`](./ejecutar-pasos-api.ps1). El paso 4 (modo avión) lo cubre `BookAppointmentScreen_retryAfterTimeout_resendsTheSameKey` (Vitest); falta en un celular. Sin defectos encontrados.
