# Test Case — TC-001 · Los cupos se calculan del horario y la duración

> Copia de [`_template-test-case.md`](../_template-test-case.md). La prueba automatizada que cubre la
> misma regla es la sonda `GET /services/{id}/availability` de `beauty-salon-api/scripts/smoke-test.ps1`.

- **ID:** TC-001
- **Related story:** HU-002 definir el horario · HU-004 agendar la cita ([booking](../../01-architecture/features/booking.md))
- **Feature / screen:** booking · [Agendar cita](../../01-architecture/screens/agendar-cita.md)
- **Platform(s):** Android (app) y API. Mientras la pantalla no exista, se ejecuta contra la API con Postman
- **Type:** Functional

**Regla que protege:** los cupos no se crean a mano: salen del horario de la profesional dividido
por la duración del servicio. Si esto falla, la manicurista tiene que cargar cupos todos los días y
deja de usar la app.

---

## Preconditions

- La API está levantada con `beauty-salon-infra` (`docker compose up -d`).
- Existe una cuenta de negocio con su profesional (el registro la crea).
- Se conoce una fecha futura y su día de la semana ISO (1 = lunes).

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Con la sesión del negocio, publicar un servicio de **60 min** con horario de **09:00 a 12:00** ese día de la semana (`POST /v1/business/services`) | 201 con el `id` del servicio |
| 2 | Sin sesión, consultar `GET /v1/services/{id}/availability?date=<fecha>` | 200 con **3 cupos**: `slt_<fecha>_0900`, `_1000` y `_1100` |
| 3 | Consultar la disponibilidad de una fecha cuyo día **no** tiene horario | 200 con la lista de cupos vacía |
| 4 | Consultar sin el parámetro `date` | 422 `VALIDATION_FAILED` con el error en el campo `date` |
| 5 | Agendar el cupo de las 10:00 con una clienta y volver a consultar la misma fecha | 200 con **2 cupos**: el de las 10:00 ya no aparece |

---

## Result

- **Status:** Pendiente de ejecución manual
- **Build:** —
- **Device / OS:** —
- **Notes / defects:** —
