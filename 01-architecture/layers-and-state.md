# Capas y estado

## Capas

| Capa | Responsabilidad | Dependencias permitidas |
|------|-----------------|-------------------------|
| Presentation | Dibujar la UI, sostener el estado de la vista, despachar intenciones | Domain |
| Domain | Casos de uso, entidades, interfaces de repositorio | Ninguna |
| Data | Implementaciones de repositorio, fuentes remota y local, mapeo | Domain |

## Dirección de las dependencias

```
Presentation  ──▶  Domain  ◀──  Data
```

- Domain **no depende de nada hacia afuera**: no importa `axios`, ni `drizzle-orm`, ni ningún paquete
  de Ionic o de Capacitor. Si un archivo de `domain/` importa React, la capa ya se rompió.
- Presentation nunca importa un data source directo: pasa por un caso de uso o por la interfaz
  del repositorio.
- Data depende de Domain porque implementa sus interfaces. Nunca al revés.

**Cómo se ve la regla en ManiCita:** el cálculo de cupos (`horario / duración del servicio`) es una
regla de negocio, así que vive en `domain/`, en el caso de uso `getAvailability`, y no en el
componente del selector de horas ni en el repositorio. Eso permite probar la regla más importante
del producto con una prueba unitaria de Vitest
([ADR-013](./decisions/records/ADR-013-herramientas-de-prueba.md)), sin renderizar la UI ni tocar la red.

> **El servidor es la autoridad del cupo**, porque es el único que ve todas las citas al mismo
> tiempo. El caso de uso implementa la misma regla por dos motivos: descartar las horas del día de
> hoy que ya pasaron mientras la clienta miraba la pantalla, y poder probar la regla sin backend.
> Si algún día el servidor y el cliente no coinciden, manda el servidor y el cliente recarga.

## Manejo de estado

El patrón elegido para toda la app es **Store unidireccional con estado inmutable**, implementado
con **Zustand**. La decisión está registrada en
[ADR-006](./decisions/records/ADR-006-state-management-pattern.md).

- Un solo patrón en toda la app. **No se mezclan patrones entre features.**
- Cada pantalla tiene un store que expone **un único objeto de estado inmutable** más las acciones
  que lo modifican.
- El estado nunca se muta: cada acción produce un objeto nuevo (`set(state => ({...}))`).
- Los componentes no contienen lógica de negocio: leen el estado con un selector y despachan
  acciones. La acción llama al caso de uso; el caso de uso no sabe que existe el store.
- Prohibido `useState` para datos que vienen del servidor. `useState` queda solo para estado
  puramente visual y local de un componente (un acordeón abierto, el foco de un input).

### Forma del estado

El estado de cada pantalla es una **unión discriminada** por `status`, para que los cinco estados de
la tabla de pantallas existan en el tipo y el compilador obligue a manejarlos:

```ts
type CatalogState = {
  status: 'loading' | 'loaded' | 'empty' | 'error';
  services: Service[];          // vacío salvo en 'loaded'
  selectedType: ServiceType | null;  // filtro activo
  error: DomainError | null;    // solo en 'error'
  isOffline: boolean;           // se muestra el banner de sin conexión
};
```

Correspondencia con la tabla de estados que exige cada documento de pantalla:
`loading` mientras la petición está en vuelo, `loaded` con contenido, `empty` cuando la respuesta
llegó vacía, `error` con su acción de reintento, y `offline` cuando `isOffline` es true (puede
convivir con `loaded` si se está mostrando caché).

> **Por qué `empty` es un estado y no una lista de cero elementos:** en ManiCita el catálogo vacío no
> es un caso raro, es el primer día de la app. Si `empty` no existe en el tipo, la pantalla dibuja una
> lista en blanco y la clienta cree que la app está rota.

## Casos de uso

Un caso de uso = una acción de negocio. Son funciones puras que reciben sus dependencias por
parámetro, se prueban sin UI y sin red, y orquestan repositorios. Estos son los de ManiCita:

| Caso de uso | Feature | Qué hace |
|-------------|---------|----------|
| `signIn` | auth | Autentica con correo y contraseña, devuelve la sesión con su rol |
| `signUp` | auth | Registra a la clienta o al negocio |
| `signOut` | auth | Cierra sesión y limpia tokens y datos locales |
| `getPublishedServices` | catalog | Lista los servicios publicados, con filtro por tipo |
| `getServiceDetail` | catalog | Trae el detalle de un servicio con su profesional |
| `getAvailability` | booking | **Calcula los cupos libres** de una profesional en una fecha: el horario se divide en bloques del tamaño de la duración del servicio, y se descartan los bloques ya tomados |
| `bookAppointment` | booking | Crea la cita sobre un cupo, y falla explícitamente si el cupo ya fue tomado |
| `getMyAppointments` | appointments | Lista las citas de la clienta autenticada |
| `cancelAppointment` | appointments | Cancela una cita propia |
| `createService` | business | Publica un servicio con precio, duración, profesional y horario |
| `pauseService` | business | Saca un servicio del catálogo sin borrarlo ni tocar las citas ya agendadas |
| `setSchedule` | business | Define el horario de atención de una profesional por día de la semana |
| `getBusinessAgenda` | business | Lista las citas que le llegaron al negocio |
| `respondAppointment` | business | Confirma o rechaza una cita pendiente |

> `getAvailability` es el caso de uso central del producto: es donde vive la regla de que los cupos
> se calculan y no se crean a mano. Es también el que más pruebas unitarias tiene, porque es el que
> reemplaza al cuaderno de la manicurista.
