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
| Cuerpo | Lista de tarjetas de cita | Fecha, hora, servicio, salón y estado de la cita |
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

## Accesibilidad

- [ ] El estado de la cita se anuncia con texto, no solo con el color del distintivo.
- [ ] Cada tarjeta se anuncia como una sola unidad: "Manicure semipermanente, viernes 12 a las 3 de
      la tarde, confirmada".
- [ ] Las pestañas se anuncian como pestañas, con la activa marcada.
- [ ] Área táctil mínima de 48x48 dp en pestañas y tarjetas.
- [ ] La lista escala con la fuente del sistema sin recortar la fecha.
