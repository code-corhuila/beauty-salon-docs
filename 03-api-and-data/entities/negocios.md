# Entidad local — negocios

- **Almacén:** SQLite con `@capacitor-community/sqlite` y Drizzle ORM
- **Tabla:** `negocios`
- **Versión de esquema en que se introduce:** 1

Guarda lo mínimo para mostrar de quién es cada servicio en el catálogo: el nombre del salón y su
dirección.

---

## Campos

| Columna | Tipo | Nulo | Notas |
|---------|------|------|-------|
| `id` | text | No | Llave primaria, la misma del servidor |
| `name` | text | No | Nombre del salón, o el de la manicurista independiente |
| `address` | text | No | Se muestra como texto; el MVP no usa mapa ni coordenadas |
| `created_at` | integer | No | Epoch en milisegundos |
| `updated_at` | integer | No | Epoch en milisegundos |
| `cached_at` | integer | No | Cuándo se trajo del servidor |

> **El celular del negocio no se guarda aquí, ni llega en el catálogo.** Solo se muestra cuando hay
> una cita confirmada, según [`security-rules.md`](../../00-governance/security-rules.md).

---

## Índices

| Índice | Columnas | Para qué |
|--------|----------|----------|
| — | — | Ninguno además de la llave primaria: la tabla siempre se consulta por `id` desde `servicios` |

> No se crea un índice por si acaso. Un índice que ninguna consulta usa solo hace más lentas las
> escrituras.

---

## Relaciones

| Entidad relacionada | Llave | Cardinalidad |
|---------------------|-------|--------------|
| [`servicios`](./servicios.md) | `negocio_id` en la otra tabla | 1:N |
| [`profesionales`](./profesionales.md) | `negocio_id` en la otra tabla | 1:N |

---

## Sincronización

- **¿Se sincroniza?** No. Caché de solo lectura, igual que `servicios`.
- **Política de conflicto:** no aplica; la respuesta del servidor reemplaza la fila.
- **Vencimiento:** 30 minutos, el mismo del catálogo, porque llegan en la misma respuesta.

---

## Notas de migración

- Se crea en la versión 1 junto con `servicios` y `profesionales`.
- Se vacía al cerrar sesión.
