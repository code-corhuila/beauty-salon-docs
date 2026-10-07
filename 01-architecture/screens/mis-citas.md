# Pantalla — MyAppointmentsScreen

- **Ruta:** `/my-appointments`
- **Feature:** [Mis citas](../features/appointments.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 3 queda como apoyo, no como referencia principal.

---

## Propósito

Ver las citas propias separadas en próximas y pasadas. Es la pantalla que la clienta abre camino al
salón para confirmar la hora, muchas veces sin buena señal.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Título y dos pestañas | Próximas y Pasadas |
| Cuerpo | Lista de tarjetas de cita | Fecha, hora, servicio y salón; el estado con [DistintivoEstadoCita](../../02-code-and-ui/components/distintivo-estado-cita.md). La tarjeta solo la usa esta feature, así que vive en `features/appointments/presentation/` |
| Banner | Aviso de sin conexión | Con la fecha de la última actualización |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cargando las citas | Esqueleto de dos tarjetas |
| Loaded | Hay citas | Lista ordenada: la más próxima primero |
| Empty | Nunca ha agendado | [EstadoVacio](../../02-code-and-ui/components/estado-vacio.md) con acción que lleva al catálogo |
| Error | Falló la carga sin caché | Mensaje con botón de reintentar |
| Offline | Sin conexión | Citas cacheadas con banner; se puede leer todo, no se puede cancelar |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Cambiar de pestaña | Alterna próximas y pasadas sin volver a pedir al servidor | — |
| Tocar una cita | Navega a `/appointment/:appointmentId` | — |
| Deslizar hacia abajo | Refresca desde el servidor | `getMyAppointments` |

---

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| `getMyAppointments` | [`GET /v1/appointments/mine`](../../03-api-and-data/endpoints/appointments-list-mine.md) | `Appointment` (§2.6), con `Service` (§2.4) y `Business` (§2.2) | [`appointment`](../../03-api-and-data/entities/appointment.md), solo las citas propias (read-through) |

---

## Accesibilidad

- [ ] El estado de la cita se anuncia con texto, no solo con el color del distintivo.
- [ ] Cada tarjeta se anuncia como una sola unidad: "Manicure semipermanente, viernes 12 a las 3 de
      la tarde, confirmada".
- [ ] Las pestañas se anuncian como pestañas, con la activa marcada.
- [ ] Área táctil mínima de 48x48 dp en pestañas y tarjetas.
- [ ] La lista escala con la fuente del sistema sin recortar la fecha.
