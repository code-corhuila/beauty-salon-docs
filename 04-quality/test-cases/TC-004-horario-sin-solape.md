# Test Case — TC-004 · Una profesional no tiene dos horarios que se pisen

> Copia de [`_template-test-case.md`](../_template-test-case.md). Prueba automatizada: sonda
> `POST /business/services horario solapado` del smoke test.

- **ID:** TC-004
- **Related story:** HU-002 definir el horario ([business](../../01-architecture/features/business.md))
- **Feature / screen:** business · [Formulario de servicio](../../01-architecture/screens/negocio-servicio-form.md)
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** si dos servicios de la misma profesional comparten franja, se le podrían
agendar dos citas a la misma hora por servicios distintos.

---

## Preconditions

- Cuenta de negocio con una profesional y un servicio publicado los lunes de 09:00 a 12:00.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Publicar otro servicio de **la misma profesional** los lunes de 10:00 a 11:00 | 409 `SCHEDULE_OVERLAP`, con el día en el mensaje |
| 2 | Publicar otro servicio de la misma profesional los lunes de 12:00 a 13:00 | 201: tocarse en el borde no es solaparse |
| 3 | Publicar un servicio de **otra profesional** los lunes de 10:00 a 11:00 | 201 |
| 4 | En la app, provocar el solape desde el formulario | El error se muestra junto al horario y el formulario **conserva lo escrito** |

---

## Result

- **Status:** Pendiente de ejecución manual
- **Build:** —
- **Device / OS:** —
- **Notes / defects:** —
