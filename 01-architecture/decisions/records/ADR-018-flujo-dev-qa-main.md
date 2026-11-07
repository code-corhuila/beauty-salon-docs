# ADR-018 — Flujo de promoción `feat/` y `fix/` → `dev` → `qa` → `main`

- **ID:** ADR-018
- **Fecha:** 2026-11-06
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo
- **Reemplaza a:** [ADR-016](./ADR-016-ramas-feat-fix-con-pr.md) en el destino de los PR y en el uso de
  `develop` y `qa`. Se mantienen las ramas cortas `feat/` y `fix/` y el merge commit.

---

## Contexto

[ADR-016](./ADR-016-ramas-feat-fix-con-pr.md) definió que cada rama `feat/` o `fix/` entrara
directo a `main` por Pull Request, sin usar `develop` ni `qa`. Esa decisión se tomó con la guía del
c3-project, que solo recomendaba ramas y PR y no mencionaba ramas padres.

El 2026-11-06 la retroalimentación del docente sobre el avance hacia la Fase 1 cambió lo que se
evalúa en la entrega, en `beauty-salon-app`, `beauty-salon-api` y `beauty-salon-infra`:

- Las tres ramas padres **`dev`, `qa` y `main`** en cada repositorio de código, con el flujo
  `feat/` o `fix/` → `dev` → `qa` → `main`.
- Cada tarea entra por PR con descripción y **revisión de la otra integrante antes de fusionar**.
- Etiqueta `v1.0.0` sobre `main` en los tres repositorios.
- El flujo nuevo debe quedar registrado en un ADR y en `git-conventions.md`.

**Estado de partida:**

| Repositorio | Ramas padres hoy |
|-------------|------------------|
| `beauty-salon-app` | Solo `main` |
| `beauty-salon-infra` | Solo `main` |
| `beauty-salon-api` | `main`, más `develop` y `qa` con solo un commit inicial, sin historia común con `main` |

**Restricciones conocidas:**
- La autoría de cada commit tiene que sobrevivir a todos los merges, porque se califica.
- `develop` y `qa` de la API las creó el docente: no se reescribe su historia a la fuerza.
- No hay CI ([ADR-014](./ADR-014-distribucion-github-releases.md) la planea, no está construida): la
  verificación antes de unir sigue siendo local.

---

## Decisión

**Decidimos:** en los tres repositorios de código, todo cambio nace en una rama `feat/` o `fix/`
creada desde `dev` y se promueve `feat/` o `fix/` → `dev` → `qa` → `main`, siempre por PR y con
**merge commit**. Cada PR lleva la revisión de la integrante que no lo escribió. El nombre de la
rama de integración es **`dev`**, el que indicó el docente. `v1.0.0` se etiqueta sobre `main`. El
repositorio de documentación sigue en una sola rama. Las reglas operativas están en
[`git-conventions.md`](../../../00-governance/git-conventions.md).

**Justificación:**
- Es lo que pide el docente para la entrega y lo que se evaluará como evidencia.
- El merge commit conserva la autoría de cada commit también al pasar por `dev` y `qa`.
- `qa` da un punto fijo para probar desde un clon limpio antes de llegar a `main`.
- Unir `main` a `qa` en la API con `--allow-unrelated-histories` no reescribe nada de lo que creó el
  docente, a diferencia de un push forzado.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| `feat/` o `fix/` → `dev` → `qa` → `main` (elegida) | Cumple lo pedido; separa integración, prueba y entrega; conserva la autoría | Dos PR más por cada promoción | — (elegida) |
| Mantener ADR-016 (directo a `main`) | Menos pasos | Contradice la instrucción del docente | La retroalimentación cambió las condiciones |
| Usar `develop` como rama de integración en la API y `dev` en los otros dos | No crea una rama nueva en la API | Nombres distintos entre repositorios y distintos a los de la instrucción | Un solo nombre en los tres repositorios es más claro |
| Reemplazar `develop` y `qa` de la API con un push forzado | Historia lineal con `main` | Reescribe ramas que creó el docente | Innecesario: el merge conserva todo |

---

## Consecuencias

**Positivas:**
- Los tres repositorios quedan con la misma estructura y el mismo flujo.
- Queda evidencia en GitHub de cada tarea, de su revisión y de su promoción hasta `main`.

**Negativas / costos:**
- Más PR por tarea. Para no multiplicarlos, `dev` → `qa` → `main` se promueve por grupos de tareas
  terminadas y no por cada historia.
- `develop` de `beauty-salon-api` queda sin uso. No se borra sin consultarlo con el docente.
- La revisión exige que la otra integrante esté disponible antes de cada merge.

**Impacto en el sistema:**
- Repositorios afectados: `beauty-salon-app`, `beauty-salon-api`, `beauty-salon-infra`.
- Documento que la aplica: [`00-governance/git-conventions.md`](../../../00-governance/git-conventions.md).

---

## Referencias

- Retroalimentación del docente «Avance hacia la Fase 1 (Funcionalidad)», 2026-11-06, sección 6.
- Reemplaza parcialmente a: [ADR-016](./ADR-016-ramas-feat-fix-con-pr.md).
- Relacionada con: [ADR-014](./ADR-014-distribucion-github-releases.md) (releases etiquetados sobre `main`).
