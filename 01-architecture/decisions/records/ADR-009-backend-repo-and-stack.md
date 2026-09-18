# ADR-009 — Repo y stack del backend (API)

- **ID:** ADR-009
- **Fecha:** 2026-09-18
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

Hasta ahora ManiCita no tenía backend real: el contrato de API vivía únicamente como diseño
*stubbed* en [`03-api-and-data/endpoints/`](../../03-api-and-data/endpoints/), servido con un mock
local durante el desarrollo, tal como lo admite la
[Definition of Ready](../../00-governance/definition-of-ready.md). La Decisión 6 del
[README principal](../../README.md) registraba explícitamente que el backend "no existe todavía".

El profesor de la asignatura indicó que el repositorio `beauty-salon` (el repo original del
proyecto, org `code-corhuila`) debe usarse como el **repo de la API**, no como el repo de código
del frontend. Esto contradice la limpieza hecha el 2026-09-17 ([commit `03ca05b`](https://github.com/code-corhuila/beauty-salon/commit/03ca05b)),
que dejó `beauty-salon` listo como repo de frontend Ionic + Capacitor (ver
[ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md)) y borró de él la copia antigua del framework
de documentación.

El curso exige repos separados por *concern* (docs, frontend, backend/api). Con `beauty-salon`
reasignado a la API, el código del frontend necesita un repo propio nuevo, que todavía no se ha
creado.

**Restricciones conocidas:**
- Equipo de dos personas, un semestre, sin presupuesto para servicios pagos.
- El contrato de API ya está completamente diseñado (12 endpoints documentados en
  `03-api-and-data/endpoints/`); el backend real debe implementar exactamente ese contrato, no
  rediseñarlo.
- `beauty-salon` ya tiene historial de git en GitHub (`code-corhuila/beauty-salon`) que se
  conserva; no se crea un repo nuevo para la API.

---

## Decisión

**Se decidió:**
1. `beauty-salon` pasa a ser el **repo de código de la API**, no el de frontend.
2. Stack de la API: **Node.js + Express + PostgreSQL**.
3. El código del frontend (Ionic React + Capacitor, [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md))
   se mueve a un **repo nuevo, aún sin crear ni nombrar**.

**Justificación:**
Con repos separados por *concern* exigidos por el curso, y con `beauty-salon` asignado
específicamente a la API por indicación del profesor, no tiene sentido que ese mismo repo siga
sirviendo como frontend: se necesita un repo dedicado nuevo para eso. Para el stack de la API se
eligió Express sobre alternativas "todo incluido" (como Supabase) porque el objetivo de este
entregable es que el equipo diseñe y exponga la API explícitamente (rutas, controladores,
validación, acceso a datos) en vez de que quede autogenerada — eso es lo que un repo de API
dedicado, pedido explícitamente por el profesor, está señalando que se evalúa. PostgreSQL se elige
por ser la base relacional estándar con Express y porque el modelo de datos de ManiCita (negocios,
profesionales, servicios, citas con cupos) es relacional por naturaleza, igual que ya se decidió
para el almacenamiento local en [ADR-007](./ADR-007-local-storage-capacitor.md).

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Node.js + Express + PostgreSQL (elegida) | El equipo diseña y expone la API explícitamente (rutas, controladores, validación); PostgreSQL relacional encaja con el modelo de datos; JavaScript/TypeScript consistente con el frontend | Hay que construir auth, migraciones y acceso a datos a mano, sin nada "gratis" | — (elegida) |
| Supabase (Postgres + Auth + API autogenerada) | Mucho más rápido de levantar; ya había experiencia previa del equipo con Supabase en `beauty-salon-app` | La API queda autogenerada por Supabase; lo que el equipo construye a mano queda reducido a Edge Functions, difícil de sustentar como "hicimos la API" cuando el profesor pidió un repo de API dedicado | El repo de API se pidió explícitamente como entregable propio; una API autogenerada no demuestra ese trabajo |
| Mantener `beauty-salon` como frontend y crear un repo nuevo para la API | No hay que reescribir el README ni el historial reciente de `beauty-salon` | Contradice directamente la indicación del profesor sobre qué repo usar para la API | El profesor fue explícito: `beauty-salon` es el repo de la API |

---

## Consecuencias

**Positivas:**
- La estructura de repos queda alineada con lo que pidió el profesor: `beauty-salon-docs` (docs),
  `beauty-salon` (API), y un repo nuevo por crear (frontend).
- El contrato ya diseñado en `03-api-and-data/endpoints/` se implementa tal cual, sin rediseño.

**Negativas / Costos:**
- El trabajo de limpieza y el README escritos en `beauty-salon` el 2026-09-17 para convertirlo en
  frontend quedan descartados; hay que reescribir el README de ese repo para su nuevo rol de API.
- Se necesita crear y nombrar un repo nuevo para el frontend antes de poder arrancar la Fase 0 de
  [`plan-implementacion-login-catalogo.md`](../plan-implementacion-login-catalogo.md).
- El estado "backend no existe" de la Decisión 6 del README y de
  [`03-api-and-data/README.md`](../../03-api-and-data/README.md) /
  [`api-networking.md`](../../03-api-and-data/api-networking.md) queda desactualizado: ahora hay
  repo y stack decididos, aunque el código todavía no está escrito.

**Impacto en el sistema:**
- Documentos a actualizar: [`README.md`](../../README.md) (Decisión 6), `01-architecture/README.md`,
  [`plan-implementacion-login-catalogo.md`](../plan-implementacion-login-catalogo.md) (el repo de
  código que referencia ya no es `beauty-salon`), [`03-api-and-data/README.md`](../../03-api-and-data/README.md)
  y [`api-networking.md`](../../03-api-and-data/api-networking.md) (estado del backend).
- Repo `beauty-salon`: reescribir su `README.md` para reflejar su nuevo rol de API.

---

## Referencias

- Relacionada con: [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) (stack del frontend, que
  ahora vive en un repo aparte), [ADR-007](./ADR-007-local-storage-capacitor.md) (SQLite/Drizzle,
  mismo enfoque relacional del lado del cliente)
- `03-api-and-data/endpoints/` — contrato de API ya diseñado, a implementar tal cual
