# CI/CD

Cómo un commit en `main` se convierte en un APK que la manicurista instala. La plataforma de CI y
el canal de distribución se eligieron en
[ADR-014](../01-architecture/decisions/records/ADR-014-distribucion-github-releases.md).

## Principios

- **Los artefactos que se entregan salen de CI**, nunca del portátil de alguien: el APK que se
  adjunta a un GitHub Release lo construye GitHub Actions a partir del tag.
- Dos entornos de build, no tres: `development` y `production` (modos de Vite). Con un equipo de dos
  y sin servidor propio no hay un `staging` que mantener; la manicurista aliada prueba el build de
  producción antes que nadie (ver [`signing-and-stores.md`](./signing-and-stores.md)).
- Toda variable de entorno (URL de la API) se inyecta en tiempo de build con `VITE_*`; nunca va
  escrita en el código. Ninguna variable `VITE_*` es secreta: termina dentro del APK.

---

## Pipelines por repositorio

Cada repo de código tiene su propio pipeline en `.github/workflows/`. El repo de docs y el de infra
no tienen CI.

### `beauty-salon-app`

| # | Etapa | Comando | Falla si |
|---|-------|---------|----------|
| 1 | Instalar | `npm ci` | — |
| 2 | Lint | `npm run lint -- --max-warnings=0` | Hay una sola advertencia |
| 3 | Tipos | `npx tsc --noEmit` | Hay un error de tipos |
| 4 | Unitarias y de componente | `npx vitest run --coverage` | Falla una prueba o `domain/` baja de 80% |
| 5 | Build web | `npm run build` | No compila, o el JavaScript inicial pasa de 400 KB gzip ([presupuesto](../04-quality/performance-budgets.md)) |
| 6 | APK firmado | `npx cap sync android` y `./gradlew assembleRelease` con Java 21, firmando con la llave de los secretos de CI | — |
| 7 | Publicar | Adjunta el `.apk` al GitHub Release del tag | — |

### `beauty-salon-api`

| # | Etapa | Comando | Falla si |
|---|-------|---------|----------|
| 1 | Instalar | `npm ci` | — |
| 2 | Unitarias | `node --test` | Falla una prueba |
| 3 | Integración | Levanta PostgreSQL 16 como `services:` del job, corre `npm run migrate`, arranca la API y ejecuta `pwsh scripts/smoke-test.ps1` (PowerShell 7 viene instalado en los runners de Ubuntu) | Falla una de las sondas |
| 4 | Publicar | `release.yml`: crea el GitHub Release con notas generadas | — |

---

## Disparadores

| Evento | App | API |
|--------|-----|-----|
| Push a `main` o PR hacia `main` (`ci.yml`) | Etapas 1–5 | Etapas 1–3 |
| Tag `vX.Y.Z` (`release.yml`) | Etapas 1–7 | Etapas 1–4 |
| Antes del tag, a mano | Cypress (`npm run test.e2e`) contra la API de `beauty-salon-infra` y los [casos de prueba](../04-quality/test-cases/) que apliquen | — |

> El tag se crea sobre `main` según [`git-conventions.md`](../00-governance/git-conventions.md).
> App y API se versionan **por separado**: una corrección de la API no obliga a sacar otro APK.

---

## Entornos

| Modo de Vite | Archivo | `VITE_API_BASE_URL` | Para qué |
|--------------|---------|---------------------|----------|
| `development` | `.env.development` (no versionado) | `http://localhost:3000/v1` en el navegador; `http://10.0.2.2:3000/v1` en el emulador de Android, que es como el emulador ve el `localhost` del computador | `npm run dev` y builds de depuración |
| `production` | `.env.production`, generado en CI desde las variables del repositorio | La URL **HTTPS** de la API desplegada | El APK que se publica |

> **Bloqueo conocido:** la API no tiene despliegue ni URL de producción (hueco H-01 de
> [`api-contract.md`](../03-api-and-data/api-contract.md)). Hasta que exista, un APK de producción
> no tiene a dónde apuntar, y los builds que se muestran en clase son de depuración contra la API
> local.

---

## Estado real al 2026-10-07

| Qué | Estado |
|-----|--------|
| `release.yml` de la API | ✅ existe: con cada tag `v*.*.*` crea el GitHub Release con notas generadas. Aún no se ha creado ningún tag |
| `ci.yml` de la API (pruebas y smoke test) | ⏳ no existe |
| `ci.yml` de la app (lint, tipos, pruebas, build) | ⏳ no existe |
| `release.yml` de la app (APK firmado) | ⏳ no existe; depende de la llave de release (ver [`signing-and-stores.md`](./signing-and-stores.md)) |
| Script `test` | ⚠️ la app no tiene `npm test`: sus scripts son `test.unit` y `test.e2e` (los del andamiaje de Ionic). La DoD usa esos nombres |

| ID | Qué falta | Responsable | Fecha |
|----|-----------|-------------|-------|
| R-01 | `ci.yml` de la API con PostgreSQL de servicio y el smoke test | _por asignar_ | _por asignar_ |
| R-02 | `ci.yml` de la app con lint, tipos, Vitest y build | _por asignar_ | _por asignar_ |
| R-03 | `release.yml` de la app que firme y adjunte el APK | _por asignar_ | _por asignar_ |
| R-04 | Desplegar la API con HTTPS (H-01) | _por asignar_ | _por asignar_ |
