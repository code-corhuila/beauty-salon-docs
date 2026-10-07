# Estrategia de pruebas

Cómo se prueba ManiCita, con qué herramientas y cuánto. Las herramientas se eligieron en
[ADR-013](../01-architecture/decisions/records/ADR-013-herramientas-de-prueba.md).

---

## Herramientas por repositorio

| Repo | Nivel | Herramienta | Comando | Dónde viven las pruebas |
|------|-------|-------------|---------|-------------------------|
| `beauty-salon-app` | Unitarias y de componente | **Vitest 4** + jsdom + React Testing Library | `npm run test.unit` | Junto al archivo probado: `getAvailability.test.ts` al lado de `getAvailability.ts` |
| `beauty-salon-app` | Punta a punta (E2E) | **Cypress 13** contra el servidor de Vite (`http://localhost:5173`) | `npm run test.e2e` | `cypress/e2e/*.cy.ts` |
| `beauty-salon-api` | Unitarias del dominio | **`node:test`** (incluido en Node, sin dependencias nuevas) | `node --test` | `src/**/*.test.js` |
| `beauty-salon-api` | Integración contra la API real | **`scripts/smoke-test.ps1`** (PowerShell 7): recorre los 18 endpoints con datos que crea por la propia API, nunca por SQL | `pwsh scripts/smoke-test.ps1` | `scripts/` |

> **Por qué Vitest y no Jest**, aunque varias ADR anteriores digan "Jest puro": la app se compila
> con Vite, y Vitest usa la misma configuración (alias `@core`, `@features`, `@shared`) sin
> duplicarla en Babel. Su API (`describe`, `it`, `expect`) es la de Jest, así que donde la
> documentación dice "probar con Jest puro" la idea sigue en pie: probar **sin renderizar UI ni
> tocar la red**. Ver ADR-013.

---

## Pirámide de pruebas

### App (`beauty-salon-app`)

| Tipo | Qué cubre en ManiCita | Velocidad | Proporción |
|------|-----------------------|-----------|------------|
| Unitarias | Casos de uso de `features/*/domain` (`getAvailability`, `bookAppointment`, `cancelAppointment`, `createService`…), mapeadores DTO → modelo y stores de Zustand | Rápida | ~70% |
| De componente | Una pantalla o un componente compartido aislado, renderizado con React Testing Library, en cada fila de su tabla de estados (loading, loaded, vacío, error, offline) | Media | ~20% |
| E2E | El ciclo completo del MVP en el navegador, contra la API levantada con `beauty-salon-infra` | Lenta | ~10% |

### API (`beauty-salon-api`)

| Tipo | Qué cubre | Velocidad |
|------|-----------|-----------|
| Unitarias | Las funciones puras que sostienen las reglas de negocio: cálculo de cupos a partir del horario y la duración, conversión a hora de Bogotá (UTC-05:00), validadores de entrada | Rápida |
| Integración | El contrato de [`api-contract.md`](../03-api-and-data/api-contract.md) de punta a punta contra PostgreSQL real: códigos HTTP, forma `problem+json` y `code` de cada error. Hoy son **49 sondas** | Media (necesita Docker) |

> En la API la integración pesa más que en la app **a propósito**: las dos reglas más importantes
> del negocio (no hay doble agendamiento y la misma `clientRequestId` no crea dos citas) las
> resuelve el **motor** con índices únicos, no el código. Solo una prueba contra PostgreSQL real
> demuestra que funcionan; una prueba unitaria con la base simulada no prueba nada de eso.

---

## Reglas

- Cada caso de uso tiene prueba unitaria. Las dependencias se reemplazan con **objetos falsos
  escritos a mano** que implementan la interfaz del repositorio, inyectados por constructor
  ([ADR-008](../01-architecture/decisions/records/ADR-008-dependency-injection.md)). **No se usa
  `vi.mock`** sobre módulos: si un caso de uso necesita interceptar un import para probarse, está
  mal inyectado.
- Se prueba el **comportamiento y las transiciones de estado** (`loading → loaded`,
  `submitting → slotTaken`), no los detalles de implementación.
- Deterministas: sin red real en unitarias ni de componente, sin `setTimeout` de espera, y con el
  **reloj fijo** (`vi.setSystemTime`) en todo lo que calcula cupos o separa citas próximas de
  pasadas. Una prueba de cupos que depende de la hora en que se corre falla los domingos.
- Las fechas de las pruebas se escriben en hora de Bogotá con su desfase explícito
  (`2026-10-06T09:00:00-05:00`), igual que en el contrato.
- Arrange-Act-Assert; una afirmación lógica por prueba cuando se pueda.
- El smoke test de la API crea sus propios usuarios con un sufijo único por corrida, así que se puede
  correr cuantas veces se quiera sobre la misma base sin limpiarla.

---

## Nombres

- Archivo: `<unidad>.test.ts` (app) o `<unidad>.test.js` (API), al lado del código.
- Prueba: `<unidad>_<condición>_<resultadoEsperado>`, en inglés como el resto de identificadores
  ([ADR-012](../01-architecture/decisions/records/ADR-012-nombres-en-ingles.md)).
  - `getAvailability_whenScheduleNotDivisible_dropsRemainder`
  - `bookAppointment_whenSlotTaken_returnsSlotTakenError`
  - `CatalogScreen_whenOfflineWithCache_showsCachedServices`

---

## Cobertura

- **80% mínimo** en `src/features/*/domain/` y en los stores de Zustand de la app, medido con
  `vitest --coverage` (proveedor `@vitest/coverage-v8`).
- En la API, 80% mínimo en las funciones puras del cálculo de cupos y de la hora de Bogotá.
- La cobertura es un piso, no una meta: una línea cubierta no es un comportamiento probado. Por eso
  cada regla crítica tiene además su caso de prueba escrito (abajo).

---

## Reglas de negocio críticas y cómo se prueba cada una

Cada regla que, si falla, le cuesta una cita o la privacidad a alguien tiene **al menos un caso de
prueba** en [`test-cases/`](./test-cases/), además de la prueba automatizada que la cubre.

| Regla | Prueba automatizada | Caso de prueba |
|-------|---------------------|----------------|
| Los cupos se calculan del horario y la duración, no se guardan | Unitaria de `getAvailability`; sonda `GET /services/{id}/availability` | [TC-001](./test-cases/TC-001-cupos-calculados.md) |
| Un cupo no se agenda dos veces | Sonda `POST /appointments cupo tomado` (409 `SLOT_TAKEN`) | [TC-002](./test-cases/TC-002-sin-doble-agendamiento.md) |
| Reintentar el envío no crea una segunda cita | Sonda `POST /appointments mismo clientRequestId` | [TC-003](./test-cases/TC-003-reintento-idempotente.md) |
| Una profesional no tiene dos horarios que se pisen | Sonda `horario solapado` (409 `SCHEDULE_OVERLAP`) | [TC-004](./test-cases/TC-004-horario-sin-solape.md) |
| Pausar no es borrar | Sondas de pausa (410 `SERVICE_PAUSED`) y agenda | [TC-005](./test-cases/TC-005-pausar-no-borra.md) |
| El negocio responde una cita una sola vez | Sonda `respond ya respondida` (409) | [TC-006](./test-cases/TC-006-responder-una-vez.md) |
| Solo la dueña cancela su cita, y una sola vez | Sondas de cancelación (403, 409) | [TC-007](./test-cases/TC-007-cancelar-solo-la-duena.md) |
| Cada rol ve solo lo suyo | Sondas `FORBIDDEN_ROLE` y `FORBIDDEN_RESOURCE` | [TC-008](./test-cases/TC-008-cada-rol-ve-lo-suyo.md) |
| Cerrar sesión invalida el token de refresco | Sondas de refresh y logout | [TC-009](./test-cases/TC-009-cerrar-sesion-revoca.md) |
| El catálogo se ve sin conexión | De componente de `CatalogScreen` (pendiente) | [TC-010](./test-cases/TC-010-catalogo-sin-conexion.md) |

---

## CI

- Las pruebas unitarias, de componente y el linter corren **en cada push a `main` y en cada PR**, en
  GitHub Actions. Si fallan, el cambio no se da por terminado (DoD).
- El smoke test de la API corre en el mismo pipeline de la API, con PostgreSQL como servicio del job.
- Las E2E de Cypress corren antes de cada release (no en cada push: necesitan la API y la app
  levantadas y tardan minutos).
- El detalle de etapas está en [`05-release/ci-cd.md`](../05-release/ci-cd.md).

---

## Estado real al 2026-10-07

La estrategia de arriba es la regla. Esto es lo que existe hoy, para que nadie la lea como un hecho:

| Qué | Estado |
|-----|--------|
| Smoke test de la API | ✅ 49 sondas sobre los 18 endpoints, todas en verde en la última corrida (2026-09-27) |
| Unitarias de la API (`node:test`) | ⏳ ninguna todavía |
| Unitarias y de componente de la app | ⏳ solo existe `src/App.test.tsx`, la prueba de ejemplo del andamiaje de Ionic |
| E2E de la app | ⚠️ `cypress/e2e/test.cy.ts` es la prueba de ejemplo de Ionic: busca el texto "Ready to create an app?", que ya no existe en la app, así que **falla**. Hay que reemplazarla |
| Cobertura medida | ⏳ `@vitest/coverage-v8` no está instalado |
| CI que corra pruebas | ⏳ no existe; el único workflow es `release.yml` de la API, que solo crea el GitHub Release |

### Deuda de pruebas

| ID | Qué falta | Responsable | Fecha |
|----|-----------|-------------|-------|
| Q-01 | Pruebas unitarias de los casos de uso de `catalog` (la única feature construida en la app) | _por asignar_ | _por asignar_ |
| Q-02 | Pruebas de componente de `CatalogScreen` y `ServiceDetailScreen` en sus cinco estados | _por asignar_ | _por asignar_ |
| Q-03 | Reemplazar la E2E de ejemplo de Cypress por el recorrido catálogo → detalle | _por asignar_ | _por asignar_ |
| Q-04 | Pruebas unitarias del cálculo de cupos y la hora de Bogotá en la API | _por asignar_ | _por asignar_ |
| Q-05 | Instalar `@vitest/coverage-v8` y medir la cobertura de `domain/` | _por asignar_ | _por asignar_ |
| Q-06 | Workflow de CI que corra lint, unitarias y smoke test (ver `05-release/ci-cd.md`) | _por asignar_ | _por asignar_ |

> Las features que todavía no existen en la app (auth, booking, appointments, business) entran con
> sus pruebas: la [Definition of Done](../00-governance/definition-of-done.md) no da por terminada
> una historia sin ellas.
