# ADR-011 — Cuatro repositorios: docs, infra, api y app

- **ID:** ADR-011
- **Fecha:** 2026-09-25
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo
- **Reemplaza a:** [ADR-010](./ADR-010-monorepo-temporal.md)

---

## Contexto

[ADR-010](./ADR-010-monorepo-temporal.md) dejó la v1 como **monorepo temporal**: `beauty-salon`
con carpetas `backend/` y `frontend/`, y el `docker-compose.yml` dentro de `backend/`. Dejó
explícitamente pendiente la migración a repos separados y la evaluación de dónde debía vivir la
base de datos.

El 2026-09-25 el profesor publicó el **Manual de contrato de datos y API** (Programación Móvil,
2026-B), que cierra esa evaluación para todos los proyectos del curso:

- Un proyecto vive en **cuatro repositorios** con la misma abreviatura: `<abbr>-docs`,
  `<abbr>-infra`, `<abbr>-api` y `<abbr>-app` (manual §2.1).
- **El esquema es propiedad del servicio:** lo crea y lo evoluciona el repo de la API con
  migraciones que viven en él. El repo de infraestructura entrega un motor **vacío** (manual §2.3).
- Los tres repos ejecutables se clonan **como hermanos**; infra construye apuntando a `../`
  (manual §2.5).

Ese mismo día quedaron creados `beauty-salon-app` y `beauty-salon-infra` en `code-corhuila`, y el
repo de la API se renombró de `beauty-salon` a `beauty-salon-api`.

---

## Decisión

**Se decidió:**

| Repositorio | Contenido | Viene de |
|-------------|-----------|----------|
| `beauty-salon-docs` | La especificación (sin cambios) | — |
| `beauty-salon-infra` | `docker-compose.yml` (PostgreSQL + API), `.env.example` sin valores | `beauty-salon/backend/docker-compose.yml` |
| `beauty-salon-api` | La API **y el esquema** (`src/db/`), su `Dockerfile` | `beauty-salon/backend/`, movido a la raíz |
| `beauty-salon-app` | La app Ionic React + Capacitor | `beauty-salon/frontend/` |

1. **El esquema se queda en `beauty-salon-api`.** Infra no lleva `init.sql`, DDL ni datos semilla:
   la API aplica su esquema al arrancar (`node src/db/migrate.js && node src/server.js`).
2. **El `Dockerfile` se queda en la API**, porque describe cómo se construye ese servicio; infra solo
   lo referencia con `build: ../beauty-salon-api`.
3. **Ningún secreto en ningún repo.** Las credenciales de PostgreSQL y los secretos JWT dejan de
   estar escritos en el compose y pasan a `.env` (ignorado por git), con `.env.example` sin valores.
4. La API se mueve con `git mv`, así que **conserva su historia**. El frontend se copia al repo nuevo
   desde el último commit de `main`; su historia previa queda consultable en `beauty-salon-api`.

**Justificación:** es la estructura que exige el manual, y resuelve las dos razones medibles que
da para que el esquema no viva en infra: un script de inicialización del contenedor solo corre con
el volumen vacío (la segunda versión del esquema nunca se aplicaría, y el fallo sería silencioso), y
dos repos no pueden cambiar la misma tabla.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Cuatro repos, esquema en la API (elegida) | Cumple el manual; cada repo se despliega sin tocar a los otros; un solo dueño del esquema | Hay que clonar cuatro repos como hermanos; la historia del frontend queda en otro repo | — (elegida) |
| Mantener el monorepo de ADR-010 | Cero trabajo de migración | Incumple §2.1 del manual; ADR-010 ya lo declaraba temporal | La excepción temporal ya no tiene razón de ser: los repos existen |
| Esquema como `init.sql` en `beauty-salon-infra` | La base "llega lista" sin correr nada en la API | Solo se ejecuta con el volumen vacío; dos repos tocarían la misma tabla | Prohibido expresamente por el manual (§2.3, §2.4 y Anexo E #5) |
| Extraer el frontend con `git subtree split` | Conserva la historia del frontend en `beauty-salon-app` | Reescribe commits y exige empujar historia a un repo que ya tiene su commit inicial | La historia no se pierde (sigue en `beauty-salon-api`) y la copia desde `main` es más simple y segura |

---

## Consecuencias

**Positivas:**
- La estructura coincide con la que se revisa en la sustentación (manual §2 y Anexo D, "Reparto de
  repositorios", 15 puntos).
- El compose ya no tiene contraseñas escritas.

**Negativas / Costos:**
- El volumen de datos cambia de nombre (el proyecto de compose ahora es `beauty-salon-infra`): la
  primera vez se arranca con una base vacía.
- La historia del frontend no está en `beauty-salon-app`; su README lo aclara.

**Pendiente, fuera de esta ADR:**
- `src/db/migrate.js` aplica hoy un único `schema.sql` con `CREATE ... IF NOT EXISTS`. Eso no
  son migraciones versionadas: un cambio de columna nunca se aplicaría sobre una base existente.
  Se resolvió el mismo día en [ADR-012](./ADR-012-nombres-en-ingles.md).

**Impacto en el sistema:**
- Documentos actualizados junto con esta ADR: [`README.md`](../../../README.md) (Decisión 6),
  [`01-architecture/README.md`](../../README.md),
  [`plan-implementacion-login-catalogo.md`](../../plan-implementacion-login-catalogo.md) y el
  registro de ADRs.
- READMEs reescritos en `beauty-salon-api`, `beauty-salon-app` y `beauty-salon-infra`.

---

## Referencias

- Reemplaza a [ADR-010](./ADR-010-monorepo-temporal.md).
- Mantiene vigentes [ADR-009](./ADR-009-backend-repo-and-stack.md) (stack de la API) y
  [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) (stack de la app).
- Manual de contrato de datos y API, Programación Móvil 2026-B — §2.1, §2.3, §2.4, §2.5 y §2.6.
