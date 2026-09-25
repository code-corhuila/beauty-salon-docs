# Feature — Mis citas

- **Responsables:** Lilly Signey Puentes Rincon y Lizeth Caicedo
- **Estado:** Planned
- **Historias relacionadas:** HU-005 consultar y cancelar mis citas (Sprint 3)

---

## Propósito

Darle a la clienta un lugar donde ver sus citas —próximas y pasadas—, consultar el detalle de cada
una y cancelar si no va a poder ir. Es la feature que hace que la app se abra todos los meses y no
una sola vez.

---

## Pantallas

| Pantalla | Ruta | Propósito |
|----------|------|-----------|
| [MyAppointmentsScreen](../screens/mis-citas.md) | `/my-appointments` | Listar las citas propias, separadas en próximas y pasadas |
| [AppointmentDetailScreen](../screens/detalle-cita.md) | `/appointment/:appointmentId` | Ver el resumen completo, el estado de la cita y cancelarla |

---

## Estado

- **Patrón:** Store con Zustand ([ADR-006](../decisions/records/ADR-006-state-management-pattern.md))
- **Objetos de estado:** `MyAppointmentsState`, `AppointmentDetailState`
- **Transiciones clave:**
  - Lista: `loading` a `loaded` o `empty` o `error`.
  - Cancelación: `submitting` a `cancelled`, con confirmación previa. La cancelación es una acción
    destructiva, así que se confirma en un diálogo antes de enviarla.

---

## Estados de la cita

El estado no es un adorno: es el dato que después le dice al negocio cuánto pierde por inasistencia.

| Estado | Quién lo produce | Qué ve la clienta |
|--------|------------------|-------------------|
| `Pendiente` | Se crea al agendar | Aviso de que el negocio aún debe confirmar |
| `Confirmada` | El negocio la acepta | Cita en firme, se puede cancelar |
| `Rechazada` | El negocio la rechaza con motivo | Motivo visible y sugerencia de escoger otra hora |
| `Cancelada` | La clienta o el negocio | Queda en el historial, no se borra |
| `Completada` | Pasó la fecha y hora y la clienta asistió | Historial |
| `No asistió` | El negocio lo marca | Historial |

---

## Datos

- **Casos de uso:** `getMyAppointments`, `cancelAppointment`
- **Repositorios:** `AppointmentRepository`
- **Endpoints:** [`GET /v1/appointments/mine`](../../03-api-and-data/endpoints/appointments-list-mine.md),
  [`PATCH /v1/appointments/{id}/cancel`](../../03-api-and-data/endpoints/appointments-cancel.md)
- **Persistencia local:** tabla [`appointment`](../../03-api-and-data/entities/appointment.md), solo las citas de
  la clienta autenticada
- **Estrategia offline:** **read-through cache** para leer, **online-only** para cancelar.
  La razón es de negocio: la clienta necesita ver a qué hora es su cita justo cuando va camino al
  salón y puede no tener datos; pero una cancelación que se guarda en el celular y no llega al
  negocio es peor que no cancelar, porque la manicurista igual reserva el cupo y pierde la hora.

---

## Casos borde y estados

- [x] Loading — cargando la lista
- [x] Empty — todavía no ha agendado nada: el mensaje lleva al catálogo, no se queda en el vacío
- [x] Error / reintento — falla la carga sin caché disponible
- [x] Offline — se muestran las citas cacheadas con aviso; el botón de cancelar queda deshabilitado
      con la explicación de por qué
- [x] Permiso denegado — sin sesión no se entra; con sesión de negocio la guarda redirige a la agenda

---

## Decisiones

- [ADR-006](../decisions/records/ADR-006-state-management-pattern.md) — patrón de estado
- [ADR-007](../decisions/records/ADR-007-local-storage-capacitor.md) — qué se guarda localmente y qué no

---

## Pruebas

- **Unitarias:** `getMyAppointments` separando próximas de pasadas alrededor de la hora actual;
  `cancelAppointment` sobre una cita ajena debe fallar; cancelar una cita ya pasada debe fallar.
- **De componente:** `MyAppointmentsScreen` en sus cinco estados; que el botón de cancelar esté
  deshabilitado sin conexión y muestre el motivo.
- **Integración:** cancelar una cita y verificar que desaparece de las próximas y aparece en el
  historial como `Cancelada`.
