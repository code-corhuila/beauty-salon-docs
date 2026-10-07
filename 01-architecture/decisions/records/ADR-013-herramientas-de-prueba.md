# ADR-013 — Herramientas de prueba: Vitest y Cypress en la app, `node:test` y smoke test en la API

- **ID:** ADR-013
- **Fecha:** 2026-10-07
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

El framework deja abierta la decisión de con qué se prueba, y el proyecto la había dado por
supuesta sin escribirla. Eso dejó una contradicción en los documentos:

- La [Definition of Done](../../../00-governance/definition-of-done.md),
  [`layers-and-state.md`](../../layers-and-state.md) y
  [ADR-006](./ADR-006-state-management-pattern.md) hablan de **Jest** y de `npm test`.
- `beauty-salon-app`, generado con el andamiaje de Ionic React sobre **Vite**, trae **Vitest** y
  **Cypress**, con los scripts `test.unit` y `test.e2e`. No existe `npm test`.
- `beauty-salon-api` no tiene ninguna herramienta de pruebas unitarias; su única prueba es
  `scripts/smoke-test.ps1`, que verifica los 18 endpoints contra PostgreSQL real.

Una DoD que exige una herramienta que el repo no usa no se puede verificar. Se decide ahora porque
la sección `04-quality` se está escribiendo y necesita nombrar herramientas reales.

**Restricciones conocidas:**
- Los casos de uso se prueban con objetos falsos escritos a mano e inyectados, sin interceptar
  módulos ([ADR-008](./ADR-008-dependency-injection.md)).
- Las reglas de negocio más críticas de la API (sin doble agendamiento, idempotencia) las garantiza
  el **motor** de PostgreSQL con índices únicos, no el código.
- Equipo de dos personas: cada herramienta extra es configuración que alguien tiene que mantener.

---

## Decisión

**Decidimos:** en la app, **Vitest** (con jsdom y React Testing Library) para pruebas unitarias y
de componente, y **Cypress** para punta a punta. En la API, **`node:test`** para las funciones puras
del dominio y el **smoke test en PowerShell** como prueba de integración del contrato.

**Justificación:**
- Vitest lee el mismo `vite.config.ts` que compila la app: los alias `@core`, `@features` y `@shared`
  funcionan en las pruebas sin repetirlos en Babel ni en `moduleNameMapper`. Con Jest habría que
  mantener dos configuraciones que dicen lo mismo.
- La API de Vitest (`describe`, `it`, `expect`) es la de Jest. Lo que los documentos llaman "probar
  con Jest puro" sigue valiendo como idea: probar el dominio **sin renderizar UI ni tocar la red**.
- Vitest y Cypress ya vienen instalados y configurados por el andamiaje: no hay nada que agregar.
- `node:test` viene con Node 18+: la API no gana dependencias para tener pruebas unitarias.
- El smoke test ya existe, ya cubre los 18 endpoints con 49 sondas y crea sus propios datos por la
  API. Es la única prueba que demuestra que los índices de PostgreSQL hacen su trabajo.

**El desempate** fue la configuración única: Jest y Vitest prueban lo mismo, pero solo uno funciona
sin duplicar la configuración de Vite.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Vitest + Cypress en la app; `node:test` + smoke test en la API (elegida) | Ya instalados; una sola configuración; la API no suma dependencias | El smoke test es PowerShell, no JavaScript | — (elegida) |
| Jest + React Testing Library en la app | Es lo que decían los documentos; el más conocido | Con Vite, necesita Babel o `ts-jest` y repetir los alias; hay que desinstalar Vitest | Duplica configuración para el mismo resultado |
| Playwright en vez de Cypress | Más rápido; varios navegadores | Hay que instalarlo y escribir la configuración; los navegadores extra no aportan en una app que corre en el WebView de Android | Cypress ya está configurado y la ventaja no aplica |
| Jest + Supertest en la API, con la base simulada | Pruebas rápidas sin Docker | Con la base simulada, el índice único que evita el doble agendamiento no existe: la prueba pasaría aunque la regla estuviera rota | Prueba lo que no importa y deja sin probar lo que sí |
| Reescribir el smoke test en JavaScript | Un solo lenguaje en la API | Trabajo sin ganancia: PowerShell 7 corre en Windows y en los runners Linux de GitHub Actions | No resuelve un problema que exista |

---

## Consecuencias

**Positivas:**
- La DoD vuelve a ser verificable: nombra comandos que existen.
- Cero dependencias nuevas, salvo `@vitest/coverage-v8` para medir la cobertura.

**Negativas / costos:**
- Quien escriba pruebas en la API tiene que conocer dos estilos: `node:test` en JavaScript y el smoke
  test en PowerShell.
- Las E2E de Cypress corren en Chrome de escritorio, no en el WebView de Android. Lo específico del
  dispositivo (SQLite nativo, almacenamiento seguro) se cubre con los casos de prueba manuales en el
  emulador.

**Impacto en el sistema:**
- Features afectadas: todas (cada historia se cierra con sus pruebas).
- Documentos actualizados: [`definition-of-done.md`](../../../00-governance/definition-of-done.md)
  (de `npm test` con Jest a `npm run test.unit` con Vitest) y
  [`layers-and-state.md`](../../layers-and-state.md).
  [ADR-006](./ADR-006-state-management-pattern.md) **no** se edita: su mención de "Jest puro" se lee
  a la luz de esta ADR, porque el argumento (estado que se prueba sin renderizar UI) no cambia.
- Documento que la aplica: [`04-quality/testing-strategy.md`](../../../04-quality/testing-strategy.md).

---

## Referencias

- [Vitest](https://vitest.dev/) · [Cypress](https://www.cypress.io/) · [`node:test`](https://nodejs.org/api/test.html)
- Relacionada con: [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) (stack), [ADR-008](./ADR-008-dependency-injection.md) (objetos falsos inyectados), [ADR-009](./ADR-009-backend-repo-and-stack.md) (stack de la API)
