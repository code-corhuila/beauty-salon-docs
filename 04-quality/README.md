# 04 — Quality

> **¿Qué es esto?** Cómo se prueba ManiCita, qué tan rápida y liviana tiene que ser, y qué se
> revisa de seguridad antes de sacar un build.

## Por qué existe esta sección

La calidad se define y se mide; no se espera que aparezca sola. Esta sección convierte el "en mi
emulador funciona" en compuertas explícitas: pruebas, presupuestos de rendimiento y una checklist
de seguridad que se marca en cada release.

> **Cada documento separa la regla del estado real.** La regla dice cómo debe ser; la tabla de
> estado al 2026-10-07 dice qué existe hoy. Lo que falta queda como deuda con ID (Q-, P-) para que
> no se confunda lo planeado con lo hecho.

---

## Documentos de esta sección

| Archivo | Para qué sirve |
|---------|----------------|
| [testing-strategy.md](./testing-strategy.md) | Herramientas por repo (Vitest, Cypress, `node:test`, smoke test), pirámide, nombres, cobertura y las reglas de negocio críticas con su prueba |
| [performance-budgets.md](./performance-budgets.md) | Arranque, tamaño del JavaScript y del APK, fps y memoria, con la línea base medida |
| [mobile-security.md](./mobile-security.md) | Checklist de seguridad antes de cada release, para Capacitor y para la API |
| [test-cases/](./test-cases/) | Un caso de prueba por regla de negocio crítica |
| [_template-test-case.md](./_template-test-case.md) | Plantilla para escribir un caso de prueba manual (no se edita) |

---

## Casos de prueba

| ID | Regla de negocio | Feature | Se puede ejecutar hoy en |
|----|------------------|---------|--------------------------|
| [TC-001](./test-cases/TC-001-cupos-calculados.md) | Los cupos se calculan del horario y la duración | booking | API |
| [TC-002](./test-cases/TC-002-sin-doble-agendamiento.md) | Un cupo no se agenda dos veces | booking | API |
| [TC-003](./test-cases/TC-003-reintento-idempotente.md) | Reintentar el envío no crea una segunda cita | booking | API |
| [TC-004](./test-cases/TC-004-horario-sin-solape.md) | Una profesional no tiene dos horarios que se pisen | business | API |
| [TC-005](./test-cases/TC-005-pausar-no-borra.md) | Pausar no es borrar | business, catalog | API |
| [TC-006](./test-cases/TC-006-responder-una-vez.md) | El negocio responde una cita una sola vez | business | API |
| [TC-007](./test-cases/TC-007-cancelar-solo-la-duena.md) | Solo la dueña cancela su cita, y una sola vez | appointments | API |
| [TC-008](./test-cases/TC-008-cada-rol-ve-lo-suyo.md) | Cada rol ve solo lo suyo | auth | API |
| [TC-009](./test-cases/TC-009-cerrar-sesion-revoca.md) | Cerrar sesión invalida el token y limpia el dispositivo | auth | API |
| [TC-010](./test-cases/TC-010-catalogo-sin-conexion.md) | El catálogo se ve sin conexión | catalog | App (Android) |

> Los casos describen los pasos en la app y en la API. Mientras la pantalla de una feature no exista,
> el caso se ejecuta contra la API (Postman o el smoke test) y los pasos de la app quedan pendientes.
> Los archivos se copian de la plantilla como `test-cases/TC-NNN-titulo-corto.md`, con numeración
> secuencial.

---

## Correlaciones con otras secciones

| Esta sección depende de... | Por qué |
|----------------------------|---------|
| `00-governance/definition-of-done.md` | Las pruebas son parte de "terminado" |
| `00-governance/security-rules.md` | `mobile-security.md` verifica esas reglas |
| `01-architecture/` | Las capas definen qué es prueba unitaria y qué es de UI; las features definen las reglas de negocio |
| `03-api-and-data/` | El contrato de API es lo que el smoke test verifica, código por código |
| `05-release/` | Las pruebas y los presupuestos son compuertas del release |

---

## Preguntas que esta sección debe responder

- ¿Qué se prueba, en qué nivel y cuánto? → [testing-strategy.md](./testing-strategy.md)
- ¿Cuáles son los presupuestos de rendimiento y cómo se detecta una regresión? → [performance-budgets.md](./performance-budgets.md)
- ¿Qué revisiones de seguridad se hacen antes de un release? → [mobile-security.md](./mobile-security.md)
- ¿Qué regla de negocio crítica tiene su caso de prueba? → la tabla de arriba
