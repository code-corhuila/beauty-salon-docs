# ADR-001 — Patrón de manejo de estado

- **ID:** ADR-001
- **Fecha:** 2026-09-07
- **Estado:** Superseded by [ADR-006](./ADR-006-state-management-pattern.md)
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

ManiCita necesita una sola forma de manejar el estado de la UI en todas sus features. Sin un patrón
decidido, cada pantalla termina resolviendo lo mismo de forma distinta —una con `useState`, otra con
Context, otra con una librería— y las pantallas dejan de poder probarse igual.

El producto tiene dos lados (clienta y negocio) sobre la misma base de código, así que el patrón se
va a repetir al menos diez veces. Elegir mal cuesta diez veces.

**Restricciones conocidas:**
- El equipo son dos personas aprendiendo: el patrón tiene que ser simple de escribir, fácil de
  recordar después de dos semanas sin tocar el archivo, y lo bastante uniforme para que el código de
  las dos se lea igual.
- El estado debe poder probarse **sin renderizar UI**, con Jest puro.
- La pantalla de agendamiento tiene estados que se cruzan (cargando cupos, cupo tomado por otra
  clienta, sin conexión) y necesita que esos estados sean explícitos.

---

## Decisión

**Se decidió:** adoptar un **store unidireccional con estado inmutable**, implementado con
**Zustand**, uno por pantalla o por feature, exponiendo un único objeto de estado más las acciones
que lo modifican.

**Justificación:**
Zustand da flujo unidireccional y estado inmutable con una fracción de la ceremonia de Redux, y el
store es un objeto plano de JavaScript: se prueba llamando acciones y leyendo el estado, sin
render y sin providers. Además no obliga a envolver la app en un Provider, lo que mantiene el
árbol de componentes limpio. El desempate contra Redux Toolkit fue la cantidad de código por
pantalla: con diez pantallas y un equipo de dos, el boilerplate se paga diez veces.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Store con Zustand (elegida) | Poco boilerplate, estado inmutable, se prueba sin UI, sin Provider obligatorio | Menos convenciones impuestas: la disciplina la pone el equipo | — (elegida) |
| Redux Toolkit | Estándar de la industria, DevTools excelentes, patrón muy explícito | Slices, actions y thunks por pantalla; mucho archivo para un CRUD de dos lados | El costo de boilerplate no se justifica en un proyecto de una persona |
| MVI con useReducer + Context | Sin dependencias nuevas, muy explícito (intent, reducer, estado) | Context re-renderiza todo lo que lo consume; hay que memoizar a mano en cada pantalla | Los problemas de rendimiento aparecerían justo en el catálogo, que es la pantalla con lista larga |
| TanStack Query + estado local | Excelente para caché de servidor, refetch y estados de carga gratis | Deja el estado partido en dos fuentes: la caché de la librería y el estado local de la pantalla | Rompe la regla de un solo objeto de estado por pantalla y complica el manejo del estado offline |

---

## Consecuencias

**Positivas:**
- Todas las pantallas se leen igual: un State, unas acciones, y componentes que solo dibujan.
- Los cinco estados obligatorios (loading / loaded / empty / error / offline) se modelan como una
  unión discriminada por `status`, y TypeScript obliga a manejarlos todos.
- Las pruebas de estado corren en milisegundos porque no montan componentes.

**Negativas / Costos:**
- Zustand no impone estructura: si no se respeta la convención de un objeto de estado por pantalla,
  el store se vuelve una bolsa de variables sueltas. Se mitiga con la regla escrita en
  [`layers-and-state.md`](../../layers-and-state.md) y con la revisión de PR.
- No hay caché de servidor gratis: el reintento y la invalidación se implementan en el repositorio,
  no en la capa de estado.

**Impacto en el sistema:**
- Features y pantallas afectadas: todas.
- Documentos a mantener sincronizados: [`layers-and-state.md`](../../layers-and-state.md) y cada
  documento de feature en [`../../features/`](../../features/).

---

## Referencias

- Relacionada con: [ADR-002](./ADR-002-mobile-stack.md) (el stack condiciona las librerías disponibles)
- [`layers-and-state.md`](../../layers-and-state.md)
