# ADR-010 — Monorepo temporal: backend y frontend en `beauty-salon`

- **ID:** ADR-010
- **Fecha:** 2026-09-18
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

[ADR-009](./ADR-009-backend-repo-and-stack.md) dejó `beauty-salon` como el repo de la API por
indicación explícita del profesor, y registró que el curso exige **repos separados por concern**
(docs, backend, frontend), con el repo de frontend (Ionic React + Capacitor,
[ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md)) todavía **sin crear**.

Para poder arrancar la Fase 0 de [`plan-implementacion-login-catalogo.md`](../plan-implementacion-login-catalogo.md)
sin esperar a que se cree y nombre ese repo nuevo, el equipo decidió que esta **primera versión**
(v1/MVP) trabaje bajo un esquema de **monorepo**: backend y frontend comparten el mismo repositorio
(`beauty-salon`), pero en carpetas distintas, para conservar la separación de responsabilidades a
nivel de código aunque no a nivel de repo.

**Restricciones conocidas:**
- Equipo de dos personas, un semestre, sin tiempo de sobra para esperar la creación de un tercer
  repo antes de poder avanzar en el frontend.
- El curso exige repos separados por concern; este esquema es una **excepción temporal**, no un
  reemplazo permanente de esa exigencia.
- El backend ya implementado (13 endpoints, dockerizado) no debe perder su historial de git ni
  romperse durante la reorganización.

---

## Decisión

**Se decidió:**
1. `beauty-salon` pasa a ser un **monorepo** para la v1: mismo repositorio, con carpetas
   `backend/` (todo lo implementado bajo ADR-009: `src/`, `Dockerfile`, `docker-compose.yml`,
   `package.json`, etc.) y `frontend/` (proyecto Ionic React + Capacitor nuevo, ADR-005), cada una
   con su propio `README.md`.
2. El servicio de base de datos (PostgreSQL) se mantiene como **servicio de docker-compose dentro
   de `backend/`**, no como repo ni carpeta aparte.
3. **Se planea migrar** en una próxima iteración/release al esquema original de ADR-009: un repo
   por `backend`, uno por `frontend`, y evaluar en ese momento si la base de datos amerita su
   propio repo (p. ej. migraciones versionadas de forma independiente) o si se mantiene como
   servicio del backend. Esta ADR no cierra esa evaluación, solo la deja pendiente.

**Justificación:**
Dividir en tres repos desde ya requiere que el profesor cree y nombre el repo de frontend antes de
poder escribir una sola línea de esa parte, lo cual bloquea el avance del equipo sin necesidad:
nada en el contrato de API ni en el plan de trabajo depende de que el código viva en repos
separados, solo el *entregable final* del curso lo exige. Mantener carpetas separadas dentro del
mismo repo conserva la disciplina de responsabilidades (nada de mezclar código de UI con
controladores de la API en el mismo directorio) sin bloquear el trabajo, y deja la migración a
repos separados como una operación mecánica (cada carpeta ya es una unidad autocontenida que se
puede extraer con `git subtree split` conservando su historial).

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Monorepo con carpetas `backend/` y `frontend/` (elegida) | Se puede empezar el frontend ya, sin esperar un repo nuevo; separación de responsabilidades a nivel de carpeta; migración futura mecánica (`git subtree split`) | Contradice temporalmente la exigencia del curso de repos separados; hay que recordar deshacerlo | — (elegida) |
| Esperar a que el profesor cree el repo de frontend antes de avanzar | Cumple ADR-009 y la exigencia del curso desde el día uno | Bloquea todo avance de frontend por tiempo indefinido, sin justificación técnica real | El equipo tiene un semestre limitado; no hay razón técnica para bloquear el trabajo por un repo aún no creado |
| Crear un repo de frontend nuevo por cuenta propia, sin esperar al profesor | Cumple repos separados sin bloquear el avance | El profesor es quien crea y nombra los repos del proyecto en `code-corhuila`; crear uno por fuera de ese proceso puede duplicar o desalinear lo que el profesor arme después | Va contra la forma de trabajo ya establecida con el profesor para este curso |

---

## Consecuencias

**Positivas:**
- El equipo puede arrancar la Fase 0 del frontend ([`plan-implementacion-login-catalogo.md`](../plan-implementacion-login-catalogo.md))
  de inmediato, sin depender de que se cree un repo nuevo.
- El backend conserva su historial de git; solo se reubican sus archivos dentro de `backend/`.

**Negativas / Costos:**
- Mientras dure el monorepo, `beauty-salon` no cumple literalmente la exigencia de "repos
  separados por concern" del curso — hay que estar preparados para explicarlo si se pregunta, y
  no olvidar la migración pendiente.
- Los README de `beauty-salon` (raíz, `backend/`, `frontend/`) deben mantenerse claros sobre cuál
  carpeta es cuál, para no confundir a quien revise el repo.

**Impacto en el sistema:**
- Documentos actualizados junto con esta ADR: [`README.md`](../../README.md) (Decisión 6),
  [`01-architecture/README.md`](../README.md),
  [`plan-implementacion-login-catalogo.md`](../plan-implementacion-login-catalogo.md) (el repo de
  código del frontend ya no está "sin crear": es `beauty-salon/frontend/`).
- Repo `beauty-salon`: reorganizar `src/`, `Dockerfile`, `docker-compose.yml`, `package.json` y
  demás archivos de la API dentro de `backend/`; crear `frontend/` con el scaffold Ionic + Capacitor
  de la Fase 0; reescribir el `README.md` raíz para explicar el layout monorepo.

---

## Referencias

- Reemplaza temporalmente la parte de repos separados de [ADR-009](./ADR-009-backend-repo-and-stack.md)
  (el stack y la asignación de `beauty-salon` como backend siguen vigentes; lo que cambia es que el
  frontend también vive ahí, por ahora).
- Relacionada con: [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) (stack del frontend, que
  ahora arranca dentro de `beauty-salon/frontend/` en vez de un repo aparte).
- [`plan-implementacion-login-catalogo.md`](../plan-implementacion-login-catalogo.md) — Fase 0 se
  ejecuta dentro de `beauty-salon/frontend/`.
