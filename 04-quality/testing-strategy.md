# Estrategia de pruebas

Cómo se prueba ManiCita, con qué herramientas y cuánto. Las herramientas se eligieron en
[ADR-013](../01-architecture/decisions/records/ADR-013-herramientas-de-prueba.md).

---

## Herramientas por repositorio

| Repo | Nivel | Herramienta | Comando | Dónde viven las pruebas |
|------|-------|-------------|---------|-------------------------|
| `beauty-salon-app` | Unitarias y de componente | **Vitest 4** + jsdom + React Testing Library | `npm run test.unit` | Junto al archivo probado: `getAvailability.test.ts` al lado de `getAvailability.ts` |
| `beauty-salon-app` | Punta a punta (E2E) | **Cypress 13** contra el servidor de Vite (`http://localhost:5173`), con la API simulada por `cy.intercept` | `npm run test.e2e` | `cypress/e2e/*.cy.ts` y datos en `cypress/fixtures/` |
| `beauty-salon-api` | Unitarias del dominio | **`node:test`** (incluido en Node, sin dependencias nuevas) | `node --test` | `src/**/*.test.js` |
| `beauty-salon-api` | Colección de la API | **Postman** (se corre con Newman) | `npx newman run postman/manicita.postman_collection.json` | `postman/` |
| `beauty-salon-api` | Integración contra la API real | **`scripts/smoke-test.ps1`** (PowerShell 7): recorre los 21 endpoints con datos que crea por la propia API, nunca por SQL | `pwsh scripts/smoke-test.ps1` | `scripts/` |

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
| E2E | Recorridos completos en el navegador (catálogo, inicio de sesión, inicio según el rol). La API se simula con `cy.intercept` y respuestas con la forma del contrato, para que la prueba no dependa de Docker ni de los datos de la base | Lenta | ~10% |

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
| Los cupos se calculan del horario y la duración, no se guardan | API: `booking.service.test.js` (3 cupos en 3 horas de 60 min, 2 con 90 min, cupo agendado ocupado) y `bogota.test.js`; app: unitaria de `getAvailability`; sonda `GET /services/{id}/availability` | [TC-001](./test-cases/TC-001-cupos-calculados.md) |
| Un cupo no se agenda dos veces | `booking.service.test.js`: secuencial y **simultáneo** (dos clientas a la vez, entra una); sonda `POST /appointments cupo tomado` (409 `SLOT_TAKEN`) | [TC-002](./test-cases/TC-002-sin-doble-agendamiento.md) |
| Reintentar el envío no crea una segunda cita | `booking.service.test.js` (misma cita y una sola fila); sonda `POST /appointments mismo clientRequestId` | [TC-003](./test-cases/TC-003-reintento-idempotente.md) |
| Una profesional no tiene dos horarios que se pisen | `business.agenda.test.js`; sonda `horario solapado` (409 `SCHEDULE_OVERLAP`) | [TC-004](./test-cases/TC-004-horario-sin-solape.md) |
| Pausar no es borrar | `business.agenda.test.js` (sale del catálogo, la cita sigue en la agenda) y `booking.service.test.js` (410); sondas de pausa y agenda; app: la caché borra el pausado (`CatalogRepositoryImpl.test.ts`) | [TC-005](./test-cases/TC-005-pausar-no-borra.md) |
| El negocio responde una cita una sola vez | `business.agenda.test.js`; sonda `respond ya respondida` (409) | [TC-006](./test-cases/TC-006-responder-una-vez.md) |
| Solo la dueña cancela su cita, y una sola vez | `appointments.service.test.js` (403, 409 y el cupo se libera); sondas de cancelación | [TC-007](./test-cases/TC-007-cancelar-solo-la-duena.md) |
| Cada rol ve solo lo suyo | `appointments.service.test.js` y `business.agenda.test.js`; sondas `FORBIDDEN_ROLE` y `FORBIDDEN_RESOURCE`; app: `RequireSession.test.tsx` | [TC-008](./test-cases/TC-008-cada-rol-ve-lo-suyo.md) |
| Cerrar sesión invalida el token de refresco | Sondas de refresh y logout | [TC-009](./test-cases/TC-009-cerrar-sesion-revoca.md) |
| El catálogo se ve sin conexión | `CatalogRepositoryImpl.test.ts` (14, contra un SQLite real), `proxy.test.ts` (escritura atómica) y `CatalogScreen.test.tsx` (aviso con fecha) | [TC-010](./test-cases/TC-010-catalogo-sin-conexion.md) |

---

## CI

- Las pruebas unitarias, de componente y el linter corren **en cada push a `main` y en cada PR**, en
  GitHub Actions. Si fallan, el cambio no se da por terminado (DoD).
- El smoke test de la API corre en el mismo pipeline de la API, con PostgreSQL como servicio del job.
- Las E2E de Cypress también corren en cada PR desde el 2026-11-16 (job `e2e` del `ci.yml` de la
  app): tardan unos 2 minutos y atraparon un cambio de flujo que las unitarias no veían.
- El detalle de etapas está en [`05-release/ci-cd.md`](../05-release/ci-cd.md).

---

## Estado real al 2026-11-16

La estrategia de arriba es la regla. Esto es lo que existe hoy, para que nadie la lea como un hecho:

| Qué | Estado |
|-----|--------|
| Unitarias y de componente de la app (Vitest) | ✅ **302 pruebas en 47 archivos** en `dev`, todas en verde, y **308** al unirse con `main`, que trae las 6 del almacenamiento seguro en web (app PR #40; se comprobó el resultado unido). Desde la v1.0.0 del 2026-11-09 (245) se sumaron, además de esas 6: caché SQLite contra un SQLite real (`CatalogRepositoryImpl.test.ts`, 16) y escritura atómica (2), estados de Catálogo (9) y Detalle (6), casos de uso del catálogo (6), bienvenida y lo más pedido (9), marca de bienvenida (3), rutas de visitante (3), registro como negocio (2) y barra de visitante (1) |
| E2E de la app (Cypress) | ✅ **6 pruebas** en `cypress/e2e/login-y-catalogo.cy.ts`: la primera vez sale la bienvenida y "Quiero agendar" lleva al catálogo (HU-08); "Quiero ofrecer mis servicios" abre el registro con Negocio; la segunda vez abre en el catálogo con "Entrar"; credenciales incorrectas (HU-09); la clienta llega al catálogo y el negocio a sus servicios (HU-09, HU-13) |
| Pruebas de la API (`node:test`) | ✅ **62 pruebas en 10 archivos** con `npm test`, en verde dos corridas seguidas sobre la misma base: `app.test.js` (6), `auth.routes` (4), `auth.service` (5), `loginLimiter` (4), `bogota` (6), `booking.service` (11), `appointments.service` (6), `business.service` (3), `business.agenda` (11) y `catalog.service` (6). Todas menos `app`, `loginLimiter` y `bogota` usan la base de infra |
| Colección Postman de la API | ✅ 13 peticiones, 13/13 en verde con Newman (2026-11-08) |
| Smoke test de la API | ✅ **69 sondas** sobre los 22 endpoints, en verde (2026-11-16) |
| Casos de prueba manuales | ✅ TC-001 a TC-010 ejecutados el 2026-11-08 (pasos de API con `test-cases/ejecutar-pasos-api.ps1` y de app en el emulador). Desde el 2026-11-16 cada uno tiene además prueba automatizada (tabla de reglas críticas, arriba) |
| Cobertura medida | ✅ `npm run test.coverage` (`@vitest/coverage-v8`). Medida el 2026-11-16 con las 302 pruebas: **total** líneas 85,7 %, sentencias 84,1 %, funciones 85,1 %, ramas 80,3 %. **`domain/`** (27 archivos): líneas 95,3 %, sentencias 94,7 %, funciones 100 %, ramas 88,0 %. **Stores** (8): líneas 98,3 %, sentencias 93,8 %, funciones 100 %, **ramas 71,4 %**, por debajo del 80 % de la regla (Q-07) |
| CI que corra pruebas | ✅ `ci.yml` en la app (lint, tipos, Vitest con cobertura, build y Cypress) y en la API (PostgreSQL 16, `npm test` y smoke test), en cada PR y en cada push a `dev`, `qa` y `main` (2026-11-16). Detalle en [`ci-cd.md`](../05-release/ci-cd.md) |

### Deuda de pruebas

| ID | Qué falta | Estado | Responsable | Fecha |
|----|-----------|--------|-------------|-------|
| Q-01 | Pruebas unitarias de los casos de uso de `catalog` | ✅ hecha: `catalogUseCases.test.ts` (6) y `getPopularServices` en la bienvenida (app PR #42 y #43) | Lilly Puentes | 2026-11-13 |
| Q-02 | Pruebas de componente de `CatalogScreen` y `ServiceDetailScreen` en sus cinco estados | ✅ hecha: carga, cargado, vacío, vacío por filtro, error con reintento y sin conexión en las dos pantallas (app PR #42) | Lilly Puentes | 2026-11-13 |
| Q-03 | Reemplazar la E2E de ejemplo de Cypress | ✅ hecha el 2026-11-09 (app PR #31); ampliada a 6 con la bienvenida el 2026-11-16 | Lizeth Caicedo, Lilly Puentes | 2026-11-16 |
| Q-04 | Pruebas unitarias del cálculo de cupos y la hora de Bogotá en la API | ✅ hecha: `bogota.test.js` (6, puras) y `booking.service.test.js` (11, contra la base) | Lilly Puentes | 2026-11-16 |
| Q-05 | Instalar `@vitest/coverage-v8` y medir la cobertura de `domain/` | ✅ hecha: `npm run test.coverage` (app PR #42). `domain/` en 95,3 % de líneas | Lilly Puentes | 2026-11-13 |
| Q-06 | Workflow de CI que corra lint, unitarias y smoke test | ✅ hecha: `ci.yml` en app y API (rama `fix/flujo-de-ingreso`) | Lilly Puentes | 2026-11-16 |
| Q-07 | Subir las ramas de los stores de Zustand al 80 % y configurar el umbral en `vite.config.ts` (ver R-05 de `ci-cd.md`) | ⏳ pendiente: hoy 71,4 % de ramas | _por asignar_ | _por asignar_ |

> La deuda que queda abierta es de **cobertura fina**, no de funcionalidad sin probar: cada regla
> crítica tiene prueba automatizada, sonda y caso de prueba.
