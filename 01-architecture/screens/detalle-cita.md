# Pantalla — AppointmentDetailScreen

- **Ruta:** `/appointment/:appointmentId`
- **Feature:** [Mis citas](../features/appointments.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 3 queda como apoyo, no como referencia principal.

---

## Propósito

Mostrar el resumen completo de una cita y permitir cancelarla. Es la pantalla que se abre justo
después de agendar, así que también funciona como comprobante.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | [DistintivoEstadoCita](../../02-code-and-ui/components/distintivo-estado-cita.md) en tamaño `md` | Texto e ícono: Pendiente, Confirmada, Rechazada, Cancelada, Completada, No asistió |
| Cuerpo | Bloques de resumen | Servicio, precio, duración, profesional, fecha y hora, salón y dirección. Si fue rechazada, el motivo |
| Pie | [BotonSecundario](../../02-code-and-ui/components/boton-secundario.md) con `isDestructive` | Cancelar cita. Solo si está Pendiente o Confirmada y aún no pasó |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cargando el detalle | Esqueleto del resumen |
| Loaded | Detalle disponible | Contenido completo |
| Empty | La cita ya no existe | Mensaje con acción de volver a Mis citas |
| Error | Falló la carga o la cancelación | Mensaje con reintentar; la cita no cambia de estado |
| Offline | Sin conexión | Detalle cacheado con banner; el botón de cancelar queda deshabilitado con el motivo visible |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Tocar Cancelar | Abre un diálogo de confirmación antes de enviar nada | — |
| Confirmar la cancelación | La cita pasa a Cancelada y el cupo se libera | `cancelAppointment` |
| Tocar la dirección | Copia la dirección al portapapeles | — |

---

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| Lectura del detalle | Ninguno propio: la cita ya viene en la respuesta de [`GET /v1/appointments/mine`](../../03-api-and-data/endpoints/appointments-list-mine.md) | `Appointment` (§2.6) | [`appointment`](../../03-api-and-data/entities/appointment.md) |
| `cancelAppointment` | [`PATCH /v1/appointments/{id}/cancel`](../../03-api-and-data/endpoints/appointments-cancel.md) | `Appointment` (§2.6) | Se actualiza la fila de [`appointment`](../../03-api-and-data/entities/appointment.md) con la respuesta del servidor; nunca antes |

> El contrato no tiene un `GET` de una sola cita: la pantalla abre una cita que "Mis citas" ya
> trajo. Si se llega por un enlace directo sin esa lista cargada, la pantalla la pide primero.

---

## Accesibilidad

- [ ] El estado se comunica con texto e ícono, nunca solo con color.
- [ ] El diálogo de confirmación atrapa el foco y lo devuelve al botón al cerrarse.
- [ ] El botón de cancelar se anuncia como acción destructiva.
- [ ] Área táctil mínima de 48x48 dp en todos los botones.
- [ ] Cuando el botón está deshabilitado por falta de conexión, el motivo se anuncia.
