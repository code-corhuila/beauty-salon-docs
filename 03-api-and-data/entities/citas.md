# Entidad local — citas

- **Almacén:** SQLite con `@capacitor-community/sqlite` y Drizzle ORM
- **Tabla:** `citas`
- **Versión de esquema en que se introduce:** 2

Guarda **solo las citas de la clienta autenticada**. Existe para que pueda ver a qué hora y en qué
dirección es su cita cuando va camino al salón, que suele ser cuando peor señal tiene.

La agenda del negocio **no** usa esta tabla ni ninguna otra: contiene datos de terceras personas y no
se guarda en el dispositivo.

---

## Campos

| Columna | Tipo | Nulo | Notas |
|---------|------|------|-------|
| `id` | text | No | Llave primaria, la misma del servidor |
| `status` | text | No | `pendiente`, `confirmada`, `rechazada`, `cancelada`, `completada`, `no_asistio` |
| `starts_at` | integer | No | Epoch en milisegundos, en hora de Colombia |
| `servicio_id` | text | No | Llave foránea a [`servicios`](./servicios.md) |
| `profesional_id` | text | No | Llave foránea a [`profesionales`](./profesionales.md) |
| `negocio_id` | text | No | Llave foránea a [`negocios`](./negocios.md) |
| `service_name` | text | No | Copia del nombre al momento de agendar |
| `price_cop` | integer | No | Copia del precio al momento de agendar |
| `duration_minutes` | integer | No | Copia de la duración al momento de agendar |
| `rejection_reason` | text | Sí | Solo cuando `status` es `rechazada` |
| `created_at` | integer | No | Epoch en milisegundos |
| `updated_at` | integer | No | Epoch en milisegundos |
| `cached_at` | integer | No | Cuándo se trajo del servidor |

> Las tres columnas copiadas —nombre, precio y duración— **duplican** datos de `servicios` a
> propósito. Una cita es el registro de lo que se acordó ese día: si la manicurista sube el precio el
> mes entrante, la cita pasada no puede cambiar de valor. Y si el servicio se despublica, la cita
> tiene que seguir siendo legible.

---

## Índices

| Índice | Columnas | Para qué |
|--------|----------|----------|
| `idx_citas_starts_at` | `starts_at` | Ordenar la lista y separar próximas de pasadas, que es la consulta de la pantalla principal |
| `idx_citas_status` | `status` | Filtrar por estado en el detalle y en las pruebas |

---

## Relaciones

| Entidad relacionada | Llave | Cardinalidad |
|---------------------|-------|--------------|
| [`servicios`](./servicios.md) | `servicio_id` | N:1 |
| [`profesionales`](./profesionales.md) | `profesional_id` | N:1 |
| [`negocios`](./negocios.md) | `negocio_id` | N:1 |

---

## Sincronización

- **¿Se sincroniza?** No en dos direcciones. Es caché de lectura: crear y cancelar son operaciones
  online-only y la respuesta del servidor reemplaza la fila.
- **Política de conflicto:** `server-wins`, sin excepción. El estado de la cita lo cambia el negocio,
  así que el servidor siempre sabe más que el dispositivo.
- **Vencimiento:** 5 minutos, más corto que el del catálogo por la misma razón.

---

## Notas de migración

- Llega en la **versión 2** del esquema, en el Sprint 2, cuando ya hay celulares de prueba con datos
  de la versión 1. La migración agrega la tabla y sus dos índices sin tocar las tablas existentes.
- Se prueba contra una base con catálogo cargado, no vacía.
- Se vacía al cerrar sesión.
