# Convenciones de Git

> Estas reglas rigen los **repositorios de código** de ManiCita: `beauty-salon-app`,
> `beauty-salon-api` y `beauty-salon-infra`.
> Este repositorio de documentación es la excepción declarada en el [README raíz](../README.md):
> no usa ramas, todo se commitea directo a `main`.

> **Actualizado el 2026-11-06 por la retroalimentación del docente.** En app, api e infra el flujo es
> `feat/` o `fix/` → `dev` → `qa` → `main`, siempre por Pull Request y con revisión de la otra
> integrante. **Nadie commitea directo a `dev`, `qa` ni `main`.** La decisión y sus alternativas están
> en [ADR-018](../01-architecture/decisions/records/ADR-018-flujo-dev-qa-main.md), que reemplaza en
> este punto a [ADR-016](../01-architecture/decisions/records/ADR-016-ramas-feat-fix-con-pr.md).

## Ramas

| Rama | Para qué sirve | Recibe PR desde |
|------|----------------|-----------------|
| `feat/…`, `fix/…` | Una historia o un arreglo | Nace de `dev` |
| `dev` | Integración de las tareas terminadas | `feat/`, `fix/` y demás ramas de tarea |
| `qa` | Prueba desde un clon limpio, con el manual | `dev` |
| `main` | Versión entregable; aquí va la etiqueta `v1.0.0` | `qa` |

- **Una rama por historia de usuario o por arreglo.** Nombre: `<tipo>/hu-<NN>-<resumen>` o
  `<tipo>/<scope>-<resumen>` cuando no hay historia.
  - Tipos: `feat`, `fix`, `chore`, `test`, `docs`.
  - Ejemplos: `feat/hu-13-rutas-por-rol`, `feat/hu-15-crud-profesionales`, `fix/catalog-empty-state`.
- Las ramas de tarea no se crean por adelantado: se abren al empezar la historia, salen de `dev` y se
  borran al hacer merge. `dev`, `qa` y `main` no se borran.
- Una rama de tarea vive pocos días. Antes de abrir el PR se actualiza con `dev`
  (`git pull origin dev`).
- `dev` → `qa` → `main` se promueve por grupos de tareas terminadas, no por cada historia.
- **`develop` de `beauty-salon-api` no se usa:** la rama de integración se llama `dev` en los tres
  repositorios. La creó el docente el 2026-09-01 y no se borra sin consultarlo con él. `qa` sí se usa:
  como no compartía historia con `main`, se unió con `--allow-unrelated-histories`, sin push forzado.

## Commits

- [Conventional Commits](https://www.conventionalcommits.org/): `tipo(scope): resumen`.
- Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `build`, `ci`.
- Modo imperativo, máximo 72 caracteres en la línea de resumen.
- **Cada integrante commitea su propio trabajo, con su usuario de GitHub, en varios días.** Se
  commitea por partes pequeñas a medida que se avanza, no todo al final: la guía del curso pone tope
  de 3,0 a la "aplicación de golpe" y deja en 0,0 a quien no tenga commits propios.

**Scopes propios de ManiCita.** Son los únicos válidos y salen de las features documentadas en
`01-architecture/features/`:

| Scope | Cubre |
|-------|-------|
| `auth` | Registro, inicio de sesión, sesión y roles |
| `catalog` | Catálogo de servicios y detalle del servicio |
| `booking` | Disponibilidad y creación de la cita |
| `appointments` | Mis citas de la clienta y detalle de la cita |
| `business` | Profesionales, servicios con horario y agenda del negocio |
| `core` | Cliente HTTP, base de datos local, tema, navegación |
| `infra` | Compose, variables de entorno y manual de implementación (`beauty-salon-infra`) |

Ejemplos:

- `feat(booking): calcular cupos a partir del horario y la duracion`
- `fix(catalog): mostrar estado vacio cuando no hay servicios publicados`
- `feat(business): eliminar profesional sin citas activas`

## Pull Requests

- Un PR = una historia o un arreglo. Revisable (menos de ~400 líneas cuando se pueda).
- El título sigue Conventional Commits. La descripción enlaza la historia (`Closes #NN`) y lista qué
  probar.
- Antes de pedir revisión, en la máquina de quien abre el PR: en la app `npm run lint` y
  `npm run test.unit` en verde; en la API, el smoke test (`scripts/smoke-test.ps1`) y, cuando exista
  (deuda del c3-project), `npm test`. No hay CI todavía: el que
  abre el PR declara en la descripción que lo corrió.
- Al menos una aprobación en GitHub. **Merge commit** en todos los PR (botón *Create a merge
  commit*), **no squash**: el squash junta los commits en uno solo a nombre de quien hace el merge y
  borra la autoría de cada integrante, que la guía del curso califica.

> Con un equipo de dos, la aprobación la da quien **no** escribió el PR, desde su propia cuenta de
> GitHub. Un PR sin esa revisión no se fusiona, tampoco en las promociones hacia `qa` y `main`.

## Releases

- Versión con [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`.
- Los releases se etiquetan `vX.Y.Z` sobre `main`, con la misma versión en los tres repositorios de
  código.
- **`v1.0.0` es la entrega del c3-project:** etiqueta en `main` de `beauty-salon-app`,
  `beauty-salon-api` y `beauty-salon-infra` antes del **2026-11-15 23:59**, después de la sustentación
  del 2026-11-09. Tras la sustentación solo entran correcciones y documentación (`fix/`, `docs/`).
- No hay publicación en tiendas ([ADR-014](../01-architecture/decisions/records/ADR-014-distribucion-github-releases.md)):
  si se adjunta un APK de depuración, va en el GitHub Release de `v1.0.0` de `beauty-salon-app`.
