# ADR-006 — Patrón de manejo de estado (reafirmación bajo Ionic + Capacitor)

- **ID:** ADR-006
- **Fecha:** 2026-09-17
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

[ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) cambió el stack móvil de React Native + Expo a
Ionic React + Capacitor. Por la regla registrada en [`decisions/README.md`](../README.md) ("si algún
día se cambiara el stack, las otras tres se marcarían `Superseded`: ninguna sobrevive a ese cambio"),
[ADR-001](./ADR-001-state-management-pattern.md) queda superada y hay que volver a decidir el patrón
de estado bajo el stack nuevo, no asumir que sigue igual solo porque parece igual.

**Restricciones conocidas:** las mismas que en [ADR-001](./ADR-001-state-management-pattern.md) —
equipo de dos personas aprendiendo, estado probable sin renderizar UI con Jest puro, y la pantalla de
agendamiento con estados que se cruzan. Ionic React sigue siendo **React**: no cambia ninguna de esas
restricciones.

---

## Decisión

**Se decidió:** mantener el **store unidireccional con estado inmutable, implementado con Zustand**,
uno por pantalla o por feature, exponiendo un único objeto de estado más las acciones que lo
modifican. La decisión no cambia de fondo respecto a [ADR-001](./ADR-001-state-management-pattern.md);
se reafirma en una ADR propia porque el stack que la condicionaba cambió.

**Justificación:**
Zustand es una librería de manejo de estado para React, no para React Native específicamente: no
importa ni un solo paquete nativo de Expo o de React Native, así que nada de lo que justificó la
elección en [ADR-001](./ADR-001-state-management-pattern.md) depende de si los componentes se dibujan
con primitivas nativas (React Native) o dentro de un WebView (Ionic + Capacitor). El store sigue siendo
un objeto plano de JavaScript que se prueba llamando acciones y leyendo estado, sin renderizar nada.

---

## Alternativas evaluadas

Las mismas cuatro que en [ADR-001](./ADR-001-state-management-pattern.md), con el mismo resultado: el
cambio de Expo a Capacitor no altera ninguno de los descartes, porque ninguna alternativa se rechazó
por una razón específica de React Native.

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Store con Zustand (elegida) | Poco boilerplate, estado inmutable, se prueba sin UI, sin Provider obligatorio, agnóstico de si la UI corre nativa o en WebView | Menos convenciones impuestas: la disciplina la pone el equipo | — (elegida) |
| Redux Toolkit | Estándar de la industria, DevTools excelentes | Slices, actions y thunks por pantalla; mucho archivo para un CRUD de dos lados | El costo de boilerplate no se justifica en un proyecto de dos personas, con o sin Capacitor |
| MVI con useReducer + Context | Sin dependencias nuevas | Context re-renderiza todo lo que lo consume; hay que memoizar a mano | El catálogo sigue siendo la lista larga del MVP, WebView o no: el problema de rendimiento no depende del renderer |
| TanStack Query + estado local | Excelente para caché de servidor | Deja el estado partido en dos fuentes | Rompe la regla de un solo objeto de estado por pantalla, independientemente del stack |

---

## Consecuencias

**Positivas:**
- Cero cambios de código o de convención para el equipo: el store, las acciones y las pruebas se
  escriben exactamente igual que bajo React Native.
- La migración de stack no obliga a re-arquitecturar la capa de presentación.

**Negativas / Costos:**
- Ninguno adicional a los ya aceptados en [ADR-001](./ADR-001-state-management-pattern.md).

**Impacto en el sistema:**
- Features y pantallas afectadas: todas.
- Documentos a mantener sincronizados: [`layers-and-state.md`](../../layers-and-state.md) y cada
  documento de feature en [`../../features/`](../../features/).

---

## Referencias

- Supersede a: [ADR-001](./ADR-001-state-management-pattern.md)
- Relacionada con: [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) (el stack condiciona las
  librerías disponibles)
- [`layers-and-state.md`](../../layers-and-state.md)
