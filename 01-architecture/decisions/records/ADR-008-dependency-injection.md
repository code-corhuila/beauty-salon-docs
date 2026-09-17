# ADR-008 — Inyección de dependencias (reafirmación bajo Ionic + Capacitor)

- **ID:** ADR-008
- **Fecha:** 2026-09-17
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

[ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) cambió el stack móvil de React Native + Expo a
Ionic React + Capacitor. Por la misma regla que obliga a revisar [ADR-001](./ADR-001-state-management-pattern.md)
y [ADR-003](./ADR-003-local-storage.md), [ADR-004](./ADR-004-dependency-injection.md) queda superada y
hay que confirmar si el composition root manual sigue siendo la solución correcta bajo el stack nuevo.

**Restricciones conocidas:** las mismas que en [ADR-004](./ADR-004-dependency-injection.md) —
sustituir un repositorio por un doble de prueba sin montar componentes, solución legible por dos
personas, TypeScript sin decoradores ni `reflect-metadata`. Ionic React sigue siendo React: React
Context existe igual, y Vite (el bundler nuevo, ver [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md))
no necesita configuración especial para usarlo.

---

## Decisión

**Se decidió:** mantener el **composition root manual** en `src/core/di/`, expuesto a la UI mediante
un **React Context** (`AppProviders`), con los casos de uso recibiendo sus dependencias por parámetro.
La decisión no cambia de fondo respecto a [ADR-004](./ADR-004-dependency-injection.md); se reafirma en
una ADR propia porque el stack que la condicionaba cambió.

**Justificación:**
Nada en el razonamiento de [ADR-004](./ADR-004-dependency-injection.md) dependía de React Native o de
Expo: dependía de React (Context existe) y de evitar decoradores/`reflect-metadata` (que Babel de
Metro complicaba, y que Vite tampoco necesita). Un caso de uso que recibe su repositorio por parámetro
se sigue probando pasándole un objeto falso, sin librería de mocking, exactamente igual bajo Capacitor.
Lo único que cambia es **qué implementaciones concretas** construye el composition root: ahora
instancia el repositorio de SQLite sobre `@capacitor-community/sqlite` (ver
[ADR-007](./ADR-007-local-storage-capacitor.md)) y el de sesión sobre el plugin de secure storage de
Capacitor, en vez de sobre los equivalentes de Expo.

---

## Alternativas evaluadas

Las mismas cuatro que en [ADR-004](./ADR-004-dependency-injection.md), con el mismo resultado: ninguna
se descartó por una razón específica de React Native o Expo.

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Composition root manual + Context (elegida) | Sin dependencias nuevas, explícito, pruebas sin librería de mocking, agnóstico del bundler | Hay que cablear a mano cada dependencia nueva | — (elegida) |
| Contenedor con tsyringe o InversifyJS | Resolución automática | Exige decoradores y `reflect-metadata`; Vite necesita el mismo tipo de configuración extra que Babel para soportarlos | Complejidad desproporcionada para cinco features y un equipo de dos, con o sin Capacitor |
| Importar los repositorios directamente donde se usan | Cero ceremonia | Amarra el dominio a `axios` y al plugin de SQLite de turno | Rompe la dirección de dependencias que define toda la sección 01, independientemente del stack |
| Solo Context, sin composition root | Menos archivos | El armado de dependencias queda repartido por la app | Traslada el problema en vez de resolverlo |

---

## Consecuencias

**Positivas:**
- Cero cambios de patrón para el equipo: el composition root se reescribe cableando los nuevos
  plugins de Capacitor, pero la forma de la solución es idéntica.
- Los casos de uso se siguen probando con objetos falsos escritos a mano.

**Negativas / Costos:**
- El `AppProviders` y el composition root sí requieren reescribir las fábricas concretas: donde antes
  construían un repositorio sobre `expo-sqlite`/`expo-secure-store`, ahora construyen uno sobre
  `@capacitor-community/sqlite` y el plugin de secure storage de Capacitor.

**Impacto en el sistema:**
- Afecta a `src/core/di/` y al punto de arranque de la app.
- Documentos a mantener sincronizados: [`project-structure.md`](../../project-structure.md) y
  [`layers-and-state.md`](../../layers-and-state.md).

---

## Referencias

- Supersede a: [ADR-004](./ADR-004-dependency-injection.md)
- Relacionada con: [ADR-006](./ADR-006-state-management-pattern.md), [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md)
- [`project-structure.md`](../../project-structure.md)
