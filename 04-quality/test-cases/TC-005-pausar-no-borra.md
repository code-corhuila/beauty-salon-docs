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

- **Status:** Pendiente de ejecución manual
- **Build:** —
- **Device / OS:** —
- **Notes / defects:** —
