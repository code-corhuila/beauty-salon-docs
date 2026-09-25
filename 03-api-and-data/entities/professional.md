# Entidad local — profesionales

- **Almacén:** SQLite con `@capacitor-community/sqlite` y Drizzle ORM
- **Tabla:** `professional`
- **Versión de esquema en que se introduce:** 2 (en la 1 se llamaba en español; ver [persistence.md](../persistence.md))

Guarda quién atiende cada servicio, que es lo que la clienta mira antes de decidir: en este negocio
la persona importa tanto como el precio.

---

## Campos

| Columna | Tipo | Nulo | Notas |
|---------|------|------|-------|
| `id` | text | No | Llave primaria, la misma del servidor |
| `name` | text | No | Nombre de la profesional |
| `business_id` | text | No | Llave foránea a [`business`](./business.md) |
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
| `idx_professional_business` | `business_id` | Listar las profesionales de un salón |

---

## Relaciones

| Entidad relacionada | Llave | Cardinalidad |
|---------------------|-------|--------------|
| [`business`](./business.md) | `business_id` | N:1 |
| [`service`](./service.md) | `professional_id` en la otra tabla | 1:N |
| [`appointment`](./appointment.md) | `professional_id` en la otra tabla | 1:N |

---

## Sincronización

- **¿Se sincroniza?** No. Caché de solo lectura.
- **Política de conflicto:** no aplica.
- **Vencimiento:** 30 minutos, junto con el catálogo.

---

## Notas de migración

- Se crea en la versión 2 junto con `business` y `service`, en la misma transacción.
- Se vacía al cerrar sesión.
