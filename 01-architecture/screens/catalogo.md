# Pantalla — CatalogScreen

- **Ruta:** `/servicios`
- **Feature:** [Catálogo de servicios](../features/catalog.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 2 queda como apoyo, no como referencia principal.

---

## Propósito

Ver todos los servicios de manicure publicados en la ciudad y filtrarlos por tipo. Es la pantalla de
entrada de la app y **se explora sin cuenta**.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Título y fila de filtros | Chips por tipo: tradicional, semipermanente, acrílicas, retiro, decoración |
| Cuerpo | Lista de [TarjetaServicio](../../02-code-and-ui/components/tarjeta-servicio.md) | `IonList` virtualizada con foto, nombre, precio, duración y nombre del salón |
| Banner | Aviso de sin conexión | Solo cuando se muestran datos cacheados |
| Pie | — | Sin CTA fijo: la acción está en cada tarjeta |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Primera carga sin caché | Esqueleto de tres tarjetas, no un spinner centrado |
| Loaded | Hay servicios publicados | Lista con pull-to-refresh |
| Empty | No hay ningún servicio publicado todavía | [EstadoVacio](../../02-code-and-ui/components/estado-vacio.md) que invita a compartir la app con su manicurista. **Es el estado del primer día de la app** |
| Empty por filtro | Hay servicios, pero ninguno del tipo filtrado | Mensaje con acción de quitar el filtro |
| Error | Falló la petición y no hay caché | Mensaje con botón de reintentar |
| Offline | Sin conexión | Lista cacheada con banner y la fecha de la última actualización |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Tocar un chip de tipo | Filtra la lista sin dejarla en blanco | `getPublishedServices` |
| Tocar una tarjeta | Navega a `/servicio/:servicioId` | — |
| Deslizar hacia abajo | Refresca desde el servidor | `getPublishedServices` |

---

## Accesibilidad

- [ ] Cada tarjeta se anuncia completa: nombre, precio y duración en una sola etiqueta.
- [ ] Los chips de filtro se anuncian como seleccionados o no, además del cambio de color.
- [ ] Área táctil mínima de 48x48 dp en chips y tarjetas.
- [ ] Las fotos de servicio tienen texto alternativo, o se marcan como decorativas si el nombre ya
      está en la etiqueta de la tarjeta.
- [ ] La lista sigue siendo usable con el tamaño de fuente más grande del sistema: la tarjeta crece,
      no recorta el texto.
- [ ] Contraste AA del precio sobre el fondo de la tarjeta, en tema claro y oscuro.
