# ADR-016 — Flujo de ramas del c3-project: `feat/` y `fix/` con Pull Request y merge commit hacia `main`

- **ID:** ADR-016
- **Fecha:** 2026-10-28
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

Desde el 2026-09-18 el equipo commiteaba **directo a `main`** en los repositorios de código, por
autorización del docente: con el monorepo temporal ([ADR-010](./ADR-010-monorepo-temporal.md)) y
luego con la separación en cuatro repositorios ([ADR-011](./ADR-011-cuatro-repositorios.md)), las
ramas y los PR frenaban más de lo que aportaban a un equipo de dos. `git-conventions.md` describía
ramas cortas y PR, pero en la práctica no se usaban.

El 2026-10-28 llegó la guía del **proyecto de aula del corte 3 (c3-project)**, que cambia lo que se
evalúa:

- Se califica la **etiqueta `v1.0.0` en la rama `main`** de `beauty-salon-app`, `beauty-salon-api`
  y `beauty-salon-infra`.
- Se **recomienda** trabajar cada tarea en una rama `feat/` o `fix/` y unirla por Pull Request; el
  repositorio de documentación sigue con su política de una sola rama.
- El ítem 10 de la lista de chequeo exige que **cada integrante tenga commits propios en los
  repositorios de código, repartidos en varios días**. Sin commits propios la nota individual es
  0,0; con trabajo "de golpe", tope de 3,0.
- En la sustentación el docente le pregunta a cada integrante por el código que lleva su nombre en
  los commits.

Además, `beauty-salon-api` tiene ramas `develop` y `qa` que creó el docente el 2026-09-01 con solo un
commit inicial; no comparten historia con `main` y nunca se dio una instrucción sobre ellas. La guía
del c3-project no las menciona.

**Restricciones conocidas:**
- Equipo de dos: quien revisa un PR es siempre la otra integrante.
- No hay CI todavía ([ADR-014](./ADR-014-distribucion-github-releases.md) la planea, no está
  construida): la verificación antes de unir es local.
- La autoría de cada commit tiene que sobrevivir al merge, porque es lo que se califica.

---

## Decisión

**Decidimos:** en los tres repositorios de código, **todo cambio entra a `main` por Pull Request**
desde una rama corta `feat/hu-NN-resumen` o `fix/scope-resumen`, una por historia o arreglo, y se une
con **merge commit**, no con squash ni rebase. Nadie commitea directo a `main`. `develop` y `qa` no
se usan. El repositorio de documentación sigue commiteando directo a `main`. Las reglas operativas
están en [`git-conventions.md`](../../../00-governance/git-conventions.md).

**Justificación:**
- Es lo que la guía del curso recomienda y lo que se evalúa (`v1.0.0` en `main`).
- El **merge commit** conserva cada commit con su autora original. Un squash los junta en uno solo a
  nombre de quien aprieta el botón, y borraría justo la evidencia que pide el ítem 10.
- Un PR por historia deja en GitHub quién hizo qué, cuándo y quién lo revisó: sirve de evidencia para
  el FO-IV-159 (metodología: tablero, ramas y reparto) y para preparar las preguntas de la
  sustentación.
- Promover por `develop` → `qa` → `main` agrega dos merges por historia sin un ambiente de QA real
  detrás; para un equipo de dos y tres semanas no paga su costo.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| `feat/`/`fix/` + PR + merge commit (elegida) | Conserva la autoría de cada commit; un PR por historia; coincide con la guía | Un paso más que commitear directo; la historia de `main` tiene commits de merge | — (elegida) |
| Seguir commiteando directo a `main` | Lo más rápido; es lo que se hacía desde el 2026-09-18 | No hay revisión; no queda rastro de qué commit es de qué historia; contradice la recomendación de la guía | La guía cambió las condiciones que justificaban la autorización |
| `feat/` + PR + **squash merge** | `main` queda con un commit por historia, limpio de leer | Todos los commits de la rama quedan a nombre de quien hace el merge | Borra la autoría individual, que es lo que el ítem 10 califica |
| Git flow con `develop` y `qa` (las ramas que creó el docente) | Separa integración, pruebas y producción | Dos merges extra por historia; `develop` y `qa` no comparten historia con `main` y habría que forzarlas o unir historias no relacionadas; no hay ambiente de QA | Costo alto sin beneficio real en este tamaño de equipo; la guía no lo pide |

---

## Consecuencias

**Positivas:**
- Cada integrante tiene commits propios y visibles, repartidos en el tiempo.
- Cada historia tiene un PR que la enlaza (`Closes #NN`), y el tablero se cierra solo al unir.
- Hay una revisión de la otra integrante antes de que algo llegue a `main`.

**Negativas / costos:**
- Más pasos por historia (crear rama, abrir PR, aprobar, unir, borrar la rama).
- Sin CI, la verificación depende de que quien abre el PR corra lint, pruebas y smoke test y lo
  declare en la descripción.
- `develop` y `qa` quedan en `beauty-salon-api` sin uso. No se borran porque no son del equipo.

**Impacto en el sistema:**
- Repositorios afectados: `beauty-salon-app`, `beauty-salon-api`, `beauty-salon-infra`.
- Documento que la aplica: [`00-governance/git-conventions.md`](../../../00-governance/git-conventions.md).

---

## Referencias

- Guía "Proyecto de aula del corte 3" (Programación Móvil 2026-B, c3-project), secciones 6 (Ramas) y
  11 (ítem 10) y 12 (reglas de integridad).
- [GitHub: acerca de los métodos de merge](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/about-merge-methods-on-github)
- Relacionada con: [ADR-011](./ADR-011-cuatro-repositorios.md) (los tres repositorios de código), [ADR-014](./ADR-014-distribucion-github-releases.md) (releases etiquetados sobre `main`)
