# Pantalla — BusinessAgendaScreen

- **Ruta:** `/business/agenda`
- **Feature:** [Gestión del negocio](../features/business.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 3 queda como apoyo, no como referencia principal.

---

## Propósito

Que la manicurista vea las citas que le llegaron, día por día, y las confirme o las rechace. Es la
pantalla que reemplaza el cuaderno.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Selector de día | Tira de días con un punto en los que tienen citas |
| Cuerpo | Lista de citas del día | Hora, servicio, nombre de la clienta y estado |
| Acciones por fila | Botones Confirmar y Rechazar | Solo en las citas Pendientes |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cargando la agenda del día | Esqueleto de dos filas |
| Loaded | Hay citas ese día | Lista ordenada por hora |
| Empty | Ese día no tiene citas | Mensaje neutro: un día sin citas no es un error |
| Error | Falló la carga | Mensaje con botón de reintentar |
| Offline | Sin conexión | La agenda **no se cachea** por contener datos de las clientas: se explica que se necesita conexión |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Elegir un día | Carga las citas de ese día | `getBusinessAgenda` |
| Tocar Confirmar | La cita pasa a Confirmada y la clienta recibe el aviso | `respondAppointment` |
| Tocar Rechazar | Pide el motivo y la cita pasa a Rechazada con ese motivo visible para la clienta | `respondAppointment` |

---

## Accesibilidad

- [ ] Cada cita se anuncia completa: hora, servicio y nombre de la clienta.
- [ ] Confirmar y rechazar se distinguen por etiqueta, no solo por color verde y rojo.
- [ ] Rechazar se anuncia como acción destructiva y pide el motivo en un diálogo con foco atrapado.
- [ ] Área táctil mínima de 48x48 dp en los dos botones de cada fila.
- [ ] Con la fuente más grande del sistema los botones se apilan en lugar de recortarse.
