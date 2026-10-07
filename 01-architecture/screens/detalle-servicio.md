# Pantalla — ServiceDetailScreen

- **Ruta:** `/service/:serviceId`
- **Feature:** [Catálogo de servicios](../features/catalog.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 2 queda como apoyo, no como referencia principal.

---

## Propósito

Mostrar todo lo que la clienta necesita para decidir: qué incluye el servicio, cuánto vale, cuánto se
demora, quién lo atiende y dónde queda. Desde aquí se entra a agendar.

Es también la pantalla que recibe el deep link que una clienta comparte por WhatsApp, así que tiene
que funcionar sin sesión y sin venir del catálogo.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Foto del servicio y botón atrás | Si no hay foto, se usa un fondo con el color del token de marca |
| Cuerpo | Bloques de información | Nombre, precio, duración, descripción, profesional que atiende, nombre y dirección del salón |
| Pie | [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) fijo | Agendar. Visible sin hacer scroll |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cargando el detalle | Esqueleto con la forma del contenido |
| Loaded | Detalle disponible | Contenido completo y botón de agendar activo |
| Empty | El servicio fue pausado o eliminado | Mensaje de que ya no está disponible, con acción de volver al catálogo |
| Error | Falló la petición | Mensaje con botón de reintentar |
| Offline | Sin conexión con detalle cacheado | Contenido cacheado con banner. **El botón de agendar se deshabilita**, porque agendar es online-only |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Abrir la pantalla | Carga el detalle por su id | `getServiceDetail` |
| Tocar Agendar | Navega a `/book/:serviceId`; sin sesión, la guarda pide login y devuelve aquí | — |
| Tocar la dirección | Copia la dirección al portapapeles | — |

---

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| `getServiceDetail` | [`GET /v1/services/{id}`](../../03-api-and-data/endpoints/catalog-service-detail.md) | `Service` (§2.4), `Business` (§2.2), `Professional` (§2.3) | [`service`](../../03-api-and-data/entities/service.md), [`business`](../../03-api-and-data/entities/business.md), [`professional`](../../03-api-and-data/entities/professional.md) (read-through) |

---

## Accesibilidad

- [ ] El precio y la duración se anuncian juntos con su unidad: "45 mil pesos, 60 minutos".
- [ ] La foto tiene texto alternativo o se marca como decorativa.
- [ ] El botón de agendar cumple 48x48 dp y mantiene el contraste AA en ambos temas.
- [ ] Cuando el botón está deshabilitado por falta de conexión, el motivo se anuncia al lector de
      pantalla: un botón deshabilitado sin explicación es un callejón sin salida.
- [ ] El contenido escala con el tamaño de fuente del sistema sin recortar la descripción.
