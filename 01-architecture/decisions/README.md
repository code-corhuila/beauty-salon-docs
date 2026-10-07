# ADRs — Registros de Decisiones de Arquitectura

Una ADR documenta una decisión de arquitectura importante. Un archivo = una decisión.

## Cómo se crea una ADR

1. Se copia `_template-adr.md` (la plantilla no se edita).
2. Se guarda como `records/ADR-NNN-titulo-corto.md`, con numeración secuencial.
3. Se llena completa, en especial la tabla de **alternativas evaluadas**: una ADR sin alternativas
   descartadas no es una decisión, es una preferencia.
4. Una vez aceptada, el estado es permanente: una ADR no se borra, se marca como `Superseded` por
   la ADR que la reemplaza.

## Estados posibles

- `Proposed` — en discusión
- `Accepted` — aprobada
- `Rejected` — evaluada y descartada (se documenta por qué)
- `Superseded` — reemplazada por la ADR-NNN que se indique

## Registro de ADRs

| # | Título | Estado | Fecha |
|---|--------|--------|-------|
| [ADR-001](./records/ADR-001-state-management-pattern.md) | Patrón de manejo de estado | Superseded by ADR-006 | 2026-09-07 |
| [ADR-002](./records/ADR-002-mobile-stack.md) | Stack de desarrollo móvil | Superseded by ADR-005 | 2026-09-07 |
| [ADR-003](./records/ADR-003-local-storage.md) | Almacenamiento local | Superseded by ADR-007 | 2026-09-07 |
| [ADR-004](./records/ADR-004-dependency-injection.md) | Inyección de dependencias | Superseded by ADR-008 | 2026-09-07 |
| [ADR-005](./records/ADR-005-mobile-stack-ionic-capacitor.md) | Stack de desarrollo móvil (revisión: Ionic + Capacitor, solo Android) | Accepted | 2026-09-17 |
| [ADR-006](./records/ADR-006-state-management-pattern.md) | Patrón de manejo de estado (reafirmación) | Accepted | 2026-09-17 |
| [ADR-007](./records/ADR-007-local-storage-capacitor.md) | Almacenamiento local (revisión: SQLite vía Capacitor) | Accepted | 2026-09-17 |
| [ADR-008](./records/ADR-008-dependency-injection.md) | Inyección de dependencias (reafirmación) | Accepted | 2026-09-17 |
| [ADR-009](./records/ADR-009-backend-repo-and-stack.md) | Repo y stack del backend (API) | Accepted | 2026-09-18 |
| [ADR-010](./records/ADR-010-monorepo-temporal.md) | Monorepo temporal: backend y frontend en `beauty-salon` | Superseded by ADR-011 | 2026-09-18 |
| [ADR-011](./records/ADR-011-cuatro-repositorios.md) | Cuatro repositorios: docs, infra, api y app | Accepted | 2026-09-25 |
| [ADR-012](./records/ADR-012-nombres-en-ingles.md) | Todos los identificadores en inglés, y migraciones versionadas en la API | Accepted | 2026-09-25 |
| [ADR-013](./records/ADR-013-herramientas-de-prueba.md) | Herramientas de prueba: Vitest y Cypress en la app, `node:test` y smoke test en la API | Accepted | 2026-10-07 |
| [ADR-014](./records/ADR-014-distribucion-github-releases.md) | Distribución por GitHub Releases, con CI en GitHub Actions | Accepted | 2026-10-07 |

> La ADR-001 que traía el framework era un ejemplo genérico y el propio archivo pedía reemplazarla.
> Se reescribió con la decisión real del proyecto, conservando el número y el tema.
>
> El 2026-09-17 el alcance del producto cambió a **solo Android** para la primera entrega, lo que quitó
> la restricción que había desempatado a Expo en ADR-002 (compilar iOS en la nube sin Mac). Eso llevó a
> adoptar Ionic + Capacitor en ADR-005, y por la regla de abajo, ADR-001, 002, 003 y 004 se marcaron
> `Superseded` aunque dos de las cuatro decisiones (estado y DI) no cambiaron de fondo — se reafirman en
> ADR-006 y ADR-008 por trazabilidad, no porque el argumento haya cambiado.

## Orden real de las decisiones

Las primeras cuatro se tomaron en la Fase 0, antes de escribir las secciones 01, 02 y 03. Las últimas
cuatro son la revisión del 2026-09-17 tras el cambio de alcance a solo Android. La dependencia lógica
vigente es esta:

```
ADR-005  stack (Ionic React + Capacitor, solo Android)
   ├──▶ ADR-006  patrón de estado (Zustand)
   ├──▶ ADR-007  almacenamiento local (SQLite vía Capacitor + Drizzle)
   ├──▶ ADR-008  inyección de dependencias (composition root manual)
   │       └──▶ ADR-013  herramientas de prueba (Vitest, Cypress; objetos falsos inyectados)
   └──▶ ADR-014  distribución del APK por GitHub Releases, CI en GitHub Actions
```

> ADR-013 y ADR-014 (2026-10-07) cierran las dos decisiones que el framework deja abiertas para las
> secciones `04-quality` y `05-release`. Ninguna reemplaza a una anterior.

Si algún día se cambiara el stack otra vez, las otras tres vigentes (006, 007, 008) se marcarían
`Superseded`: ninguna sobrevive a ese cambio, sin importar si su conclusión termina siendo la misma.
