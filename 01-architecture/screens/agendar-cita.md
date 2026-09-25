# Pantalla — BookAppointmentScreen

- **Ruta:** `/book/:serviceId`
- **Feature:** [Agendamiento](../features/booking.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 2 queda como apoyo, no como referencia principal.

---

## Propósito

Elegir fecha y hora entre los cupos que la profesional tiene realmente libres, y confirmar la cita.
Es la pantalla donde el producto cumple su promesa: agendar sin escribir un solo mensaje.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Resumen del servicio | Nombre, precio y duración, para no tener que volver atrás a verificar |
| Selector de fecha | Tira de días | Próximos 14 días; los días sin cupos se ven deshabilitados |
| Cuerpo | [SelectorHorario](../../02-code-and-ui/components/selector-horario.md) | Cuadrícula de horas libres calculadas para esa fecha |
| Pie | [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) fijo | Confirmar cita, activo solo con una hora seleccionada |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Consultando los cupos de la fecha | Esqueleto de la cuadrícula de horas |
| Loaded | Hay cupos libres | Cuadrícula de horas seleccionables |
| Empty | Ese día no tiene cupos | Mensaje con la siguiente fecha disponible sugerida y acción para saltar a ella |
| Error | Falló la consulta de disponibilidad | Mensaje con botón de reintentar |
| Cupo tomado | El servidor rechaza el cupo al confirmar | Aviso explicando que alguien acaba de tomar esa hora, y **recarga automática** de la disponibilidad |
| Offline | Sin conexión | La pantalla explica que agendar necesita conexión y no deja continuar. No se muestran cupos cacheados: un cupo guardado es un cupo mentiroso |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Elegir una fecha | Carga los cupos de ese día | `getAvailability` |
| Tocar una hora | La marca como seleccionada y habilita el botón | — |
| Tocar Confirmar | Crea la cita en estado Pendiente y navega a `/appointment/:appointmentId` | `bookAppointment` |

---

## Accesibilidad

- [ ] Cada hora se anuncia con su estado: "10:30 de la mañana, disponible" o "ocupada".
- [ ] La disponibilidad no se comunica solo por color: la hora ocupada además va tachada o ausente.
- [ ] Área táctil mínima de 48x48 dp en cada celda de hora, aunque visualmente sea chica.
- [ ] El aviso de cupo tomado se anuncia al lector de pantalla apenas aparece: es un cambio que la
      usuaria no provocó y tiene que enterarse sin verlo.
- [ ] La cuadrícula sigue siendo usable con la fuente más grande del sistema: se reacomoda a menos
      columnas en vez de recortar.
- [ ] Contraste AA en las horas deshabilitadas: gris claro sobre blanco no cumple.
