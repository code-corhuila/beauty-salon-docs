# Pantalla — ServiceFormScreen

- **Ruta:** `/business/service/new` (con `serviceId` opcional para editar)
- **Feature:** [Gestión del negocio](../features/business.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 1 queda como apoyo, no como referencia principal.

---

## Propósito

Crear o editar un servicio con todo lo que hace falta para que sea agendable: nombre, descripción,
precio, duración, profesional que lo atiende y horario de atención de esa profesional.

Es el formulario más largo de la app y el que decide si el producto funciona: **si la manicurista no
logra llenarlo sola, no hay catálogo**.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Título y botón atrás | Al salir con cambios sin guardar, pide confirmación |
| Bloque 1 | [CampoFormulario](../../02-code-and-ui/components/campo-formulario.md) | Nombre, tipo de servicio y descripción |
| Bloque 2 | Campos numéricos | Precio en pesos y duración en minutos, múltiplo de 15 |
| Bloque 3 | Selector de profesional | Lista de las profesionales del salón, con opción de agregar una nueva |
| Bloque 4 | Horario por día | Hora de inicio y fin por cada día de la semana que atiende |
| Pie | [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) fijo | Publicar servicio |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cargando el servicio a editar | Esqueleto del formulario |
| Loaded | Formulario listo | Campos editables, validación al salir de cada campo |
| Empty | No aplica | Es un formulario |
| Error | Falla el guardado o hay campos inválidos | Mensaje por campo. **Lo escrito se conserva siempre**: perder un formulario largo es la forma más rápida de que la manicurista abandone |
| Offline | Sin conexión | Se avisa **antes** de empezar a llenar, no al tocar guardar |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Llenar y tocar Publicar | Valida, crea el servicio y calcula los cupos a partir del horario | `createService`, `setSchedule` |
| Editar un servicio existente | Actualiza sin afectar las citas ya agendadas | `createService` en modo edición |
| Salir con cambios sin guardar | Diálogo de confirmación antes de descartar | — |

---

## Reglas de validación

| Campo | Regla | Por qué |
|-------|-------|---------|
| Nombre | Obligatorio, hasta 60 caracteres | Se muestra en la tarjeta del catálogo |
| Precio | Obligatorio, mayor a 0, en pesos enteros | Sin precio la clienta vuelve a preguntar por WhatsApp |
| Duración | Obligatoria, múltiplo de 15, entre 15 y 240 minutos | De la duración salen los cupos |
| Profesional | Obligatoria | Sin profesional no hay horario del cual calcular cupos |
| Horario | Al menos un día con hora de inicio menor a la de fin | Un servicio sin horario es inagendable |

---

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| Selector de profesional | [`GET /v1/business/professionals`](../../03-api-and-data/endpoints/business-list-professionals.md) y [`POST /v1/business/professionals`](../../03-api-and-data/endpoints/business-create-professional.md) | `Professional` (§2.3) | Ninguna |
| `createService`, `setSchedule` | [`POST /v1/business/services`](../../03-api-and-data/endpoints/business-create-service.md) | `Service` (§2.4) y `Schedule` (§2.5) | Ninguna |
| Edición | [`PUT /v1/business/services/{id}`](../../03-api-and-data/endpoints/business-update-service.md) | `Service` (§2.4) y `Schedule` (§2.5) | Ninguna |

---

## Accesibilidad

- [ ] Cada campo tiene etiqueta visible, no solo texto de ayuda dentro del campo.
- [ ] Los errores se anuncian al lector de pantalla y el foco salta al primer campo con error.
- [ ] Los selectores de hora son alcanzables con lector de pantalla, no solo con gesto de rueda.
- [ ] Área táctil mínima de 48x48 dp en cada control del horario.
- [ ] El teclado no tapa el campo enfocado.
- [ ] El formulario completo es usable con la fuente más grande del sistema.
