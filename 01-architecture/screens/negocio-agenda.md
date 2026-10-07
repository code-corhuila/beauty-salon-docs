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
| Cuerpo | Lista de citas del día | Hora, servicio y nombre de la clienta; el estado con [DistintivoEstadoCita](../../02-code-and-ui/components/distintivo-estado-cita.md) |
| Acciones por fila | Dos [BotonSecundario](../../02-code-and-ui/components/boton-secundario.md) con `fullWidth={false}`: Confirmar, y Rechazar con `isDestructive` | Solo en las citas Pendientes. No se usa `BotonPrimario`: la pantalla tiene una fila por cita, y un botón primario por fila rompería la regla de uno por pantalla |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cargando la agenda del día | Esqueleto de dos filas |
| Loaded | Hay citas ese día | Lista ordenada por hora |
| Empty | Ese día no tiene citas | [EstadoVacio](../../02-code-and-ui/components/estado-vacio.md) con mensaje neutro y sin acción: un día sin citas no es un error |
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

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| `getBusinessAgenda` | [`GET /v1/business/agenda`](../../03-api-and-data/endpoints/business-agenda.md) | `Appointment` (§2.6), con el nombre y el celular de `UserAccount` (§2.1) de cada clienta | Ninguna: la agenda tiene datos personales de las clientas |
| `respondAppointment` | [`PATCH /v1/business/appointments/{id}/respond`](../../03-api-and-data/endpoints/business-respond-appointment.md) | `Appointment` (§2.6) | Ninguna |

---

## Accesibilidad

- [ ] Cada cita se anuncia completa: hora, servicio y nombre de la clienta.
- [ ] Confirmar y rechazar se distinguen por etiqueta, no solo por color verde y rojo.
- [ ] Rechazar se anuncia como acción destructiva y pide el motivo en un diálogo con foco atrapado.
- [ ] Área táctil mínima de 48x48 dp en los dos botones de cada fila.
- [ ] Con la fuente más grande del sistema los botones se apilan en lugar de recortarse.
