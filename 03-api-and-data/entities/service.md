# Entidad local — servicios

- **Almacén:** SQLite con `@capacitor-community/sqlite` y Drizzle ORM ([ADR-007](../../01-architecture/decisions/records/ADR-007-local-storage-capacitor.md))
- **Tabla:** `service`
- **Versión de esquema en que se introduce:** 2 (en la 1 se llamaba en español; ver [persistence.md](../persistence.md))

Es la tabla que hace que el catálogo abra con contenido aunque la señal esté mala. Es la razón
principal por la que este proyecto tiene base de datos local.

---

## Campos

| Columna | Tipo | Nulo | Notas |
|---------|------|------|-------|
| `id` | text | No | Llave primaria, la misma del servidor |
| `name` | text | No | Nombre del servicio |
| `type` | text | No | `traditional`, `semi_permanent`, `acrylic`, `removal`, `nail_art`, `otro` |
| `description` | text | Sí | Solo llega en el detalle, no en la lista |
| `price_cop` | integer | No | Pesos enteros. Nunca se guarda el precio ya formateado |
| `duration_minutes` | integer | No | Múltiplo de 15 |
| `image_url` | text | Sí | Puede no tener foto |
| `is_published` | integer | No | Booleano 0 o 1 |
| `business_id` | text | No | Llave foránea a [`business`](./business.md) |
| `professional_id` | text | No | Llave foránea a [`professional`](./professional.md) |
| `created_at` | integer | No | Epoch en milisegundos, se pone al insertar |
| `updated_at` | integer | No | Epoch en milisegundos, se actualiza en cada escritura |
| `cached_at` | integer | No | Cuándo se trajo del servidor; de aquí sale el TTL y la fecha del banner |

---

## Índices

| Índice | Columnas | Para qué |
|--------|----------|----------|
| `idx_service_type` | `type` | Filtrar el catálogo por tipo sin recorrer toda la tabla |
| `idx_service_business` | `business_id` | Traer los servicios de un salón junto con su información |

---

## Relaciones

| Entidad relacionada | Llave | Cardinalidad |
|---------------------|-------|--------------|
| [`business`](./business.md) | `business_id` | N:1 — muchos servicios pertenecen a un negocio |
| [`professional`](./professional.md) | `professional_id` | N:1 — muchos servicios los atiende una profesional |
| [`appointment`](./appointment.md) | `service_id` en la otra tabla | 1:N |

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

- Se crea en la versión 2 del esquema, junto con `business` y `professional`, dentro de una sola
  transacción.
- La tabla se vacía completa al cerrar sesión, junto con el resto de la base.
- Si más adelante se agrega una columna, se hace en una migración nueva con valor por defecto: la
  migración de la versión 2 no se toca nunca.
