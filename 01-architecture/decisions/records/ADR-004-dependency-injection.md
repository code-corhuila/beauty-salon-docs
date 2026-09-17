# ADR-004 — Inyección de dependencias

- **ID:** ADR-004
- **Fecha:** 2026-09-07
- **Estado:** Superseded by [ADR-008](./ADR-008-dependency-injection.md)
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

Las capas definidas en [`layers-and-state.md`](../../layers-and-state.md) solo se sostienen si algo
conecta las piezas sin que la capa de arriba conozca a la de abajo: los casos de uso dependen de
**interfaces** de repositorio, y alguien tiene que decidir qué implementación concreta se usa.

Sin una regla, cada archivo termina importando directamente la implementación —o peor, un singleton
global— y la capa de dominio queda amarrada a `axios` y a SQLite. Ahí se acaba la posibilidad de
probar un caso de uso sin red.

**Restricciones conocidas:**
- Debe permitir sustituir un repositorio por un doble de prueba **sin montar componentes**.
- El proyecto lo mantienen dos personas: la solución tiene que entenderse leyendo un archivo.
- TypeScript sin decoradores ni `reflect-metadata`: activarlos complica la configuración de Babel
  del stack elegido en [ADR-002](./ADR-002-mobile-stack.md).

---

## Decisión

**Se decidió:** usar un **composition root manual** en `src/core/di/`, que construye las
implementaciones concretas una sola vez y las expone a la UI mediante un **React Context**
(`AppProviders`). Los casos de uso reciben sus dependencias **por parámetro**, nunca las importan.

**Justificación:**
Es la solución más simple que sostiene la regla de capas. Un caso de uso que recibe su repositorio
por parámetro se prueba pasándole un objeto falso, sin librería de mocking y sin contenedor. Y el
composition root es un archivo que se lee de arriba abajo: cualquiera —incluida yo misma en tres
meses— ve en un minuto qué implementación está entrando. Un contenedor con decoradores resolvería lo
mismo, pero agrega configuración de Babel y magia en tiempo de ejecución a un proyecto que tiene
cinco features.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Composition root manual + Context (elegida) | Sin dependencias nuevas, explícito, se lee en un archivo, pruebas sin librería de mocking | Hay que cablear a mano cada dependencia nueva | — (elegida) |
| Contenedor con tsyringe o InversifyJS | Resolución automática, escala bien en equipos grandes | Exige decoradores y `reflect-metadata`, más configuración de Babel; la resolución falla en ejecución, no al compilar | Complejidad desproporcionada para cinco features y una desarrolladora |
| Importar los repositorios directamente donde se usan | Cero ceremonia, escribir menos | Amarra el dominio a `axios` y a SQLite; para probar un caso de uso habría que interceptar módulos con `jest.mock` | Rompe la dirección de dependencias que define toda la sección 01 |
| Solo Context, sin composition root | Menos archivos | El armado de dependencias queda repartido por la app y se vuelve imposible de seguir | Traslada el problema en vez de resolverlo |

---

## Consecuencias

**Positivas:**
- Los casos de uso se prueban con objetos falsos escritos a mano, sin `jest.mock`.
- Un solo lugar dice qué implementación real usa la app: cambiar la fuente de datos es cambiar una
  línea del composition root.
- No hay dependencias ni configuración de build adicionales.

**Negativas / Costos:**
- Cada dependencia nueva se cablea a mano. Con cinco features es trivial; con cincuenta dolería.
- El `AppProviders` crece con el proyecto y hay que mantenerlo ordenado por feature.

**Impacto en el sistema:**
- Afecta a `src/core/di/` y al punto de arranque `App.tsx`.
- Documentos a mantener sincronizados: [`project-structure.md`](../../project-structure.md) y
  [`layers-and-state.md`](../../layers-and-state.md).

---

## Referencias

- Relacionada con: [ADR-001](./ADR-001-state-management-pattern.md), [ADR-002](./ADR-002-mobile-stack.md)
- [`project-structure.md`](../../project-structure.md)
