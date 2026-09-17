# Entidad local — servicios

- **Almacén:** SQLite con `@capacitor-community/sqlite` y Drizzle ORM ([ADR-007](../../01-architecture/decisions/records/ADR-007-local-storage-capacitor.md))
- **Tabla:** `servicios`
- **Versión de esquema en que se introduce:** 1

Es la tabla que hace que el catálogo abra con contenido aunque la señal esté mala. Es la razón
principal por la que este proyecto tiene base de datos local.

---

## Campos

| Columna | Tipo | Nulo | Notas |
|---------|------|------|-------|
| `id` | text | No | Llave primaria, la misma del servidor |
| `name` | text | No | Nombre del servicio |
| `type` | text | No | `tradicional`, `semipermanente`, `acrilicas`, `retiro`, `decoracion`, `otro` |
| `description` | text | Sí | Solo llega en el detalle, no en la lista |
| `price_cop` | integer | No | Pesos enteros. Nunca se guarda el precio ya formateado |
| `duration_minutes` | integer | No | Múltiplo de 15 |
| `image_url` | text | Sí | Puede no tener foto |
| `is_published` | integer | No | Booleano 0 o 1 |
| `negocio_id` | text | No | Llave foránea a [`negocios`](./negocios.md) |
| `profesional_id` | text | No | Llave foránea a [`profesionales`](./profesionales.md) |
| `created_at` | integer | No | Epoch en milisegundos, se pone al insertar |
| `updated_at` | integer | No | Epoch en milisegundos, se actualiza en cada escritura |
| `cached_at` | integer | No | Cuándo se trajo del servidor; de aquí sale el TTL y la fecha del banner |

---

## Índices

| Índice | Columnas | Para qué |
|--------|----------|----------|
| `idx_servicios_type` | `type` | Filtrar el catálogo por tipo sin recorrer toda la tabla |
| `idx_servicios_negocio` | `negocio_id` | Traer los servicios de un salón junto con su información |

---

## Relaciones

| Entidad relacionada | Llave | Cardinalidad |
|---------------------|-------|--------------|
| [`negocios`](./negocios.md) | `negocio_id` | N:1 — muchos servicios pertenecen a un negocio |
| [`profesionales`](./profesionales.md) | `profesional_id` | N:1 — muchos servicios los atiende una profesional |
| [`citas`](./citas.md) | `servicio_id` en la otra tabla | 1:N |

---

## Sincronización

- **¿Se sincroniza?** No en dos direcciones. Es **caché de solo lectura**: el servidor escribe, la app
  lee.
- **Política de conflicto:** no aplica. La app nunca modifica un servicio localmente; la respuesta del
  servidor reemplaza la fila completa.
- **Vencimiento:** 30 minutos según `cached_at`. Vencido se muestra igual y se refresca en segundo
  plano.

---

## Notas de migración

- Se crea en la versión 1 del esquema, junto con `negocios` y `profesionales`, dentro de una sola
  transacción.
- La tabla se vacía completa al cerrar sesión, junto con el resto de la base.
- Si más adelante se agrega una columna, se hace en una migración nueva con valor por defecto: la
  migración de la versión 1 no se toca nunca.
