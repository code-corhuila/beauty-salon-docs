# Pantalla — BusinessServicesScreen

- **Ruta:** `/negocio/servicios`
- **Feature:** [Gestión del negocio](../features/business.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 1 queda como apoyo, no como referencia principal.

---

## Propósito

Que la manicurista vea sus servicios publicados, cree uno nuevo, edite los existentes y pause los que
no esté prestando. Es la pantalla de inicio del lado del negocio.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Título y nombre del salón | — |
| Cuerpo | Lista de servicios propios | Nombre, precio, duración, profesional y distintivo de Publicado o Pausado |
| Pie | [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) fijo | Crear servicio |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cargando los servicios | Esqueleto de dos filas |
| Loaded | Tiene servicios | Lista con interruptor de publicado o pausado por fila |
| Empty | Negocio recién registrado | [EstadoVacio](../../02-code-and-ui/components/estado-vacio.md) que explica que sin servicios publicados nadie la puede encontrar, con acción de crear el primero. **Es la pantalla más importante del onboarding del negocio** |
| Error | Falló la carga | Mensaje con botón de reintentar |
| Offline | Sin conexión | Aviso de que la gestión necesita conexión; la lista no se cachea |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Tocar Crear servicio | Navega a `/negocio/servicio/nuevo` | — |
| Tocar un servicio | Navega al formulario en modo edición | — |
| Mover el interruptor | Publica o pausa el servicio; cambio optimista que se revierte si falla | `pauseService` |

---

## Accesibilidad

- [ ] El interruptor anuncia qué controla y su estado: "Manicure semipermanente, publicado".
- [ ] El estado publicado o pausado se distingue con texto, no solo con color.
- [ ] Área táctil mínima de 48x48 dp en el interruptor y en cada fila.
- [ ] Al pausar, el cambio se anuncia al lector de pantalla.
- [ ] El estado vacío es alcanzable y legible con la fuente más grande del sistema.
