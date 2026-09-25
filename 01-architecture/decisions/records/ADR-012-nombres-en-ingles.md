# ADR-012 — Todos los identificadores en inglés, y migraciones versionadas en la API

- **ID:** ADR-012
- **Fecha:** 2026-09-25
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

Hasta esta fecha el sistema mezclaba dos idiomas en sus identificadores: el código y los campos del
JSON estaban en inglés (`priceCop`, `ServiceDetailScreen`), pero las tablas (`citas`, `usuarios`),
las rutas de la API (`/v1/citas/mias`), las rutas de la app (`/agendar/:servicioId`) y los valores
de enumeración (`pendiente`, `clienta`, `semipermanente`) estaban en español.

El **Manual de contrato de datos y API** del curso (2026-B, §4.1) fija la convención: entidades en
`PascalCase`, tablas y atributos en `snake_case`, **inglés y singular**; claves primarias `id` y
foráneas `<entidad>_id`; campos del JSON en `camelCase`.

Además, `beauty-salon-api` aplicaba el esquema con un único `schema.sql` de `CREATE ... IF NOT
EXISTS`. Eso no son migraciones: un cambio de columna sobre una base existente nunca se aplicaría,
que es exactamente la falla silenciosa que describe el manual en §2.3.

---

## Decisión

**Todo identificador del sistema va en inglés. Los textos que lee la persona siguen en español.**

| Qué | Antes | Después |
|-----|-------|---------|
| Tablas del servidor | `usuarios`, `negocios`, `profesionales`, `servicios`, `horarios`, `citas`, `refresh_tokens_revocados` | `user_account`, `business`, `professional`, `service`, `schedule`, `appointment`, `revoked_refresh_token` |
| Claves foráneas | `negocio_id`, `profesional_id`, `servicio_id`, `cliente_usuario_id`, `usuario_id` | `business_id`, `professional_id`, `service_id`, `client_id`, `user_id` |
| Tablas locales (SQLite) | `negocios`, `profesionales`, `servicios`, `citas` | `business`, `professional`, `service`, `appointment` |
| Rol | `clienta`, `negocio` | `client`, `business` |
| Estado de la cita | `pendiente`, `confirmada`, `rechazada`, `cancelada`, `completada`, `no_asistio` (`noAsistio` en el JSON) | `pending`, `confirmed`, `rejected`, `cancelled`, `completed`, `no_show` — **el mismo valor en la base y en el JSON** |
| Tipo de servicio | `tradicional`, `semipermanente`, `acrilicas`, `retiro`, `decoracion` | `traditional`, `semi_permanent`, `acrylic`, `removal`, `nail_art` |
| Parámetros de consulta | `fecha`, `tipo`, `alcance=proximas\|pasadas` | `date`, `type`, `scope=upcoming\|past` |
| Rutas de la API | `/v1/servicios`, `/v1/citas/mias`, `/v1/negocio/...`, `/registro`, `/disponibilidad`, `/cancelar`, `/responder`, `/estado` | `/v1/services`, `/v1/appointments/mine`, `/v1/business/...`, `/register`, `/availability`, `/cancel`, `/respond`, `/status` |
| Rutas de la app | `/servicios`, `/servicio/:servicioId`, `/agendar/:servicioId`, `/mis-citas`, `/cita/:citaId`, `/negocio/...`, `/registro` | `/services`, `/service/:serviceId`, `/book/:serviceId`, `/my-appointments`, `/appointment/:appointmentId`, `/business/...`, `/register` |
| Documentos de endpoints y entidades | `negocio-crear-servicio.md`, `entities/citas.md`, … | `business-create-service.md`, `entities/appointment.md`, … |

**Palabra reservada:** `user` lo es en PostgreSQL, así que la tabla se llama `user_account` (manual
§4.1 pide documentar cómo se resolvió). Sus claves foráneas siguen la entidad, no la tabla:
`user_id` en `business` y `revoked_refresh_token`, y `client_id` en `appointment`, porque ahí la
relación es con la clienta.

**Se quedan en español, a propósito:** los mensajes de error y de validación que devuelve la API
(`"El correo ya está registrado"`) y los textos de i18n de la app, porque los lee la persona. Los
códigos de error (`SlotTaken`, `ValidationFailed`) ya estaban en inglés.

**Migraciones versionadas:** el esquema del servidor pasa a `beauty-salon-api/src/db/migrations/`
como archivos numerados (`0001_initial_schema.sql`, ...). `migrate.js` aplica, en orden y cada uno
en su transacción, los que no estén registrados en la tabla `schema_migration`. Una migración
aplicada no se edita nunca. La `0001` ya nace en inglés: como no había datos reales, **no se escribió
una migración de renombrado**; las bases locales de desarrollo se recrean (`docker compose down -v`).

En la app, la caché SQLite recibe una **migración v2** que descarta las tablas en español de la v1 y
crea las nuevas. Es solo caché del catálogo, y sus valores de `type` en español ya no coinciden con
los de la API, así que copiarla no tendría sentido.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Todo en inglés, textos para la persona en español (elegida) | Un solo idioma en todo identificador; cumple el manual §4.1; la frontera entre idiomas queda en un solo lugar (i18n y mensajes) | Cambio grande: base, API, app y docs a la vez; rompe clientes viejos | — (elegida) |
| Solo tablas y columnas en inglés | Cumple la letra de §4.1 con menos cambios | Deja rutas y valores en español: `status: "pendiente"` en un JSON con claves en inglés, y el mismo concepto con dos nombres (`appointment` en la base, `/citas` en la URL) | Mantiene justamente la mezcla que se quería eliminar |
| Mantener rutas de la app en español para el deep link | `manicita.app/agendar/128` se lee mejor por WhatsApp | Tercer idioma de facto en la frontera app ↔ usuaria, distinto del de la API | Se prefirió una sola regla sin excepciones |
| Migración 0002 que renombra tablas y valores | Conserva los datos existentes | Ningún dato real que conservar; `ALTER`/`UPDATE` de valores de enumeración y `CHECK` es propenso a errores | Costo sin beneficio en esta etapa |

---

## Consecuencias

**Positivas:**
- El contrato, la base y el código usan el mismo nombre para el mismo concepto.
- El esquema del servidor ya evoluciona con migraciones reales: el próximo cambio es un `0002`.
- `beauty-salon-api/scripts/smoke-test.ps1` recorre los 18 endpoints con los nombres nuevos, y
  comprueba además que las rutas viejas (`/v1/servicios`) responden 404.

**Negativas / Costos:**
- **Cambio rompiente** para cualquier cliente de la API anterior. Se acepta porque la app todavía
  no está publicada y su única feature implementada (catálogo) se actualizó en el mismo cambio. El
  prefijo `/v1` se mantiene: no hay versión anterior que sostener.
- Los enlaces que alguien haya compartido con rutas de la app en español dejan de funcionar.
- Las bases locales de desarrollo deben recrearse (`docker compose down -v` en `beauty-salon-infra`).

**No cambia en esta ADR (queda como está):**
- Los nombres de archivo de las pantallas (`screens/agendar-cita.md`) y de los componentes
  (`BotonPrimario`, `TarjetaServicio`), que el curso ya revisó así en la sección 02.
- Las claves de i18n de la app (`catalogo.titulo`). Solo cambiaron las de tipo de servicio, que se
  construyen a partir del valor de `type`.

**Impacto en el sistema:**
- `beauty-salon-api`: migraciones, todos los módulos, README y script de pruebas.
- `beauty-salon-app`: rutas, tipos, dominio, caché SQLite (migración v2) e i18n de tipos.
- `beauty-salon-docs`: fichas de endpoints y entidades (renombradas), features, pantallas,
  navegación, persistencia, autenticación, flujos y mockups.

---

## Referencias

- Manual de contrato de datos y API, Programación Móvil 2026-B — §2.3 y §4.1.
- [ADR-011](./ADR-011-cuatro-repositorios.md) — dejó pendiente las migraciones versionadas.
