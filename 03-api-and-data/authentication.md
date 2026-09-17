# Autenticación

## Mecanismo

**Correo y contraseña**, con tokens JWT: un `accessToken` de vida corta (60 minutos) y un
`refreshToken` de vida larga (30 días).

Se descartó el ingreso por código SMS aunque encaje mejor con el hábito de las usuarias: cuesta
dinero por mensaje enviado y el proyecto no tiene presupuesto. Queda anotado como el primer cambio a
evaluar si la app sale del semestre.

## Los dos roles

ManiCita es un producto de dos lados, así que la sesión no dice solo *quién* es, dice **de qué lado
está**:

| Rol | Qué puede hacer | Rutas propias |
|-----|-----------------|---------------|
| `clienta` | Explorar, agendar, ver y cancelar sus citas | `/agendar/:id`, `/mis-citas`, `/cita/:id` |
| `negocio` | Publicar y pausar servicios, definir horarios, responder citas | `/negocio/*` |

- El rol viene dentro del token y se lee al restaurar la sesión.
- **El rol se verifica en el servidor en cada petición.** La guarda de navegación del cliente es
  comodidad, no seguridad: esconder un botón no protege un endpoint.
- Una cuenta tiene un solo rol. Si una manicurista quiere agendarse con otra, se registra aparte como
  clienta. Es una limitación aceptada del MVP y está anotada como tal.

## Almacenamiento de tokens

- Los dos tokens van **solo** a un plugin de secure storage de Capacitor, respaldado por el Keystore
  de Android.
- Nunca en `localStorage`, `@capacitor/preferences` sin cifrar, archivos ni en la base de datos SQLite.
- La contraseña no se guarda jamás en el dispositivo, ni siquiera cifrada.

## Envío del token

- El `accessToken` se adjunta con **un solo interceptor** del cliente `axios`, nunca petición por
  petición.
- Ningún repositorio ni pantalla conoce el token: solo el interceptor lo toca.

## Refresco

- Ante un 401, el interceptor refresca el token de forma **transparente** y reintenta **una vez** la
  petición original.
- Los refrescos concurrentes se serializan: si tres peticiones reciben 401 al mismo tiempo, se dispara
  **un** refresco y las otras dos esperan su resultado. Sin esto, tres refrescos simultáneos invalidan
  el token entre ellos y expulsan a la usuaria sin motivo.
- Si el refresco falla, se cierra sesión limpiamente y el navegador raíz muestra el stack público.

## Cierre de sesión

Al cerrar sesión, en este orden:

1. Se cancelan las peticiones autenticadas en vuelo.
2. Se borran los dos tokens del plugin de secure storage de Capacitor.
3. Se borra la base de datos local completa: catálogo cacheado y citas.
4. Se limpia el caché de imágenes.
5. Se vacía el estado en memoria y se navega al stack público.

> El paso 3 no es opcional. Las citas cacheadas dicen a qué hora y en qué dirección va a estar una
> mujer; dejarlas en el dispositivo después de cerrar sesión es exactamente el riesgo que describe
> [`security-rules.md`](../00-governance/security-rules.md).

## Reglas

- Nunca se registran tokens ni credenciales en los logs.
- La app no lleva secretos de larga vida embebidos: solo tokens de la usuaria.
- El desbloqueo biométrico, si se agrega más adelante, sería una puerta al token guardado, nunca un
  reemplazo del token.
