# API y red

## Estado del backend

**ManiCita no tiene backend construido todavía.** El contrato completo está diseñado en
[`endpoints/`](./endpoints/), un documento por endpoint, y eso es lo que la
[Definition of Ready](../00-governance/definition-of-ready.md) admite como contrato *stubbed*.

Durante el desarrollo el contrato se sirve con un mock local, de modo que la app se construya contra
la misma forma de datos que tendrá el servidor real.

- Base URL de desarrollo: `http://localhost:3000/v1`
- Base URL de producción: `https://api.manicita.app/v1`
- La base URL se inyecta como variable de entorno de build de Vite (`.env` por ambiente, leída con
  `import.meta.env`), nunca se escribe en el código.

## Cliente

- **Un solo** cliente `axios` configurado en `src/core/network/`: base URL, timeouts e interceptores
  definidos una vez. Ninguna feature crea su propio cliente.
- Timeouts concretos de este proyecto:

| Tipo de petición | Timeout de conexión | Timeout de respuesta |
|------------------|---------------------|----------------------|
| Lecturas (catálogo, citas, agenda) | 5 s | 10 s |
| Disponibilidad | 5 s | 8 s |
| Escrituras (crear cita, publicar servicio) | 5 s | 15 s |

> La disponibilidad tiene el timeout más corto a propósito: la clienta está esperando con la pantalla
> abierta y prefiere un error rápido con reintentar antes que quince segundos mirando un esqueleto.

## Peticiones y reintentos

- **Reintentos solo en peticiones idempotentes** (GET), con retroceso exponencial: 300 ms, 900 ms y
  se acabó. Máximo 2 reintentos.
- **Nunca se reintenta automáticamente un POST o un PATCH.** Reintentar `POST /v1/citas` puede crear
  dos citas. El error se muestra y la clienta decide.
- Cada petición lleva un `X-Request-Id` generado por un interceptor, para poder rastrearla.

## Serialización

- Se serializa y deserializa con **DTOs**; el mapeo DTO a entidad de dominio ocurre en la capa de datos.
- **La UI nunca ve un payload crudo.**
- Un payload inesperado o malformado falla ruidosamente y se mapea a un error de dominio. No se
  adivina ni se rellena con valores por defecto: un precio que llega nulo y se pinta como 0 es peor
  que un error.

## Manejo de estados de respuesta

| Rango | Significado | Qué hace la app |
|-------|-------------|-----------------|
| 2xx | Éxito | Mapea a entidad de dominio |
| 401 | Sin autenticar | Refresca el token y reintenta una vez; si falla, cierra sesión |
| 403 | Sin permiso | Error de dominio `Unauthorized`; la guarda de navegación redirige |
| 409 | Conflicto | En `POST /v1/citas` significa **cupo tomado**: se mapea a `SlotTaken` y la pantalla recarga la disponibilidad |
| 422 | Validación | Se mapea a `ValidationFailed` con los errores por campo, que el formulario muestra |
| 4xx restante | Error del cliente | Error de dominio con mensaje accionable |
| 5xx o timeout | Transitorio | Retroceso y reintento si es idempotente; después, error visible con reintentar |

> El 409 es el código más importante del proyecto. Es la respuesta que evita que dos clientas queden
> a la misma hora, y por eso tiene su propio error de dominio y su propio estado de pantalla.

## Logging

- Nunca se registran tokens, contraseñas ni cabeceras de autorización completas.
- Los datos personales se ocultan en los logs: el celular de la clienta se registra como
  `***4321`.
- En release no queda ningún log de red.
