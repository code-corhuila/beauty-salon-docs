# Convenciones de Git

> Estas reglas rigen los **repositorios de código** de ManiCita: `beauty-salon-app`,
> `beauty-salon-api` y `beauty-salon-infra`.
> Este repositorio de documentación es la excepción declarada en el [README raíz](../README.md):
> no usa ramas, todo se commitea directo a `main`.

> **Actualizado el 2026-10-28 para el proyecto de aula del corte 3 (c3-project).** La guía del curso
> califica la etiqueta `v1.0.0` en `main` de cada repositorio de código y recomienda trabajar cada
> tarea en una rama `feat/` o `fix/` unida por Pull Request. Desde esta fecha **nadie commitea
> directo a `main`** en app, api ni infra: todo entra por PR. La decisión y sus alternativas están en
> [ADR-016](../01-architecture/decisions/records/ADR-016-ramas-feat-fix-con-pr.md).

## Ramas

- Desarrollo trunk-based con ramas cortas que salen de `main` y vuelven a `main`.
- **Una rama por historia de usuario o por arreglo.** Nombre: `<tipo>/hu-<NN>-<resumen>` o
  `<tipo>/<scope>-<resumen>` cuando no hay historia.
  - Tipos: `feat`, `fix`, `chore`, `test`, `docs`.
  - Ejemplos: `feat/hu-12-logout`, `feat/hu-15-crud-profesionales`, `fix/catalog-empty-state`.
- Las ramas no se crean por adelantado: se abren al empezar la historia y se borran al hacer merge.
- Una rama vive pocos días. Antes de abrir el PR se actualiza con `main` (`git pull origin main`).
- **`develop` y `qa` de `beauty-salon-api` no se usan.** Las creó el docente el 2026-09-01 con solo un
  commit inicial y no comparten historia con `main`. No se borran (no son del equipo), pero no se
  promueve código por ellas.

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
- Al menos una aprobación. **Merge commit** hacia `main` (botón *Create a merge commit*), **no
  squash**: el squash junta los commits en uno solo a nombre de quien hace el merge y borra la
  autoría de cada integrante, que la guía del curso califica.

> Con un equipo de dos, la aprobación la da quien **no** escribió el PR, y el docente la ratifica en
> la revisión. La regla no se elimina: se declara quién aprueba. Un PR sin aprobación no entra a
> `main`.

## Releases

- Versión con [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`.
- Los releases se etiquetan `vX.Y.Z` sobre `main`, con la misma versión en los tres repositorios de
  código.
- **`v1.0.0` es la entrega del c3-project:** etiqueta en `main` de `beauty-salon-app`,
  `beauty-salon-api` y `beauty-salon-infra` antes del **2026-11-15 23:59**, después de la sustentación
  del 2026-11-09. Tras la sustentación solo entran correcciones y documentación (`fix/`, `docs/`).
- No hay publicación en tiendas ([ADR-014](../01-architecture/decisions/records/ADR-014-distribucion-github-releases.md)):
  si se adjunta un APK de depuración, va en el GitHub Release de `v1.0.0` de `beauty-salon-app`.
