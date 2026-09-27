# API y red

## Estado del backend

**ManiCita ya tiene backend implementado**: Node.js + Express + PostgreSQL, en el repo `beauty-salon`
([ADR-009](../01-architecture/decisions/records/ADR-009-backend-repo-and-stack.md)), siguiendo el
contrato diseñado en [`endpoints/`](./endpoints/), un documento por endpoint. Mientras el frontend no
apunte a una instancia real, se puede seguir sirviendo ese mismo contrato con un mock local, que es
lo que la [Definition of Ready](../00-governance/definition-of-ready.md) admite como contrato
*stubbed*.

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
- **Nunca se reintenta automáticamente un POST o un PATCH.** Reintentar `POST /v1/appointments` puede crear
  dos citas. El error se muestra y la clienta decide.
- Cada petición lleva un `X-Request-Id` generado por un interceptor, para poder rastrearla.

## Serialización

- Se serializa y deserializa con **DTOs**; el mapeo DTO a entidad de dominio ocurre en la capa de datos.
- **La UI nunca ve un payload crudo.**
- Un payload inesperado o malformado falla ruidosamente y se mapea a un error de dominio. No se
  adivina ni se rellena con valores por defecto: un precio que llega nulo y se pinta como 0 es peor
  que un error.

## Manejo de estados de respuesta

Todo error de la API llega como `application/problem+json` con `title`, `status`, `detail`, `code` y,
en validación, `errors` ([`api-contract.md`](./api-contract.md) §2). El interceptor lo convierte en
un error tipado que conserva `code` y `detail`:

- **La app decide con `code`**, nunca comparando el texto de `detail`: el mismo 409 puede ser
  `SLOT_TAKEN`, `EMAIL_TAKEN` o `SCHEDULE_OVERLAP`, y cada uno lleva a una pantalla distinta.
- **La persona lee `detail`**, que ya viene en español y dice qué hacer. No se reemplaza por un
  "ocurrió un error" genérico.

| Rango | Significado | Qué hace la app |
|-------|-------------|-----------------|
| 2xx | Éxito | Mapea a entidad de dominio |
| 400 | `MALFORMED_JSON` | Defecto de la app, no de la persona: se registra y se muestra `detail` |
| 401 | `AUTH_REQUIRED`, `SESSION_EXPIRED` | Refresca el token y reintenta una vez; si falla, cierra sesión |
| 401 | `INVALID_CREDENTIALS` | Mensaje bajo el formulario de login; no se refresca nada |
| 401 | `INVALID_REFRESH_TOKEN` | Cierra sesión limpiamente |
| 403 | `FORBIDDEN_ROLE`, `FORBIDDEN_RESOURCE` | Error de dominio `Unauthorized`; la guarda de navegación redirige |
| 409 | `SLOT_TAKEN` | Error de dominio `SlotTaken`: la pantalla recarga la disponibilidad |
| 409 | Otros `code` | Se muestra `detail` en el contexto de la acción |
| 410 | `SERVICE_PAUSED` | Estado "ya no disponible" |
| 422 | `VALIDATION_FAILED` | `ValidationFailed` con `errors` por campo, que el formulario muestra junto a cada campo |
| 5xx o timeout | Transitorio | Retroceso y reintento si es idempotente; después, error visible con reintentar |

> El 409 es el código más importante del proyecto. Es la respuesta que evita que dos clientas queden
> a la misma hora, y por eso tiene su propio error de dominio y su propio estado de pantalla.

## Logging

- Nunca se registran tokens, contraseñas ni cabeceras de autorización completas.
- Los datos personales se ocultan en los logs: el celular de la clienta se registra como
  `***4321`.
- En release no queda ningún log de red.
