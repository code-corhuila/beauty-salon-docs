# Test Case — TC-004 · Una profesional no tiene dos citas que se crucen

> Copia de [`_template-test-case.md`](../_template-test-case.md). Pruebas automatizadas: sonda
> `POST /business/services mismo horario y misma profesional` del smoke test; en
> `business.agenda.test.js`, "dos servicios de la misma profesional pueden compartir horario
> (TC-004)"; y en `booking.service.test.js`, "una cita de otro servicio de la misma profesional ocupa
> los cupos que se cruzan (TC-004)" y "dos clientas al mismo tiempo en horas que se cruzan de dos
> servicios: entra una". En la app, `cambiosDeDatos.test.tsx` prueba que Mis servicios se recargue al
> guardar.
>
> **Reescrito el 2026-11-16.** Hasta esa fecha el caso se llamaba "Una profesional no tiene dos
> horarios que se pisen" y esperaba 409 `SCHEDULE_OVERLAP` al publicar un segundo servicio de la misma
> profesional en una franja que se cruzaba. Esa regla bloqueaba un uso normal (manicure y
> semipermanente con la misma manicurista, los lunes de 09:00 a 17:00) y se retiró: ahora los
> servicios **pueden compartir horario** y lo que se protege son las citas. El nombre del archivo se
> conserva para no romper los enlaces.

- **ID:** TC-004
- **Related story:** HU-002 definir el horario ([business](../../01-architecture/features/business.md)) y HU-004 agendar la cita sobre un cupo real ([booking](../../01-architecture/features/booking.md))
- **Feature / screen:** business · [Formulario de servicio](../../01-architecture/screens/negocio-servicio-form.md); booking · [Agendar cita](../../01-architecture/screens/agendar-cita.md)
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** si dos servicios de la misma profesional comparten franja, una clienta no
puede agendar uno a una hora que se cruce con una cita ya tomada del otro: la profesional no puede
atender a dos clientas a la vez.

---

## Preconditions

- Cuenta de negocio con una profesional y un servicio de 60 min publicado los lunes de 09:00 a 12:00.
- Dos cuentas de clienta.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Publicar otro servicio de **la misma profesional**, de 120 min, los lunes de 09:00 a 13:00 | 201: los dos servicios comparten horario |
| 2 | La clienta A agenda el servicio de 60 min el lunes a las 10:00 | 201 `pending` |
| 3 | Consultar la disponibilidad del servicio de 120 min ese lunes | 200: el cupo de las 09:00 sale con `isAvailable: false` (09:00–11:00 se cruza con 10:00–11:00) y el de las 11:00 libre |
| 4 | La clienta B intenta agendar el servicio de 120 min a las 09:00 | 409 `SLOT_TAKEN` |
| 5 | Publicar un servicio de **otra profesional** con el mismo horario y ver su disponibilidad | 201, y su cupo de las 09:00 libre: la cita de la otra profesional no lo ocupa |
| 6 | En la app, guardar el segundo servicio desde el formulario con las horas de la lista de 24 h, volver a Mis servicios y, como clienta, abrir Agendar cita del servicio de 120 min | El servicio se guarda sin error, aparece en Mis servicios sin recargar a mano, y el cupo de las 09:00 se ve deshabilitado |

---

## Result

- **Status:** ⏳ Pasos 1 a 5 ✅ pasaron; paso 6 **pendiente de ejecutar en dispositivo**
- **Build:** API `0452218` (rama `fix/servicios-y-clave`) e infra `114d4e7` (misma rama), en Docker con PostgreSQL 16
- **Device / OS:** Windows 11 con Docker Desktop (Docker 29.9.3)
- **Notes / defects:** Pasos de API: [`ejecutar-pasos-api.ps1`](./ejecutar-pasos-api.ps1) el 2026-11-16, todos en verde. El paso 6 lo cubre por ahora, en parte, `cambiosDeDatos.test.tsx` (Vitest); falta la ejecución manual en el emulador. La versión anterior del caso (regla de horario sin solape) pasó el 2026-11-08 con API `1116727` y app de `fix/app-http-debug`.
