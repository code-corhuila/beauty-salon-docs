# Feature — Catálogo de servicios

- **Responsables:** Lilly Signey Puentes Rincon y Lizeth Caicedo
- **Estado:** Planned
- **Historias relacionadas:** HU-003 explorar y elegir el servicio (Sprint 2)

---

## Propósito

Mostrarle a la clienta qué servicios de manicure hay publicados en la ciudad, cuánto valen, cuánto
duran y quién los atiende, para que pueda decidir sin escribirle a nadie. Es la pantalla que
reemplaza la pregunta de WhatsApp "¿cuánto vale y qué días tienes?".

---

## Pantallas

| Pantalla | Ruta | Propósito |
|----------|------|-----------|
| [CatalogScreen](../screens/catalogo.md) | `/servicios` | Listar los servicios publicados y filtrarlos por tipo |
| [ServiceDetailScreen](../screens/detalle-servicio.md) | `/servicio/:servicioId` | Ver descripción, precio, duración, profesional y dirección, y entrar a agendar |

---

## Estado

- **Patrón:** Store con Zustand ([ADR-006](../decisions/records/ADR-006-state-management-pattern.md))
- **Objetos de estado:** `CatalogState`, `ServiceDetailState`
- **Transiciones clave:**
  - `CatalogState`: `loading` a `loaded` o `empty` o `error`. Cambiar el filtro de tipo vuelve a
    `loading` sin borrar la lista anterior, para que la pantalla no parpadee en blanco.
  - `isOffline` puede ser true junto a `loaded`: se muestra el catálogo cacheado con un aviso de que
    puede estar desactualizado.

---

## Datos

- **Casos de uso:** `getPublishedServices`, `getServiceDetail`
- **Repositorios:** `CatalogRepository`
- **Endpoints:** [`GET /v1/servicios`](../../03-api-and-data/endpoints/catalogo-listar-servicios.md),
  [`GET /v1/servicios/{id}`](../../03-api-and-data/endpoints/catalogo-detalle-servicio.md)
- **Persistencia local:** tablas [`servicios`](../../03-api-and-data/entities/servicios.md),
  [`profesionales`](../../03-api-and-data/entities/profesionales.md) y
  [`negocios`](../../03-api-and-data/entities/negocios.md)
- **Estrategia offline:** **read-through cache**. Se muestra lo cacheado de inmediato y se refresca
  en segundo plano. Justificación de negocio: un precio de manicure que cambió ayer sigue siendo útil
  hoy; una clienta con la app en blanco en el bus, no.

---

## Casos borde y estados

- [x] Loading — primera carga sin caché: esqueleto de tarjetas, no un spinner centrado
- [x] Empty — **el caso del primer día de la app**: no hay servicios publicados todavía. El mensaje
      no dice "sin resultados", invita a la clienta a volver y ofrece compartir la app con su
      manicurista
- [x] Empty por filtro — hay servicios pero ninguno del tipo filtrado: se ofrece quitar el filtro
- [x] Error / reintento — falla la petición y no hay caché: mensaje con botón de reintentar
- [x] Offline — banner sobre la lista cacheada con la fecha de la última actualización
- [ ] Permiso denegado — no aplica

---

## Decisiones

- [ADR-006](../decisions/records/ADR-006-state-management-pattern.md) — patrón de estado
- [ADR-007](../decisions/records/ADR-007-local-storage-capacitor.md) — el caché del catálogo es la razón
  principal por la que existe la base local

---

## Pruebas

- **Unitarias:** `getPublishedServices` con caché fresco, con caché vencido y sin conexión;
  que el filtro por tipo no dispare una petición nueva si la lista ya está en memoria.
- **De componente:** `CatalogScreen` en loading, loaded, empty, empty-por-filtro, error y offline.
  El estado empty tiene prueba propia porque es el que se ve el primer día.
- **Integración:** abrir el detalle desde la lista y volver conservando la posición del scroll.
