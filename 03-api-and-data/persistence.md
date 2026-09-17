# Persistencia local

## Elección

**SQLite a través de `@capacitor-community/sqlite`, con Drizzle ORM** (conectado vía el driver
`drizzle-orm/sqlite-proxy`), registrado en
[ADR-007](../01-architecture/decisions/records/ADR-007-local-storage-capacitor.md). Todo el acceso
pasa detrás de las interfaces de repositorio del dominio.

Los modelos persistidos se mantienen **separados** de las entidades de dominio y se mapean entre
ellos. Son dos cosas distintas a propósito: la tabla puede tener `is_synced` y `updated_at`, que al
dominio no le importan.

## Qué se guarda y qué no

La regla es guardar solo lo que la app necesita sin conexión, no espejar el backend.

| Se guarda | Por qué |
|-----------|---------|
| [`servicios`](./entities/servicios.md) | El catálogo debe abrir con contenido aunque la señal esté mala |
| [`negocios`](./entities/negocios.md) | Nombre y dirección se muestran junto a cada servicio |
| [`profesionales`](./entities/profesionales.md) | Quién atiende el servicio, se muestra en el detalle |
| [`citas`](./entities/citas.md) | Solo las de la clienta autenticada: es lo que se consulta camino al salón |

| NO se guarda | Por qué |
|--------------|---------|
| Cupos y disponibilidad | Un cupo guardado es un cupo mentiroso: puede haberlo tomado otra clienta hace un minuto |
| Horarios de atención | Solo sirven para calcular cupos, y eso es online-only |
| Agenda del negocio | Contiene nombre y celular de las clientas. Es el dato más sensible de la app y no tiene por qué quedar en reposo en el dispositivo |
| Datos de otras clientas | Nunca, por la misma razón |
| Tokens | Van al plugin de secure storage de Capacitor, no a SQLite |

## Nombres

- Tablas en `snake_case` y plural: `servicios`, `citas`.
- Llave primaria: `id`.
- Llaves foráneas: `<entidad_singular>_id` — `servicio_id`, `negocio_id`.
- Marcas de tiempo en registros mutables: `created_at`, `updated_at`.
- Booleanos con prefijo `is_` o `has_`: `is_published`.
- Las columnas van en inglés, igual que el resto del código; los nombres de tabla en español porque
  son los del dominio del negocio y así aparecen en el modelo de datos de la planificación.

## Reglas

- Solo se guarda lo listado arriba.
- Todo acceso a la base pasa por la capa de datos. Ninguna pantalla toca SQLite.
- Las escrituras de varios pasos van en una transacción: guardar el catálogo son tres tablas y o
  entran las tres, o no entra ninguna.
- Cada entidad se define con [`_template-entity.md`](./_template-entity.md) y queda registrada en el
  [README de la sección](./README.md).
- La base se borra completa al cerrar sesión.

## Migraciones

- Cada cambio de esquema viaja con su **migración versionada y hacia adelante**. Una migración ya
  publicada **nunca** se modifica: se escribe otra.
- La versión del esquema local sube en cada cambio estructural.
- Las migraciones se prueban contra una base **con datos**, no vacía. Una migración probada en base
  vacía no probó nada.

| Versión | Cambio | Sprint |
|---------|--------|--------|
| 1 | Esquema inicial: `negocios`, `profesionales`, `servicios` | 1 |
| 2 | Se agrega `citas` con su índice por fecha | 2 |

> La versión 2 llega en el Sprint 2 con datos reales de la versión 1 en los celulares de prueba. Ese
> es justamente el caso que hay que probar antes de publicarla.
