# Feature — Autenticación y sesión

- **Responsables:** Lilly Signey Puentes Rincon y Lizeth Caicedo
- **Estado:** In progress — registro (HU-08), inicio de sesión (HU-09) y sesión persistente
  (HU-10) construidos en `beauty-salon-app` el 2026-10-07; faltan enviar y renovar el token en cada
  petición (HU-11), cerrar sesión (HU-12) y las rutas por rol (HU-13). Mientras no exista la pantalla
  del negocio (HU-14), las dos cuentas aterrizan en el catálogo al entrar
- **Historias relacionadas:** HU-007 registro e inicio de sesión (habilitadora del Sprint 1)

---

## Propósito

Permitir que una persona entre a ManiCita como **clienta** o como **negocio**, y sostener esa sesión
con su rol, porque todo el resto de la app cambia según de qué lado esté quien la abre.

El catálogo se explora **sin cuenta**: la sesión solo se exige en el momento de agendar o de publicar.
Pedir registro en la primera pantalla es la forma más rápida de perder a una clienta que apenas está
viendo precios.

---

## Pantallas

| Pantalla | Ruta | Propósito |
|----------|------|-----------|
| [LoginScreen](../screens/login.md) | `/login` | Entrar con correo y contraseña |
| [SignUpScreen](../screens/registro.md) | `/register` | Crear cuenta eligiendo el rol |

---

## Estado

- **Patrón:** Store con Zustand ([ADR-006](../decisions/records/ADR-006-state-management-pattern.md))
- **Objetos de estado:** `SessionState` (global, vive mientras la app esté abierta), `LoginState` y
  `SignUpState` (por pantalla)
- **Transiciones clave:**
  - `SessionState`: `unknown` al arrancar mientras se lee el token guardado, luego `authenticated`
    con su rol o `anonymous`.
  - `LoginState`: `idle` a `submitting` a `loaded` o `error`. El error de credenciales no es un
    estado de error de red: se muestra bajo el campo, no como pantalla completa.

> `SessionState` arranca en `unknown` y no en `anonymous` a propósito: si arrancara en `anonymous`,
> la app mostraría la pantalla de login durante el instante en que lee el token del almacenamiento
> seguro, y una usuaria ya autenticada vería un parpadeo de login cada vez que abre la app.

---

## Datos

- **Casos de uso:** `signIn`, `signUp`, `signOut`, `restoreSession`
- **Repositorios:** `AuthRepository`, `SessionStorage`
- **Endpoints:** [`POST /v1/auth/login`](../../03-api-and-data/endpoints/auth-login.md),
  [`POST /v1/auth/register`](../../03-api-and-data/endpoints/auth-register.md),
  [`POST /v1/auth/refresh`](../../03-api-and-data/endpoints/auth-refresh.md),
  [`POST /v1/auth/logout`](../../03-api-and-data/endpoints/auth-logout.md)
- **Persistencia local:** los tokens van **solo** al plugin de secure storage de Capacitor, nunca a SQLite.
  El perfil de la sesión activa (nombre, rol) se guarda en memoria y se vuelve a pedir al restaurar.
- **Estrategia offline:** online-only. Sin conexión no se puede iniciar sesión, pero **una sesión ya
  abierta sigue siendo válida sin red**: el token guardado se lee del dispositivo.
- **Al abrir la app (`restoreSession`, HU-10):** sin tokens → anónima. `accessToken` vigente (con un
  minuto de margen) → autenticada sin ir a la red. Vencido → se renueva antes de declarar la sesión;
  si no hay conexión (sin red o timeout) se conserva la sesión con el perfil guardado; cualquier
  otra respuesta (401, o un 5xx como pide [`auth-refresh.md`](../../03-api-and-data/endpoints/auth-refresh.md))
  borra los tokens y arranca anónima. El nombre y el rol salen del `accessToken`, sin verificar la
  firma (api-contract §1.2: solo sirven para decidir qué mostrar)

---

## Casos borde y estados

- [x] Loading — verificando credenciales, y al arrancar mientras se restaura la sesión
- [x] Empty — no aplica: son formularios
- [x] Error / reintento — credenciales inválidas (bajo el campo), correo ya registrado, error de red
- [x] Offline — el botón de entrar se deshabilita con un mensaje que explica que se necesita conexión
- [x] Permiso denegado — sesión de clienta intentando abrir una ruta de negocio: la guarda redirige
      sin mostrar error, ver [`navigation.md`](../navigation.md)

---

## Decisiones

- [ADR-006](../decisions/records/ADR-006-state-management-pattern.md) — patrón de estado
- [ADR-005](../decisions/records/ADR-005-mobile-stack-ionic-capacitor.md) — el stack define el plugin
  de secure storage de Capacitor como almacén de tokens
- [ADR-008](../decisions/records/ADR-008-dependency-injection.md) — `AuthRepository` se inyecta desde
  el composition root

---

## Pruebas

- **Unitarias:** `signIn` con credenciales válidas e inválidas; `restoreSession` con token presente,
  ausente y expirado; que `signOut` borre token, base local y caché de imágenes.
- **De componente:** `LoginScreen` en sus cuatro estados; que el error de credenciales aparezca junto
  al campo y no reemplace la pantalla.
- **Integración:** el flujo completo de deep link — abrir `/book/128` sin sesión, registrarse y
  volver a `/book/128`.
