# Plan de trabajo — Iniciar sesión y Catálogo de servicios

- **Repo de código:** `beauty-salon/frontend/` (Ionic React + TypeScript sobre Capacitor, Android —
  [ADR-005](./decisions/records/ADR-005-mobile-stack-ionic-capacitor.md)). `beauty-salon` es un
  monorepo temporal para la v1: `backend/` es el repo de la API (ver
  [ADR-009](./decisions/records/ADR-009-backend-repo-and-stack.md)) y `frontend/` es este proyecto
  (ver [ADR-010](./decisions/records/ADR-010-monorepo-temporal.md))
- **Features:** [Catálogo de servicios](./features/catalog.md), [Autenticación](./features/auth.md)
- **Scopes de commit:** `core`, `catalog`, `auth` (ver [`git-conventions.md`](../00-governance/git-conventions.md))

Este documento no repite lo que ya está decidido en otros documentos: los enlaza y los ordena en
una secuencia de trabajo. Si algo aquí contradice a un documento de arquitectura, manda el
documento de arquitectura — este plan solo organiza el orden de construcción.

---

## Por qué estas dos features primero, y en este orden

`auth` es **habilitadora**: sin sesión no se puede agendar ni publicar, así que tarde o temprano
hace falta. `catalog` es la primera pantalla que ve cualquier usuaria y **se explora sin cuenta**
— es el gancho del producto. Entre las dos cubren 4 de las 10 pantallas del producto y dejan el
60% del flujo de la clienta (explorar → ver detalle) listo antes de tocar agendamiento.

**Se construye `catalog` primero, `auth` después.** Motivo: `catalog` no depende de sesión, así
que sirve para probar que el cliente HTTP, la base SQLite y el cacheo funcionan **sin** la
complejidad extra de manejar tokens, roles y formularios de contraseña. Además es visualmente
verificable de inmediato (la primera pantalla real corriendo en el emulador), mientras que `auth`
trae la parte más delicada del proyecto (secure storage, interceptor de refresco, dos roles) y
conviene atacarla con la base del proyecto ya probada, no en el primer intento. Al no depender una
de la otra, si el equipo trabaja en pareja, la segunda persona puede adelantar `auth` en paralelo
sin esperar a que `catalog` termine — pero si se construye en solitario, el orden recomendado es
el de este documento: **Fase 1 = catalog, Fase 2 = auth.**

---

## Fase 0 — Scaffold del proyecto (se hace una sola vez)

No es parte de ninguna de las dos features, pero las dos dependen de esto. Se hace en pareja, no
por separado, para no duplicar decisiones de configuración.

| # | Tarea | Referencia |
|---|-------|------------|
| 1 | Crear el proyecto Ionic React + TypeScript con Capacitor y agregar la plataforma Android | [ADR-005](./decisions/records/ADR-005-mobile-stack-ionic-capacitor.md) |
| 2 | Armar `src/core/` (`di/`, `network/`, `storage/`, `theme/`, `routing/`, `domain/`) y `src/shared/components/` | [`project-structure.md`](./project-structure.md) |
| 3 | Configurar alias `@core/*`, `@features/*`, `@shared/*` en `tsconfig.json` y `vite.config.ts` | [`project-structure.md`](./project-structure.md) |
| 4 | Configurar ESLint (`eslint-plugin-react`, `eslint-plugin-react-hooks`, `@typescript-eslint`, `eslint-plugin-import`) con `import/no-restricted-paths`, y Prettier | [`coding-standards.md`](../02-code-and-ui/coding-standards.md) |
| 5 | Cliente `axios` único en `core/network/` con timeouts, interceptor de `X-Request-Id` y manejo de estados de respuesta | [`api-networking.md`](../03-api-and-data/api-networking.md) |
| 6 | Base de datos local: `@capacitor-community/sqlite` + Drizzle ORM (driver `sqlite-proxy`), esquema versión 1 (`negocios`, `profesionales`, `servicios`) | [ADR-007](./decisions/records/ADR-007-local-storage-capacitor.md), [`persistence.md`](../03-api-and-data/persistence.md) |
| 7 | Plugin de secure storage de Capacitor envuelto en `core/storage/` para los tokens | [`authentication.md`](../03-api-and-data/authentication.md) |
| 8 | Composition root vacío en `core/di/` + `AppProviders` (Context), listo para que cada feature registre sus repositorios | [ADR-008](./decisions/records/ADR-008-dependency-injection.md) |
| 9 | Tabla de rutas centralizada con `IonReactRouter`/`IonRouterOutlet`, `RootNavigator` con `PublicStack` (sin sesión aún, ambas pantallas de `catalog` y las dos de `auth` van aquí) | [`navigation.md`](./navigation.md) |
| 10 | Mock local del contrato `/v1` (p. ej. `json-server` o MSW) sirviendo `auth-login`, `auth-registro`, `catalogo-listar-servicios`, `catalogo-detalle-servicio` | [`03-api-and-data/endpoints/`](../03-api-and-data/endpoints/) |

**Criterio de salida de la Fase 0:** la app arranca, navega entre una pantalla en blanco de
`/login` y otra de `/servicios` sin sesión, y una petición de prueba contra el mock responde.
Todavía no hay UI real de ninguna de las dos features.

---

## Fase 1 — `catalog` (scope `catalog`)

Empieza apenas cierra la Fase 0. No depende de `auth` en absoluto (el catálogo se explora sin
cuenta), así que va primero: valida la base del proyecto (cliente HTTP, SQLite, cacheo) sin la
complejidad extra de sesión.

1. **Domain:** entidad `Service` en `core/domain/` (se comparte con `booking` y `business` más
   adelante — no se duplica, ver [`project-structure.md`](./project-structure.md)), interfaz
   `CatalogRepository`.
2. **Domain:** casos de uso `getPublishedServices` (con filtro por tipo) y `getServiceDetail`.
3. **Data:** esquema Drizzle de `servicios`, `negocios`, `profesionales` (versión 1,
   [`persistence.md`](../03-api-and-data/persistence.md)); `CatalogRepositoryImpl` con estrategia
   **read-through cache**: muestra lo cacheado de inmediato y refresca en segundo plano.
4. **Presentation:** `useCatalogStore` con `CatalogState` (`loading | loaded | empty | error`, más
   `isOffline` independiente) y `ServiceDetailState`
   ([`features/catalog.md`](./features/catalog.md)). Cambiar el filtro de tipo vuelve a `loading`
   sin borrar la lista anterior.
5. **Presentation:** `CatalogScreen` (`IonList` virtualizada, chips de filtro,
   [`TarjetaServicio`](../02-code-and-ui/components/tarjeta-servicio.md)) y `ServiceDetailScreen`
   ([`screens/catalogo.md`](./screens/catalogo.md), [`screens/detalle-servicio.md`](./screens/detalle-servicio.md)).
   El estado `empty` (catálogo del primer día) y `empty` por filtro son casos **distintos**, cada
   uno con su propia prueba.
6. **Routing:** rutas públicas `/servicios` y `/servicio/:servicioId`; esta última debe abrir
   correctamente como deep link, sin pasar por el catálogo primero.
7. **Accesibilidad:** cada tarjeta se anuncia completa (nombre, precio, duración) en una sola
   etiqueta; chips anunciados como seleccionados o no; 48×48 dp en chips y tarjetas.
8. **Pruebas:** unitarias de `getPublishedServices` con caché fresco, vencido y sin conexión, y
   que el filtro no dispare una petición si la lista ya está en memoria; de componente,
   `CatalogScreen` en sus seis estados; de integración, abrir el detalle desde la lista y volver
   conservando el scroll.

**Criterio de salida:** el catálogo abre con contenido cacheado sin conexión, el estado vacío del
primer día se ve como invitación (no como error), y el detalle de un servicio se puede abrir por
deep link sin sesión.

---

## Fase 2 — `auth` (scope `auth`)

Empieza cuando `catalog` está lista (o en paralelo, si hay dos personas disponibles). Trae la
parte más delicada del proyecto: secure storage, interceptor de refresco de token y dos roles.

Construir en este orden — cada paso depende del anterior:

1. **Domain:** entidad `Session` (o el tipo que ya exista en `core/domain/`), interfaces
   `AuthRepository` y `SessionStorage`.
2. **Domain:** casos de uso `signIn`, `signUp`, `signOut`, `restoreSession` — funciones puras,
   reciben sus dependencias por parámetro (no las importan), se prueban con dobles de prueba
   escritos a mano, sin `jest.mock` ([ADR-008](./decisions/records/ADR-008-dependency-injection.md)).
3. **Data:** `AuthRepositoryImpl` contra
   [`POST /v1/auth/login`](../03-api-and-data/endpoints/auth-login.md) y
   [`POST /v1/auth/registro`](../03-api-and-data/endpoints/auth-registro.md); `SessionStorageImpl`
   sobre el plugin de secure storage — **nunca** SQLite para los tokens
   ([`authentication.md`](../03-api-and-data/authentication.md)).
4. **Presentation:** `useAuthStore` (Zustand) con `SessionState` (arranca en `unknown`, no en
   `anonymous`), `LoginState` e `SignUpState` como uniones discriminadas por `status`
   ([`features/auth.md`](./features/auth.md)).
5. **Presentation:** `LoginScreen` y `SignUpScreen` con sus 5 estados cada una
   ([`screens/login.md`](./screens/login.md), [`screens/registro.md`](./screens/registro.md)):
   `loading`, `loaded`, `error` (credenciales bajo el campo, red como banner), `offline`. El
   selector de rol de `SignUpScreen` se anuncia como grupo de opciones.
6. **Routing:** rutas públicas `/login` y `/registro`; la guarda de sesión del `RootNavigator`
   redirige a `/login` guardando la ruta pretendida y vuelve a ella al autenticarse
   ([`navigation.md`](./navigation.md) — caso del deep link compartido por WhatsApp).
7. **Accesibilidad:** `aria-label` en los dos campos, botón de mostrar/ocultar contraseña que
   anuncia su estado, 48×48 dp, errores anunciados al lector de pantalla
   ([`screens/login.md`](./screens/login.md), [`screens/registro.md`](./screens/registro.md)).
8. **Pruebas:** unitarias de los cuatro casos de uso (credenciales válidas/inválidas, token
   presente/ausente/expirado, que `signOut` borre token + base local + caché de imágenes); de
   componente, `LoginScreen` en sus cuatro estados con el error de credenciales junto al campo.

**Criterio de salida:** una clienta puede registrarse, cerrar la app, volver a abrirla sin ver un
parpadeo de login, y cerrar sesión limpiando todo el almacenamiento local.

---

## Definition of Done aplicable a ambas fases

No se repite aquí completa — ver [`definition-of-done.md`](../00-governance/definition-of-done.md).
Los puntos que más se rompen en estas dos features específicamente:

- Los **cinco estados** de cada pantalla están implementados, no solo el caso feliz.
- Ninguna pantalla usa `useState` para datos que vienen del servidor (solo Zustand).
- La revisión de PR la hace quien **no** escribió la historia (equipo de dos, revisión cruzada).
- Corre en el emulador Android (API 34) y, al menos una vez, en el celular de la manicurista
  aliada.

## Convenciones de commit para este trabajo

Ejemplos válidos según [`git-conventions.md`](../00-governance/git-conventions.md):

```
feat(catalog): agregar filtro por tipo de servicio en CatalogScreen
fix(catalog): mostrar estado vacio cuando no hay servicios publicados
feat(auth): implementar signIn y restoreSession
test(auth): cubrir signOut limpiando token y base local
```
