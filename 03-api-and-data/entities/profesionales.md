# Entidad local — profesionales

- **Almacén:** SQLite con `@capacitor-community/sqlite` y Drizzle ORM
- **Tabla:** `profesionales`
- **Versión de esquema en que se introduce:** 1

Guarda quién atiende cada servicio, que es lo que la clienta mira antes de decidir: en este negocio
la persona importa tanto como el precio.

---

## Campos

| Columna | Tipo | Nulo | Notas |
|---------|------|------|-------|
| `id` | text | No | Llave primaria, la misma del servidor |
| `name` | text | No | Nombre de la profesional |
| `negocio_id` | text | No | Llave foránea a [`negocios`](./negocios.md) |
| `created_at` | integer | No | Epoch en milisegundos |
| `updated_at` | integer | No | Epoch en milisegundos |
| `cached_at` | integer | No | Cuándo se trajo del servidor |

> **El horario de atención no se guarda aquí.** Solo sirve para calcular cupos, y eso es online-only:
> ver [`persistence.md`](../persistence.md). Guardarlo daría la ilusión de poder calcular
> disponibilidad sin conexión, que es justo lo que no se debe hacer.

---

## Índices

| Índice | Columnas | Para qué |
|--------|----------|----------|
| `idx_profesionales_negocio` | `negocio_id` | Listar las profesionales de un salón |

---

## Relaciones

| Entidad relacionada | Llave | Cardinalidad |
|---------------------|-------|--------------|
| [`negocios`](./negocios.md) | `negocio_id` | N:1 |
| [`servicios`](./servicios.md) | `profesional_id` en la otra tabla | 1:N |
| [`citas`](./citas.md) | `profesional_id` en la otra tabla | 1:N |

---

## Sincronización

- **¿Se sincroniza?** No. Caché de solo lectura.
- **Política de conflicto:** no aplica.
- **Vencimiento:** 30 minutos, junto con el catálogo.

---

## Notas de migración

- Se crea en la versión 1 junto con `negocios` y `servicios`, en la misma transacción.
- Se vacía al cerrar sesión.
