# Estándares de código

Lenguaje: **TypeScript** sobre Ionic React + Capacitor ([ADR-005](../01-architecture/decisions/records/ADR-005-mobile-stack-ionic-capacitor.md)).

## Principios

- **Inmutabilidad primero.** `const` por defecto; el estado se reemplaza, no se muta. Nada de
  `array.push` sobre el estado: se crea un arreglo nuevo.
- **Unidades pequeñas.** Una función hace una cosa; un archivo declara un tipo o componente principal.
- **Sin valores mágicos.** Todo color, espaciado o tamaño sale de un token; todo número de negocio
  (duración mínima, días del calendario) sale de una constante con nombre.
- **Fallar temprano.** Se valida en los bordes: al recibir la respuesta del servidor y al recibir la
  entrada de la usuaria. Un error nunca se traga en silencio.

## Nombres

| Cosa | Convención | Ejemplo |
|------|------------|---------|
| Tipos, interfaces, componentes | `PascalCase` | `AppointmentRepository`, `ServiceCard` |
| Variables y funciones | `camelCase` | `bookAppointment` |
| Constantes de módulo | `UPPER_SNAKE_CASE` | `MAX_BOOKING_DAYS` |
| Archivo de componente | `PascalCase.tsx` | `ServiceCard.tsx` |
| Archivo de módulo | `camelCase.ts` | `appointmentRepository.ts` |
| Booleanos | prefijo `is` / `has` / `should` | `isOffline`, `hasSlots` |
| Handlers | prefijo `handle` | `handleConfirmPress` |

## TypeScript

- `strict: true`. `any` explícito prohibido por el linter; si de verdad no se conoce el tipo, se usa
  `unknown` y se estrecha.
- Los DTO de red se declaran aparte de las entidades de dominio y se mapean. La UI nunca ve un DTO.
- Uniones discriminadas por `status` para el estado de pantalla, no banderas booleanas sueltas.
  Tres booleanos (`isLoading`, `isEmpty`, `hasError`) permiten ocho combinaciones, de las cuales
  cinco son imposibles; una unión permite exactamente las que existen.

## Manejo de errores

- Las operaciones que pueden fallar devuelven un `Result` tipado, no lanzan:

```ts
type Result<T, E = DomainError> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

- Los errores de bajo nivel (red, parseo, SQLite) se mapean a **errores de dominio** en la capa de
  datos, antes de llegar a la UI. La pantalla nunca recibe un `AxiosError`.
- Errores de dominio de ManiCita: `NetworkUnavailable`, `Unauthorized`, `SlotTaken`, `NotFound`,
  `ValidationFailed`, `ServerError`.
- Toda falla visible para la usuaria tiene mensaje **y** acción de salida: reintentar, volver o
  escoger otra hora.

## Asíncrono

- Toda promesa maneja su rama de error. `await` sin `try` o sin `Result` no pasa revisión.
- El trabajo en vuelo se cancela cuando la pantalla se desmonta (`AbortController` en el cliente HTTP).
- Nada de trabajo pesado en el hilo de UI. El cálculo de cupos es liviano, pero el parseo de listas
  largas se hace una vez y se memoiza.

## Rendimiento en listas

Regla concreta que sale de [ADR-005](../01-architecture/decisions/records/ADR-005-mobile-stack-ionic-capacitor.md):
el catálogo es la única lista que puede crecer, y es la primera pantalla de la app. Al correr sobre un
WebView, una lista larga sin virtualizar cuesta más que en componentes nativos, así que la regla es
más estricta, no menos.

- `IonList` con virtualización (`react-window` o el `IonInfiniteScroll` de Ionic con paginación) en
  vez de renderizar todas las filas del catálogo de una vez; `key` estable, nunca el índice.
- El componente de fila va memoizado con `React.memo`.
- Nada de funciones flecha creadas en el render de la lista: se pasan handlers estables.

## Linter y formato

- **ESLint** con `eslint-plugin-react`, `eslint-plugin-react-hooks`, `@typescript-eslint` y
  `eslint-plugin-import`, más **Prettier**.
- Reglas propias del proyecto: `import/no-restricted-paths` para prohibir imports entre features,
  y `no-restricted-imports` para prohibir importar implementaciones concretas desde `domain/`.
- **CI falla ante cualquier advertencia** (`eslint --max-warnings=0`).
- Desactivar una regla en línea exige un comentario que explique por qué. Sin comentario, no pasa.
