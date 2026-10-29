# Contrato de API — ManiCita

**Qué es este documento:** la forma exacta de cada petición y de cada respuesta de
`beauty-salon-api`. Si al implementar hay que elegir entre dos formas y esto no lo dice, **es un
fallo de este documento**, no una libertad de quien implementa.

Manda sobre el controlador de la API y sobre el cliente HTTP de la app a la vez. Lo que viene de la
base de datos está en [`data-model.md`](./data-model.md); cómo la app cachea, reintenta y se
comporta sin red está en [`api-networking.md`](./api-networking.md), [`offline-sync.md`](./offline-sync.md)
y en cada ficha de [`endpoints/`](./endpoints/).

```
Verificado el 2026-09-27 contra el sistema levantado con beauty-salon-infra
(beauty-salon-api con el formato de error problem+json). Las sondas están en §10.
```

---

## 1. Convenciones comunes

Aplican a **todos** los endpoints y no se repiten en cada ficha.

### 1.1 Base, transporte y formato

| Aspecto | Decisión |
|---------|----------|
| Base (desarrollo) | `http://localhost:3000/v1` (levantada con `beauty-salon-infra`). En el emulador de Android, `http://10.0.2.2:3000/v1` |
| Base (app publicada) | **No existe todavía**: no hay despliegue. Hueco H-01 |
| Transporte | HTTPS. **Excepción de desarrollo:** HTTP plano en `localhost`, porque el servicio corre en la máquina de quien desarrolla. La app publicada no puede apuntar a HTTP |
| Formato de petición | JSON, UTF-8, `Content-Type: application/json` |
| Formato de respuesta exitosa | JSON, UTF-8, `application/json` |
| Formato de error | `application/problem+json; charset=utf-8`, con la forma de §2 |
| Nombres de campo | `camelCase` en petición y respuesta, sin excepciones (verificado en §10) |
| Valores de enumeración | minúsculas en inglés, iguales en la base y en el JSON: `pending`, `client`, `semi_permanent` ([ADR-012](../01-architecture/decisions/records/ADR-012-nombres-en-ingles.md)) |
| CORS | Abierto a cualquier origen (la app corre en el WebView de Capacitor). Hueco H-02 para producción |

### 1.2 Autenticación y roles

| Pregunta | Respuesta |
|----------|-----------|
| ¿Cómo viaja? | `Authorization: Bearer <accessToken>` |
| ¿Qué endpoint emite el token? | [E-01 registro](#e-01--post-v1authregister) y [E-02 login](#e-02--post-v1authlogin); se renueva con [E-03](#e-03--post-v1authrefresh) |
| ¿Cuánto vive? | `accessToken`: **60 minutos**. `refreshToken`: **30 días** |
| ¿Hay refresco? | Sí, con **rotación**: cada refresco entrega un `refreshToken` nuevo y revoca el usado. Reusar uno ya usado responde 401 `INVALID_REFRESH_TOKEN` |
| ¿Qué lleva dentro? | JWT HS256. `accessToken`: `sub` (id de la cuenta), `role`, `name`, `iat`, `exp`. La app **puede leer** `role` y `name` para decidir qué pantalla mostrar; **no debe confiar** en ellos para nada más. La API vuelve a verificar el rol en cada petición |
| ¿Qué pasa al expirar? | 401 `SESSION_EXPIRED`. La app refresca una vez y reintenta; si el refresco falla, cierra sesión |
| ¿Cómo se cierra sesión? | [E-04](#e-04--post-v1authlogout) revoca el `refreshToken`. **El `accessToken` no se revoca**: sigue valiendo hasta vencer (60 min como máximo) |
| ¿Qué roles hay? | Lista cerrada: `client`, `business`. Cualquier otro valor se rechaza con 422 |
| Tolerancia de reloj | Ninguna necesaria: el servidor valida `exp` con **su** reloj. La hora del teléfono no interviene |
| ¿Quién es el autor? | **Sale del token, nunca del cuerpo.** Ningún endpoint acepta `clientId`, `businessId` ni `userId` en la petición |

**Endpoints anónimos:** E-01, E-02, E-03, E-04 (estos dos piden `refreshToken`), E-05, E-06 y E-07.
Todos los demás exigen sesión y un rol exacto (ver cada ficha).

### 1.3 Identificadores, importes, moneda y fechas

| Aspecto | Decisión |
|---------|----------|
| Identificadores | Texto: prefijo por tipo + `_` + 10 caracteres de `23456789abcdefghjkmnpqrstuvwxyz`. Ej.: `svc_k3m8q2x9zt`. **No son UUID ni secuenciales.** El cliente los trata como opacos |
| Prefijos | `usr_` cuenta · `biz_` negocio · `prf_` profesional · `svc_` servicio · `apt_` cita · `slt_` cupo |
| Cupo | `slt_AAAAMMDD_HHmm` (hora de Colombia). Lo produce [E-07](#e-07--get-v1servicesserviceidavailability) y la app lo devuelve **tal cual**; no lo construye |
| Importes | Entero JSON en **pesos colombianos, sin decimales**: `"priceCop": 45000`. No hay redondeo porque no hay fracciones |
| Moneda | Siempre COP. **No viaja como campo**: va en el nombre (`priceCop`). Si algún día hubiera otra moneda, sería un campo nuevo |
| Instantes | ISO 8601 **con desplazamiento explícito de Colombia**: `2026-09-27T09:00:00-05:00`. Nunca una fecha sin zona, nunca `Z` |
| Fechas sin hora | `YYYY-MM-DD`, entendidas como día en Colombia (`date` de E-07 y E-16) |
| Horas de horario | `HH:mm`, 24 h, hora de reloj en Colombia (`schedule[].startTime`) |
| Día de la semana | Entero ISO: 1 = lunes … 7 = domingo |

Colombia no tiene horario de verano: el desplazamiento es **siempre** `-05:00`. Quien fecha una
operación (una cita, una cancelación) es **el servidor**; ningún endpoint recibe la hora del
teléfono.

### 1.4 Paginación

Una sola forma, por número de página, para las tres colecciones que pueden crecer: E-05, E-09 y
E-13.

| Parámetro | Tipo | Obligatorio | Por omisión | Límites |
|-----------|------|-------------|-------------|---------|
| `page` | entero | no | 1 | Menor que 1, o no numérico → se sirve 1 |
| `pageSize` | entero | no | 20 | Mayor que 50 → se recorta a 50. Menor que 1, o no numérico → 20. **E-09 no lo acepta: siempre 20** |

Respuesta:

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `items` | array | no | La página. Vacía es `[]`, nunca nulo |
| `page` | número | no | La página servida, ya corregida |
| `totalPages` | número | no | `max(1, ceil(total / pageSize))` con el tamaño **servido** |

**Una página pasada del final** (`page=9` con `totalPages=2`) responde 200 con `items: []` y
`page: 9`. La app deja de pedir cuando `page >= totalPages`.

**Lo que falta** respecto del manual: la respuesta no devuelve el `pageSize` servido ni el `total`.
Si la app pide `pageSize=500`, recibe 50 elementos pero no se entera por la respuesta. Hueco H-03.

**El orden es parte del contrato** y es determinista en todas (desempata por `id`):

| Colección | Orden |
|-----------|-------|
| E-05 catálogo | `createdAt` descendente, luego `id` descendente |
| E-09 mis citas | `startsAt` descendente, luego `id` descendente |
| E-13 servicios del negocio | `createdAt` descendente, luego `id` descendente |
| E-11 profesionales | `name` ascendente, luego `id` ascendente (no paginada: máximo 20) |
| E-16 agenda del día | `startsAt` ascendente, luego `id` ascendente (no paginada: un día) |

### 1.5 Filtros, orden y rangos de fecha

| Parámetro | Dónde | Si falta | Si llega mal |
|-----------|-------|----------|--------------|
| `type` | E-05 | Todos los tipos | **Valor desconocido se ignora** y se devuelven todos (hueco H-04) |
| `scope` | E-09 | Próximas y pasadas juntas | Valor desconocido se ignora: ambas |
| `date` | E-07, E-16 | 422 `VALIDATION_FAILED` | 422 `VALIDATION_FAILED` |

**Rangos:** no hay rangos `from`/`to` en esta versión. `date` representa un día completo en
Colombia, con la convención **`inicio <= startsAt < inicio + 24 h`**: el extremo inicial entra, el
final no. `scope=upcoming` es `startsAt >= ahora` y `scope=past` es `startsAt < ahora`, con la hora
del servidor.

### 1.6 Idioma de los mensajes y tamaño máximo de petición

| Aspecto | Decisión |
|---------|----------|
| Idioma | Todo texto para la persona (`detail`, mensajes de `errors`) va en **español de Colombia**. No se negocia idioma: no hay `Accept-Language` |
| Tamaño máximo | **100 KB** de cuerpo. Por encima: **413** `PAYLOAD_TOO_LARGE`. No hay subida de archivos (ver H-05) |

---

## 2. La forma del error

### 2.1 El cuerpo, campo por campo

**Todos los errores tienen el mismo cuerpo**, incluidos los que produce Express por su cuenta (JSON
mal formado, cuerpo demasiado grande, ruta inexistente):

```json
{
  "title": "Validación fallida",
  "status": 422,
  "detail": "Revisa los campos marcados.",
  "code": "VALIDATION_FAILED",
  "errors": { "phone": ["Debe tener 10 dígitos"] }
}
```

| Campo | Obligatorio | Tipo | Para quién |
|-------|-------------|------|------------|
| `title` | sí | string | Categoría del error, en español. Para registros, **no para la pantalla** |
| `status` | sí | número | Repite el código HTTP |
| `detail` | **sí, siempre** | string | **El texto que la persona acaba leyendo.** Dice qué pasó y, cuando se puede, qué hacer |
| `code` | sí | string | Estable, en `UPPER_SNAKE_CASE`. **Lo único con lo que la app decide** |
| `errors` | solo con `VALIDATION_FAILED` | objeto `{ campo: [mensaje, ...] }` | Para que el formulario marque cada campo. Las claves son los nombres de campo del contrato (`camelCase`) |

La app **nunca compara el texto de `detail`**: se puede reescribir o corregir una tilde sin aviso.
Cambiar un `code` sí es un cambio rompiente (§9).

### 2.2 Códigos estables para la app

| `code` | HTTP | `title` | `detail` literal por omisión |
|--------|------|---------|------------------------------|
| `MALFORMED_JSON` | 400 | Petición mal formada | "El cuerpo de la petición no es un JSON válido." |
| `AUTH_REQUIRED` | 401 | Sesión requerida | "Inicia sesión para continuar." |
| `SESSION_EXPIRED` | 401 | Sesión vencida | "Tu sesión venció. Inicia sesión de nuevo." |
| `INVALID_CREDENTIALS` | 401 | Credenciales inválidas | "Correo o contraseña incorrectos." |
| `INVALID_REFRESH_TOKEN` | 401 | Sesión inválida | "Tu sesión ya no es válida. Inicia sesión de nuevo." |
| `FORBIDDEN_ROLE` | 403 | Rol no permitido | "Esta acción no está disponible para tu tipo de cuenta." |
| `FORBIDDEN_RESOURCE` | 403 | Recurso ajeno | Depende del recurso: "Este servicio pertenece a otro negocio.", "Esta profesional pertenece a otro negocio.", "Esta cita pertenece a otro negocio.", "Esta cita pertenece a otra clienta." o "La sesión no pertenece a un negocio registrado." |
| `ROUTE_NOT_FOUND` | 404 | Ruta inexistente | "La ruta solicitada no existe." |
| `SERVICE_NOT_FOUND` | 404 | Servicio inexistente | "El servicio no existe." |
| `APPOINTMENT_NOT_FOUND` | 404 | Cita inexistente | "La cita no existe." |
| `PROFESSIONAL_NOT_FOUND` | 404 | Profesional inexistente | "La profesional no existe." — E-19 y E-20, pendiente de implementar |
| `EMAIL_TAKEN` | 409 | Correo registrado | "Ese correo ya tiene una cuenta. Inicia sesión." |
| `SLOT_TAKEN` | 409 | Cupo tomado | "Alguien acaba de tomar esa hora. Elige otra." |
| `SCHEDULE_OVERLAP` | 409 | Horario solapado | "El horario se cruza con otro servicio de la misma profesional (día N)." — N es el día ISO |
| `APPOINTMENT_NOT_CANCELLABLE` | 409 | Cita no cancelable | "Esta cita ya no se puede cancelar: ya fue cancelada o rechazada, o ya pasó." |
| `APPOINTMENT_ALREADY_RESPONDED` | 409 | Cita ya respondida | "Esta cita ya fue respondida o cancelada, o ya pasó." |
| `LAST_PROFESSIONAL` | 409 | Última profesional | "El negocio debe tener al menos una profesional." — E-20, pendiente de implementar |
| `PROFESSIONAL_IN_USE` | 409 | Profesional en uso | "Esta profesional tiene servicios o citas registradas y no se puede eliminar. Asigna sus servicios a otra profesional o páusalos." — E-20, pendiente de implementar |
| `SERVICE_HAS_APPOINTMENTS` | 409 | Servicio con citas | "Este servicio tiene citas registradas y no se puede eliminar. Puedes pausarlo para que deje de aparecer en el catálogo." — E-21, pendiente de implementar |
| `SERVICE_PAUSED` | 410 | Servicio pausado | "Este servicio ya no está disponible." |
| `PAYLOAD_TOO_LARGE` | 413 | Petición demasiado grande | "La petición supera el tamaño máximo de 100 KB." |
| `VALIDATION_FAILED` | 422 | Validación fallida | "Revisa los campos marcados." + `errors` |
| `INTERNAL_ERROR` | 500 | Error interno | "Ocurrió un error inesperado. Intenta de nuevo en un momento." |

Los mensajes de cada campo en `errors` están en la ficha de cada endpoint (§5).

### 2.3 Los errores sin cuerpo

**No hay.** Todo error, incluido el 401, trae el cuerpo de §2.1. El único código **exitoso** sin
cuerpo es el **204** de [E-04](#e-04--post-v1authlogout) y de los borrados [E-20](#e-20--delete-v1businessprofessionalsprofessionalid) y [E-21](#e-21--delete-v1businessservicesserviceid).

---

## 3. Catálogo de códigos de estado

| Código | Cuándo se usa | Cuándo no |
|--------|---------------|-----------|
| 200 | Operación con cuerpo: lecturas, actualizaciones, cancelar, responder | — |
| 201 | Se creó un recurso: registro, cita, servicio, profesional. Devuelve el recurso con su `id`. **También** al repetir una creación de cita con la misma `clientRequestId` (§6) | Nunca para actualizaciones |
| 204 | Cerrar sesión y eliminar (E-20, E-21) | Si hay algo que devolver |
| 400 | El cuerpo no es JSON válido (`MALFORMED_JSON`) | Para reglas de negocio ni para campos inválidos: eso es 422 |
| 401 | No hay credencial, venció, o no vale (`AUTH_REQUIRED`, `SESSION_EXPIRED`, `INVALID_CREDENTIALS`, `INVALID_REFRESH_TOKEN`) | Si la credencial vale pero el rol no alcanza |
| 403 | La credencial vale pero no alcanza: rol equivocado o recurso de otra persona | Si el recurso no existe (ver D-05) |
| 404 | El recurso o la ruta no existen | Para validación |
| 409 | Conflicto con el estado actual o con otra operación: cupo tomado, correo repetido, horario solapado, cita ya respondida o no cancelable, borrar algo que tiene historia o la última profesional | Para validación de campos |
| 410 | El servicio existe pero está pausado (`SERVICE_PAUSED`) | Si no existe: eso es 404 |
| 413 | Cuerpo de más de 100 KB | — |
| 422 | La petición se entendió pero viola una regla: campos inválidos, cupo inexistente, profesional de otro negocio, límite de 20 profesionales | Para JSON mal formado |
| 500 | **Solo** un fallo no previsto (`INTERNAL_ERROR`) | **Ningún error de este contrato es un 500.** Si aparece en una sonda, es un defecto |

**400 contra 422:** 400 es "no te entendí" (el JSON no se puede leer); 422 es "te entendí
perfectamente y no se puede". Un parámetro de consulta con formato inválido (`date=ayer`) es 422,
porque la petición se interpretó y lo que falló es una regla.

---

## 4. Decisiones cerradas

Cada una estuvo abierta en algún momento. No se vuelven a abrir aquí.

| # | Decisión |
|---|----------|
| D-01 | Una sola forma de error, `application/problem+json`, con `code` estable (§2). Reemplaza a la forma anterior `{ "error": "..." }` desde el 2026-09-27 |
| D-02 | Identificadores con prefijo y aleatorios, no UUID ni secuenciales (§1.3) |
| D-03 | Importes enteros en COP, moneda implícita en el nombre del campo (§1.3) |
| D-04 | Todo instante con `-05:00`; el servidor fecha las operaciones (§1.3) |
| D-05 | **Existencia antes que propiedad:** un recurso que no existe responde 404 aunque tampoco fuera tuyo. Revela si un `id` existe; se acepta porque los `id` son aleatorios y no se pueden recorrer |
| D-06 | El catálogo, el detalle y la disponibilidad son **anónimos**: se explora sin cuenta |
| D-07 | El registro de un negocio crea su primera profesional con el nombre de la cuenta |
| D-08 | La idempotencia de crear cita va en el cuerpo (`clientRequestId`), no en una cabecera `Idempotency-Key` (§6) |
| D-09 | Concurrencia: **gana el último** en editar servicio y en pausar; el doble agendamiento lo impide el motor (§7) |
| D-10 | Dos formas por entidad: `ServiceSummary` para listas, `ServiceDetail` para el detalle (§5, "Formas compartidas") |
| D-11 | `type` y `scope` desconocidos se ignoran en vez de responder 422 (hueco H-04 si se decide cambiarlo) |

---

## 5. Fichas de endpoint

### Formas compartidas

Las fichas las nombran en lugar de repetirlas.

**`Session`** (E-01, E-02)

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `accessToken` | string | no | JWT, 60 min |
| `refreshToken` | string | no | JWT, 30 días |
| `user.id` | string | no | `usr_…` |
| `user.name` | string | no | Nombre de la cuenta |
| `user.role` | string | no | `client` o `business` |

**`ServiceSummary`** (listas del catálogo)

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `id` | string | no | `svc_…` |
| `name` | string | no | Nombre, hasta 60 caracteres |
| `type` | string | no | `traditional`, `semi_permanent`, `acrylic`, `removal`, `nail_art` |
| `priceCop` | entero | no | Precio en COP |
| `durationMinutes` | entero | no | Múltiplo de 15 |
| `imageUrl` | string | **sí** | URL absoluta de la imagen. **Hoy siempre `null`**: no hay subida (H-05) |
| `professional.id` / `professional.name` | string | no | Quién atiende |
| `business.id` / `business.name` / `business.address` | string | no | El salón y su dirección |

El servicio **no tiene** foto de galería, calificación ni distancia, y no es un olvido.

**`ServiceDetail`** = `ServiceSummary` más:

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `description` | string | no | Qué incluye |
| `isPublished` | boolean | no | `false` = pausado |

**`Appointment`** (vista de la clienta: E-08, E-09, E-10)

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `id` | string | no | `apt_…` |
| `status` | string | no | `pending`, `confirmed`, `rejected`, `cancelled`, `completed`, `no_show` |
| `startsAt` | string | no | Instante con `-05:00` |
| `service.id` / `service.name` | string | no | Servicio; el nombre es la **copia** del día en que se agendó |
| `service.priceCop` / `service.durationMinutes` | entero | no | Copias del día en que se agendó |
| `professional` | objeto | no | `{ id, name }` |
| `business` | objeto | no | `{ id, name, address }` |
| `rejectionReason` | string | **sí** | Solo con `status = rejected`; si no, `null` |
| `createdAt` | string | no | **Solo en E-08.** Cuándo se agendó |

**`BusinessAppointment`** (vista del negocio: E-16, E-17) = `Appointment` **sin** `rejectionReason`
y **con**:

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `client.name` | string | no | Nombre de la clienta |
| `client.phone` | string | no | Celular, 10 dígitos |

---

### E-01 · POST /v1/auth/register

| Autorización | Anónimo |
|---|---|
| Idempotente | No. Repetirlo responde 409 `EMAIL_TAKEN`, así que no crea duplicados |
| Integración en la app | [auth-register.md](./endpoints/auth-register.md) |

**Petición** (`application/json`)

| Campo | Tipo | Obligatorio | Reglas |
|-------|------|-------------|--------|
| `role` | string | sí | `client` o `business` |
| `name` | string | sí | No vacío |
| `phone` | string | sí | Exactamente 10 dígitos |
| `email` | string | sí | Formato de correo. Se guarda en minúsculas |
| `password` | string | sí | Al menos 8 caracteres |
| `salonName` | string | solo si `role` es `business` | No vacío |
| `address` | string | solo si `role` es `business` | No vacía |

**Respuesta 201:** `Session`. Si `role` es `business`, además quedan creados el negocio y su
primera profesional.

**Errores**

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | Campos inválidos | `VALIDATION_FAILED` | `role`: "Debe ser \"client\" o \"business\"" · `name`: "Es requerido" · `phone`: "Debe tener 10 dígitos" · `email`: "Formato de correo inválido" · `password`: "Debe tener al menos 8 caracteres" · `salonName`: "Es requerido para una cuenta de negocio" · `address`: "Es requerida para una cuenta de negocio" |
| 409 | El correo ya existe (sin distinguir mayúsculas) | `EMAIL_TAKEN` | "Ese correo ya tiene una cuenta. Inicia sesión." |

**Notas:** orden de comprobación: todos los campos a la vez (el 422 trae **todos** los que
fallaron) → correo repetido. No existe rol de administrador.

### E-02 · POST /v1/auth/login

| Autorización | Anónimo |
|---|---|
| Idempotente | Sí en efecto (no cambia estado), pero cada llamada emite tokens nuevos |
| Integración en la app | [auth-login.md](./endpoints/auth-login.md) |

**Petición:** `email` (string, sí), `password` (string, sí).

**Respuesta 200:** `Session`.

**Errores**

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | `email` sin formato de correo | `VALIDATION_FAILED` | `email`: "Formato de correo inválido" |
| 401 | Correo inexistente **o** contraseña errada | `INVALID_CREDENTIALS` | "Correo o contraseña incorrectos." |

**Notas:** a propósito no dice cuál de los dos falló.

### E-03 · POST /v1/auth/refresh

| Autorización | Anónimo; exige `refreshToken` válido |
|---|---|
| Idempotente | **No**: cada llamada revoca el token usado. Dos llamadas simultáneas con el mismo token: una 200 y otra 401 |
| Integración en la app | [auth-refresh.md](./endpoints/auth-refresh.md) |

**Petición:** `refreshToken` (string, sí).

**Respuesta 200:** `accessToken` (string, no nulo), `refreshToken` (string, no nulo, **nuevo**).

**Errores**

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 401 | Falta, firma inválida, vencido, ya usado, revocado por logout, o la cuenta ya no existe | `INVALID_REFRESH_TOKEN` | "Tu sesión ya no es válida. Inicia sesión de nuevo." |

### E-04 · POST /v1/auth/logout

| Autorización | Anónimo; exige `refreshToken` bien firmado |
|---|---|
| Idempotente | Sí: revocar uno ya revocado también responde 204 |
| Integración en la app | [auth-logout.md](./endpoints/auth-logout.md) |

**Petición:** `refreshToken` (string, sí).

**Respuesta 204:** sin cuerpo.

**Errores**

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 401 | Falta, firma inválida o vencido | `INVALID_REFRESH_TOKEN` | "Tu sesión ya no es válida. Inicia sesión de nuevo." |

**Notas:** no revoca el `accessToken` (§1.2). La app cierra sesión localmente pase lo que pase.

### E-05 · GET /v1/services

| Autorización | Anónimo |
|---|---|
| Idempotente | Sí |
| Integración en la app | [catalog-list-services.md](./endpoints/catalog-list-services.md) |

**Consulta:** `type` (string, no; ver §1.5) · `page` · `pageSize` (§1.4).

**Respuesta 200:** página (§1.4) de `ServiceSummary`, **solo publicados**, de todos los negocios.

**Errores:** ninguno propio (`type`, `page` y `pageSize` inválidos se corrigen o se ignoran).

### E-06 · GET /v1/services/{serviceId}

| Autorización | Anónimo |
|---|---|
| Idempotente | Sí |
| Integración en la app | [catalog-service-detail.md](./endpoints/catalog-service-detail.md) |

**Respuesta 200:** `ServiceDetail` (siempre con `isPublished: true`, porque pausado responde 410).

**Errores**

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 404 | No existe | `SERVICE_NOT_FOUND` | "El servicio no existe." |
| 410 | Existe pero está pausado | `SERVICE_PAUSED` | "Este servicio ya no está disponible." |

### E-07 · GET /v1/services/{serviceId}/availability

| Autorización | Anónimo |
|---|---|
| Idempotente | Sí (pero la respuesta cambia en cuanto alguien agenda) |
| Integración en la app | [booking-availability.md](./endpoints/booking-availability.md) |

**Consulta:** `date` (string `YYYY-MM-DD`, **sí**, entre hoy y hoy + 14 días, en Colombia).

**Respuesta 200**

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `date` | string | no | El día pedido |
| `durationMinutes` | entero | no | Duración del servicio; también el tamaño de cada cupo |
| `slots` | array | no | Cupos del día ordenados por hora. Vacío si ese día no se atiende |
| `slots[].id` | string | no | `slt_AAAAMMDD_HHmm` |
| `slots[].startsAt` | string | no | Instante con `-05:00` |
| `slots[].isAvailable` | boolean | no | `false` si ya está tomado por una cita activa **o** ya pasó |

**Errores** — orden: `date` → servicio existe → publicado.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | `date` falta o no es `YYYY-MM-DD` | `VALIDATION_FAILED` | `date`: "Formato debe ser YYYY-MM-DD" |
| 422 | `date` antes de hoy o después de 14 días | `VALIDATION_FAILED` | `date`: "Debe estar entre hoy y los próximos 14 días" |
| 404 | El servicio no existe | `SERVICE_NOT_FOUND` | "El servicio no existe." |
| 410 | El servicio está pausado | `SERVICE_PAUSED` | "Este servicio ya no está disponible." |

**Notas:** los cupos se calculan partiendo cada franja del horario de ese día en bloques de
`durationMinutes`; un bloque que no cabe completo al final de la franja no se ofrece.

### E-08 · POST /v1/appointments

| Autorización | Rol `client` |
|---|---|
| Idempotente | **Con `clientRequestId`** (§6) |
| Integración en la app | [booking-create-appointment.md](./endpoints/booking-create-appointment.md) |

**Petición**

| Campo | Tipo | Obligatorio | Reglas |
|-------|------|-------------|--------|
| `serviceId` | string | sí | Servicio publicado |
| `slotId` | string | sí | Un `slots[].id` de E-07, tal cual |
| `clientRequestId` | string | sí | UUID generado por la app **una vez por intento de agendar**; se reenvía idéntico en cada reintento |

**Respuesta 201:** `Appointment` con `status: "pending"` y `createdAt`.

**Errores** — **orden de comprobación**:

1. sesión (401) → rol (403)
2. los tres campos presentes (422)
3. **si ya existe una cita de esta clienta con ese `clientRequestId`, se devuelve esa (201) y se
   termina aquí**, aunque el servicio ya esté pausado
4. el servicio existe (404) → está publicado (410)
5. `slotId` tiene el formato (422) → coincide con un cupo del horario y no ha pasado (422)
6. el cupo no está tomado (409)

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 401 | Sin token / token inválido o vencido | `AUTH_REQUIRED` / `SESSION_EXPIRED` | "Inicia sesión para continuar." / "Tu sesión venció. Inicia sesión de nuevo." |
| 403 | Sesión de negocio | `FORBIDDEN_ROLE` | "Esta acción no está disponible para tu tipo de cuenta." |
| 422 | Falta un campo | `VALIDATION_FAILED` | `serviceId` / `slotId` / `clientRequestId`: "Es requerido" |
| 404 | El servicio no existe | `SERVICE_NOT_FOUND` | "El servicio no existe." |
| 410 | El servicio está pausado | `SERVICE_PAUSED` | "Este servicio ya no está disponible." |
| 422 | Cupo con formato inválido, fuera del horario o ya pasado | `VALIDATION_FAILED` | `slotId`: "Cupo inexistente o vencido" |
| **409** | **Otra clienta tomó el cupo** | **`SLOT_TAKEN`** | "Alguien acaba de tomar esa hora. Elige otra." |

**Notas:** contraintuitivo: un `slotId` inventado sobre un servicio pausado responde **410**, no
422, porque el servicio se comprueba antes que el cupo. Y un reintento con la misma
`clientRequestId` responde **201 con la cita original** aunque entre tanto se haya pausado el
servicio.

### E-09 · GET /v1/appointments/mine

| Autorización | Rol `client` |
|---|---|
| Idempotente | Sí |
| Integración en la app | [appointments-list-mine.md](./endpoints/appointments-list-mine.md) |

**Consulta:** `scope` (`upcoming` \| `past`, no; §1.5) · `page` (§1.4). **Sin `pageSize`**: 20 fijo.

**Respuesta 200:** página de `Appointment` (sin `createdAt`) de la clienta del token, en cualquier
estado.

**Errores:** 401 `AUTH_REQUIRED` / `SESSION_EXPIRED` · 403 `FORBIDDEN_ROLE`.

### E-10 · PATCH /v1/appointments/{appointmentId}/cancel

| Autorización | Rol `client`, dueña de la cita |
|---|---|
| Idempotente | **No**: la segunda llamada responde 409 |
| Integración en la app | [appointments-cancel.md](./endpoints/appointments-cancel.md) |

**Petición:** `reason` (string, **no**; se guarda si viene). El cuerpo puede faltar.

**Respuesta 200:** `Appointment` con `status: "cancelled"`.

**Errores** — orden: sesión → rol → existe → es suya → estado y hora.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 404 | No existe | `APPOINTMENT_NOT_FOUND` | "La cita no existe." |
| 403 | Es de otra clienta | `FORBIDDEN_RESOURCE` | "Esta cita pertenece a otra clienta." |
| 409 | No está `pending` ni `confirmed`, o ya empezó | `APPOINTMENT_NOT_CANCELLABLE` | "Esta cita ya no se puede cancelar: ya fue cancelada o rechazada, o ya pasó." |

Más 401 y 403 `FORBIDDEN_ROLE` como en E-08. **Notas:** no hay plazo mínimo de anticipación: se
puede cancelar hasta el instante en que empieza. Cancelar libera el cupo al instante.

### E-11 · GET /v1/business/professionals

| Autorización | Rol `business` |
|---|---|
| Idempotente | Sí |
| Integración en la app | [business-list-professionals.md](./endpoints/business-list-professionals.md) |

**Respuesta 200:** `items` (array, no nulo, nunca vacío): `{ id, name }` ordenados por nombre.

**Errores:** 401 · 403 `FORBIDDEN_ROLE`.

### E-12 · POST /v1/business/professionals

| Autorización | Rol `business` |
|---|---|
| Idempotente | No: un reintento crea otra profesional |
| Integración en la app | [business-create-professional.md](./endpoints/business-create-professional.md) |

**Petición:** `name` (string, sí, no vacío tras recortar espacios, hasta 60 caracteres).

**Respuesta 201:** `{ id, name }` (el nombre ya recortado).

**Errores** — orden: sesión → rol → `name` → límite.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | `name` vacío o largo | `VALIDATION_FAILED` | `name`: "Es requerido, hasta 60 caracteres" |
| 422 | Ya hay 20 | `VALIDATION_FAILED` | `name`: "Un negocio puede tener hasta 20 profesionales" |

**Notas:** la profesional **no tiene** foto, teléfono ni especialidad. Se edita con [E-19](#e-19--put-v1businessprofessionalsprofessionalid) y se borra con [E-20](#e-20--delete-v1businessprofessionalsprofessionalid).

### E-13 · GET /v1/business/services

| Autorización | Rol `business` |
|---|---|
| Idempotente | Sí |
| Integración en la app | [business-list-services.md](./endpoints/business-list-services.md) |

**Consulta:** `page` · `pageSize` (§1.4).

**Respuesta 200:** página de `ServiceDetail` **más `schedule`**, publicados **y pausados**, solo del
negocio del token.

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `items[].schedule` | array | no | Franjas ordenadas por `weekday` y `startTime` |
| `items[].schedule[].weekday` | entero | no | 1 = lunes … 7 = domingo |
| `items[].schedule[].startTime` / `endTime` | string | no | `HH:mm` |

**Errores:** 401 · 403 `FORBIDDEN_ROLE`.

### E-14 · POST /v1/business/services

| Autorización | Rol `business` |
|---|---|
| Idempotente | No: un reintento tras un timeout puede crear el servicio dos veces (el segundo choca por horario con 409 si es la misma profesional) |
| Integración en la app | [business-create-service.md](./endpoints/business-create-service.md) |

**Petición**

| Campo | Tipo | Obligatorio | Reglas |
|-------|------|-------------|--------|
| `name` | string | sí | No vacío, hasta 60 caracteres |
| `type` | string | sí | Uno de los cinco tipos |
| `description` | string | sí | No vacía |
| `priceCop` | entero | sí | Mayor que 0 |
| `durationMinutes` | entero | sí | Múltiplo de 15, entre 15 y 240 |
| `professionalId` | string | sí | De E-11; del mismo negocio |
| `schedule` | array | sí | Al menos una franja `{ weekday, startTime, endTime }`; `weekday` 1–7, horas `HH:mm`, `endTime > startTime` |

**Respuesta 201:** `ServiceDetail` con `isPublished: true`.

**Errores** — orden: sesión → rol → **todos los campos a la vez** → profesional del negocio →
solape.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | Campos | `VALIDATION_FAILED` | `name`: "Es requerido, hasta 60 caracteres" · `type`: "Tipo de servicio inválido" · `description`: "Es requerida" · `priceCop`: "Debe ser un entero mayor a 0" · `durationMinutes`: "Debe ser múltiplo de 15, entre 15 y 240" · `professionalId`: "Es requerido" · `schedule`: "Debe incluir al menos un día de atención" o "Cada día debe tener weekday (1-7), startTime y endTime válidos, con endTime después de startTime" |
| 422 | La profesional es de otro negocio o no existe | `VALIDATION_FAILED` | `professionalId`: "No pertenece a este negocio" |
| 409 | Franja que se cruza con otro servicio de la misma profesional | `SCHEDULE_OVERLAP` | "El horario se cruza con otro servicio de la misma profesional (día N)." |

**Notas:** no se puede crear un servicio pausado. `imageUrl` no se recibe (H-05).

### E-15 · PUT /v1/business/services/{serviceId}

| Autorización | Rol `business`, dueño del servicio |
|---|---|
| Idempotente | Sí: reemplazo completo |
| Integración en la app | [business-update-service.md](./endpoints/business-update-service.md) |

**Petición:** **idéntica a E-14**, todos los campos obligatorios. `isPublished` se ignora si viene.

**Respuesta 200:** `ServiceDetail`.

**Errores** — orden: sesión → rol → campos → existe → es del negocio → profesional → solape (con
**otros** servicios; el propio no cuenta).

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | Campos | `VALIDATION_FAILED` | Los mismos de E-14 |
| 404 | No existe | `SERVICE_NOT_FOUND` | "El servicio no existe." |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE` | "Este servicio pertenece a otro negocio." |
| 422 | Profesional ajena | `VALIDATION_FAILED` | `professionalId`: "No pertenece a este negocio" |
| 409 | Solape | `SCHEDULE_OVERLAP` | "El horario se cruza con otro servicio de la misma profesional (día N)." |

**Notas:** todo-o-nada: el servicio y su horario se reemplazan en una transacción. Las citas ya
agendadas **no cambian**: conservan nombre, precio, duración y hora, aunque queden fuera del horario
nuevo.

### E-16 · GET /v1/business/agenda

| Autorización | Rol `business` |
|---|---|
| Idempotente | Sí |
| Integración en la app | [business-agenda.md](./endpoints/business-agenda.md) |

**Consulta:** `date` (string `YYYY-MM-DD`, **sí**, cualquier día; sin límite de rango).

**Respuesta 200:** `date` (string) e `items`: todas las `BusinessAppointment` del negocio ese día
(`inicio <= startsAt < inicio + 24 h`), en **cualquier estado**, ordenadas por hora.

**Errores:** 422 `VALIDATION_FAILED` `date`: "Formato debe ser YYYY-MM-DD" · 401 · 403
`FORBIDDEN_ROLE`.

### E-17 · PATCH /v1/business/appointments/{appointmentId}/respond

| Autorización | Rol `business`, dueño de la cita |
|---|---|
| Idempotente | **No**: responder dos veces da 409 |
| Integración en la app | [business-respond-appointment.md](./endpoints/business-respond-appointment.md) |

**Petición**

| Campo | Tipo | Obligatorio | Reglas |
|-------|------|-------------|--------|
| `status` | string | sí | `confirmed` o `rejected` |
| `reason` | string | solo si `status` es `rejected` | No vacío. Lo ve la clienta en `rejectionReason` |

**Respuesta 200:** `BusinessAppointment` con el estado nuevo.

**Errores** — orden: sesión → rol → `status` → `reason` → existe → es del negocio → estado y hora.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | `status` inválido | `VALIDATION_FAILED` | `status`: "Debe ser \"confirmed\" o \"rejected\"" |
| 422 | Rechazo sin motivo | `VALIDATION_FAILED` | `reason`: "Es requerido al rechazar" |
| 404 | No existe | `APPOINTMENT_NOT_FOUND` | "La cita no existe." |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE` | "Esta cita pertenece a otro negocio." |
| 409 | No está `pending`, o ya empezó | `APPOINTMENT_ALREADY_RESPONDED` | "Esta cita ya fue respondida o cancelada, o ya pasó." |

**Notas:** una cita `confirmed` no se puede volver a `rejected` por aquí. Rechazar libera el cupo.

### E-18 · PATCH /v1/business/services/{serviceId}/status

| Autorización | Rol `business`, dueño del servicio |
|---|---|
| Idempotente | Sí: pausar un servicio pausado deja el mismo estado y responde 200 |
| Integración en la app | [business-update-service-status.md](./endpoints/business-update-service-status.md) |

**Petición:** `isPublished` (boolean, sí).

**Respuesta 200:** `ServiceDetail`.

**Errores** — orden: sesión → rol → `isPublished` → existe → es del negocio.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | Falta o no es booleano | `VALIDATION_FAILED` | `isPublished`: "Es requerido y debe ser booleano" |
| 404 | No existe | `SERVICE_NOT_FOUND` | "El servicio no existe." |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE` | "Este servicio pertenece a otro negocio." |

**Notas:** pausar no toca las citas ya agendadas. Efectos en [data-model.md §6](./data-model.md#6-baja-lógica).

### E-19 · PUT /v1/business/professionals/{professionalId}

> **E-19, E-20 y E-21 se agregaron el 2026-10-28** para completar los CRUD de profesional y servicio
> que exige el c3-project (HU-15 y HU-16). Están **diseñados y pendientes de implementar**: no tienen
> sonda en §10 hasta que existan en `beauty-salon-api`.

| Autorización | Rol `business`, dueño de la profesional |
|---|---|
| Idempotente | Sí |
| Integración en la app | [business-update-professional.md](./endpoints/business-update-professional.md) |

**Petición:** `name` (string, sí, no vacío tras recortar espacios, hasta 60 caracteres).

**Respuesta 200:** `{ id, name }`.

**Errores** — orden: sesión → rol → `name` → existe → es del negocio.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 422 | `name` vacío o largo | `VALIDATION_FAILED` | `name`: "Es requerido, hasta 60 caracteres" |
| 404 | No existe | `PROFESSIONAL_NOT_FOUND` | "La profesional no existe." |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE` | "Esta profesional pertenece a otro negocio." |

**Notas:** las citas no guardan copia del nombre de la profesional, así que el nombre nuevo se ve
también en las citas pasadas.

### E-20 · DELETE /v1/business/professionals/{professionalId}

| Autorización | Rol `business`, dueño de la profesional |
|---|---|
| Idempotente | El efecto sí; repetirlo responde 404 |
| Integración en la app | [business-delete-professional.md](./endpoints/business-delete-professional.md) |

**Respuesta 204:** sin cuerpo. Borrado físico.

**Errores** — orden: sesión → rol → existe → es del negocio → es la última → está en uso.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 404 | No existe | `PROFESSIONAL_NOT_FOUND` | "La profesional no existe." |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE` | "Esta profesional pertenece a otro negocio." |
| 409 | Es la única del negocio | `LAST_PROFESSIONAL` | "El negocio debe tener al menos una profesional." |
| 409 | Tiene servicios o citas | `PROFESSIONAL_IN_USE` | "Esta profesional tiene servicios o citas registradas y no se puede eliminar. Asigna sus servicios a otra profesional o páusalos." |

**Notas:** si la clave foránea rechaza el borrado por una carrera, la API responde el mismo 409
`PROFESSIONAL_IN_USE`, nunca 500.

### E-21 · DELETE /v1/business/services/{serviceId}

| Autorización | Rol `business`, dueño del servicio |
|---|---|
| Idempotente | El efecto sí; repetirlo responde 404 |
| Integración en la app | [business-delete-service.md](./endpoints/business-delete-service.md) |

**Respuesta 204:** sin cuerpo. Borrado físico del servicio y, en cascada, de su horario.

**Errores** — orden: sesión → rol → existe → es del negocio → tiene citas.

| Código | Cuándo | `code` | Mensaje literal |
|--------|--------|--------|-----------------|
| 404 | No existe | `SERVICE_NOT_FOUND` | "El servicio no existe." |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE` | "Este servicio pertenece a otro negocio." |
| 409 | Tiene al menos una cita, en cualquier estado | `SERVICE_HAS_APPOINTMENTS` | "Este servicio tiene citas registradas y no se puede eliminar. Puedes pausarlo para que deje de aparecer en el catálogo." |

**Notas:** un servicio con historia se **pausa** (E-18), no se borra. Si la clave foránea rechaza el
borrado por una carrera, la API responde el mismo 409, nunca 500.

---

## 6. Idempotencia y reintentos

| Operación | ¿Se puede reintentar sola? |
|-----------|----------------------------|
| Lecturas (E-05, E-06, E-07, E-09, E-11, E-13, E-16) | **Sí**, siempre |
| E-15 editar servicio (reemplazo completo) | **Sí**: aplicarlo dos veces deja el mismo estado |
| E-18 pausar / publicar | **Sí** |
| E-19 editar profesional | **Sí**: reemplaza el nombre |
| E-04 logout | **Sí**: repetirlo responde 204 |
| E-08 crear cita | **Sí, con la misma `clientRequestId`** |
| E-01 registro | No se reintenta sola; repetirla no duplica (409) |
| E-03 refresh | **No**: rota el token; un reintento con el mismo token da 401 |
| E-10 cancelar, E-17 responder | **No**: la segunda llamada da 409 aunque la primera haya funcionado. La app debe tratar ese 409 tras un timeout como "probablemente ya se hizo" y recargar |
| E-12 crear profesional, E-14 crear servicio | **No**: pueden duplicar |
| E-20, E-21 eliminar | **No** se reintentan solos: el segundo intento da 404 aunque el primero haya funcionado. Tras un timeout, la app recarga la lista y, si el registro ya no está, lo da por hecho |

**Clave de idempotencia de E-08** (`clientRequestId`, en el cuerpo):

1. **Misma clave, mismo cuerpo:** responde 201 con **la misma cita** que la primera vez, sin crear
   otra. Lo garantiza el motor (`uq_appointment_client_request`).
2. **Misma clave, cuerpo distinto:** hoy responde **201 con la cita original**, ignorando el cuerpo
   nuevo. El manual pide 409; hueco H-06.
3. **Cuánto se conserva:** **para siempre** (es una columna de la cita). El manual pide un tiempo
   declarado; no hace falta olvidarla porque la genera el cliente y es un UUID nuevo por intento.

Los tiempos de espera y la política de reintento de la app (2 reintentos con 300 y 900 ms, solo en
lecturas) están en [`api-networking.md`](./api-networking.md): 10 s lecturas, 8 s disponibilidad,
15 s escrituras.

---

## 7. Concurrencia

| Recurso | Estrategia | Qué pasa |
|---------|------------|----------|
| Un cupo | **La decide el motor** | Dos clientas agendan el mismo cupo a la vez: una recibe 201 y la otra 409 `SLOT_TAKEN`, siempre. Probado en §10 |
| Un servicio (E-15, E-18) | **Gana el último** | Si el negocio edita el mismo servicio desde dos dispositivos, **se pierde el cambio anterior sin aviso**. Se acepta: un negocio es una sola persona |
| Una cita (E-10, E-17) | **Gana el último, con una ventana** | Se comprueba el estado y luego se actualiza, en dos pasos. Si la clienta cancela y el negocio confirma en el mismo instante, puede quedar el estado del segundo. Hueco H-07 |
| Horario (solape) | Solo dominio | Dos servicios creados a la vez para la misma profesional pueden solaparse ([data-model.md §2.4](./data-model.md#24-service--raíz-de-agregado)) |

No hay `version` ni `ETag` en esta versión.

---

## 8. Sincronización

**No hay sincronización incremental en esta versión.** La app usa caché de lectura con vencimiento
(catálogo y Mis citas) y el resto es online-only; ver [`offline-sync.md`](./offline-sync.md).

| Lo que pide el manual (§6.3) | Estado |
|------------------------------|--------|
| Parámetro `updatedSince` | No existe (H-08) |
| Los borrados viajan como marcas | No hace falta hoy: **no hay borrado físico** de nada que la app cachee; un servicio pausado es un cambio de `isPublished` ([data-model.md §6](./data-model.md#6-baja-lógica)) |
| Instante de corte puesto por el servidor | No existe (H-08) |
| `updatedAt` en toda entidad sincronizable | Existe en la base, **no viaja** en el JSON (H-08) |

**Conflictos:** gana el servidor, sin excepción. Crear, cancelar y todo lo del negocio son
online-only, así que no hay escrituras hechas sin red que reconciliar.

---

## 9. Versionado

- **Prefijo en la ruta:** `/v1`. Un cambio rompiente sube a `/v2`.
- **Versión anterior:** hoy no hay ninguna que sostener (la app no está publicada). Cuando exista
  `/v2`, `/v1` vivirá **hasta que la última versión publicada de la app que la usa deje de tener
  soporte**, como mínimo 3 meses.
- **Quien consume ignora los campos que no conoce**, en vez de fallar.

| Cambio | ¿Rompe? |
|--------|---------|
| Agregar un campo opcional a la respuesta | No |
| Agregar un parámetro de consulta opcional | No |
| Agregar un `code` de error nuevo | No, si la app trata un `code` desconocido por su status HTTP |
| Quitar o renombrar un campo, un `code` o una ruta | **Sí** |
| Cambiar un tipo, o volver nulable lo que no lo era | **Sí** |
| Cambiar un código de estado o el orden de comprobación de §5 | **Sí** |
| Volver obligatorio un campo que no lo era | **Sí** |
| Reescribir el texto de `detail` o de `errors` | No: la app no lo compara |

**Historial:** el 2026-09-25 se renombraron rutas y valores a inglés
([ADR-012](../01-architecture/decisions/records/ADR-012-nombres-en-ingles.md)) y el 2026-09-27 cambió
la forma del error (D-01). Ambos son rompientes y se hicieron **dentro de `/v1`** porque todavía no
había ninguna app publicada que los consumiera.

---

## 10. Sondas

Llamadas reales con `beauty-salon-api/scripts/smoke-test.ps1` contra el sistema levantado con
`beauty-salon-infra`, el **2026-09-27**. Cada error se comprueba además contra la forma de §2:
`Content-Type: application/problem+json`, `title` y `detail` no vacíos, `status` igual al código
HTTP y el `code` esperado. Resultado: **49 de 49**.

| # | Llamada | Se esperaba | Se obtuvo | ¿Cuadra? |
|---|---------|-------------|-----------|----------|
| 1 | POST /auth/register (business) | 201 | 201 | Sí |
| 2 | POST /auth/register (client) | 201 | 201 | Sí |
| 3 | POST /auth/register rol inválido | 422 VALIDATION_FAILED | 422 VALIDATION_FAILED | Sí |
| 4 | POST /auth/register correo repetido (en mayúsculas) | 409 EMAIL_TAKEN | 409 EMAIL_TAKEN | Sí |
| 5 | POST /auth/login | 200 | 200 | Sí |
| 6 | POST /auth/login contraseña errada | 401 INVALID_CREDENTIALS | 401 INVALID_CREDENTIALS | Sí |
| 7 | POST /auth/login JSON mal formado | 400 MALFORMED_JSON | 400 MALFORMED_JSON | Sí |
| 8 | POST /auth/login cuerpo de 120 KB | 413 PAYLOAD_TOO_LARGE | 413 PAYLOAD_TOO_LARGE | Sí |
| 9 | GET /business/professionals (creada en registro) | 200, 1 profesional | 200, 1 profesional | Sí |
| 10 | POST /business/professionals | 201 | 201 | Sí |
| 11 | POST /business/professionals nombre vacío | 422 VALIDATION_FAILED | 422 VALIDATION_FAILED | Sí |
| 12 | GET /business/professionals como clienta | 403 FORBIDDEN_ROLE | 403 FORBIDDEN_ROLE | Sí |
| 13 | POST /business/services | 201 | 201 | Sí |
| 14 | POST /business/services tipo en español | 422 VALIDATION_FAILED | 422 VALIDATION_FAILED | Sí |
| 15 | POST /business/services horario solapado | 409 SCHEDULE_OVERLAP | 409 SCHEDULE_OVERLAP | Sí |
| 16 | GET /business/services | 200, con `schedule` | 200, con `schedule` | Sí |
| 17 | PUT /business/services/{id} | 200, precio nuevo | 200, precio nuevo | Sí |
| 18 | PUT /business/services/{id} inexistente | 404 SERVICE_NOT_FOUND | 404 SERVICE_NOT_FOUND | Sí |
| 19 | PUT /business/services/{id} de otro negocio | 403 FORBIDDEN_RESOURCE | 403 FORBIDDEN_RESOURCE | Sí |
| 20 | GET /services | 200, incluye el servicio | 200, incluye el servicio | Sí |
| 21 | GET /services?type=traditional | 200, incluye el servicio | 200, incluye el servicio | Sí |
| 22 | GET /services/{id} | 200 | 200 | Sí |
| 23 | GET /services/{id} inexistente | 404 SERVICE_NOT_FOUND | 404 SERVICE_NOT_FOUND | Sí |
| 24 | GET /services/{id}/availability | 200, 3 cupos | 200, 3 cupos | Sí |
| 25 | GET availability sin `date` | 422 VALIDATION_FAILED | 422 VALIDATION_FAILED | Sí |
| 26 | POST /appointments | 201 `pending` | 201 `pending` | Sí |
| 27 | POST /appointments mismo `clientRequestId` | 201, misma cita | 201, misma cita | Sí |
| 28 | POST /appointments cupo tomado (otra clienta) | 409 SLOT_TAKEN | 409 SLOT_TAKEN | Sí |
| 29 | POST /appointments cupo inexistente | 422 VALIDATION_FAILED | 422 VALIDATION_FAILED | Sí |
| 30 | POST /appointments con sesión de negocio | 403 FORBIDDEN_ROLE | 403 FORBIDDEN_ROLE | Sí |
| 31 | GET /appointments/mine | 200, 1 cita | 200, 1 cita | Sí |
| 32 | GET /appointments/mine sin token | 401 AUTH_REQUIRED | 401 AUTH_REQUIRED | Sí |
| 33 | GET /appointments/mine token inválido | 401 SESSION_EXPIRED | 401 SESSION_EXPIRED | Sí |
| 34 | PATCH /appointments/{id}/cancel de otra clienta | 403 FORBIDDEN_RESOURCE | 403 FORBIDDEN_RESOURCE | Sí |
| 35 | PATCH /appointments/{id}/cancel inexistente | 404 APPOINTMENT_NOT_FOUND | 404 APPOINTMENT_NOT_FOUND | Sí |
| 36 | GET /business/agenda | 200, con `client.name` | 200, con `client.name` | Sí |
| 37 | PATCH /business/appointments/{id}/respond | 200 `confirmed` | 200 `confirmed` | Sí |
| 38 | PATCH respond ya respondida | 409 APPOINTMENT_ALREADY_RESPONDED | 409 APPOINTMENT_ALREADY_RESPONDED | Sí |
| 39 | PATCH respond con estado en español | 422 VALIDATION_FAILED | 422 VALIDATION_FAILED | Sí |
| 40 | PATCH /appointments/{id}/cancel | 200 `cancelled` | 200 `cancelled` | Sí |
| 41 | PATCH /appointments/{id}/cancel repetido | 409 APPOINTMENT_NOT_CANCELLABLE | 409 APPOINTMENT_NOT_CANCELLABLE | Sí |
| 42 | PATCH /business/services/{id}/status | 200 | 200 | Sí |
| 43 | GET /services/{id} pausado | 410 SERVICE_PAUSED | 410 SERVICE_PAUSED | Sí |
| 44 | POST /auth/refresh | 200 | 200 | Sí |
| 45 | POST /auth/refresh con token ya rotado | 401 INVALID_REFRESH_TOKEN | 401 INVALID_REFRESH_TOKEN | Sí |
| 46 | POST /auth/logout | 204 | 204 | Sí |
| 47 | POST /auth/logout repetido | 204 | 204 | Sí |
| 48 | POST /auth/refresh tras logout | 401 INVALID_REFRESH_TOKEN | 401 INVALID_REFRESH_TOKEN | Sí |
| 49 | GET /servicios (ruta vieja en español) | 404 ROUTE_NOT_FOUND | 404 ROUTE_NOT_FOUND | Sí |

**Cobertura:** los 18 endpoints en su camino feliz, y 18 de los 19 `code` de §2.2. El que falta es
`INTERNAL_ERROR`, que por definición no debería observarse.

### Lo que no cuadró antes de esta versión

Las valiosas. La primera y la última se observaron con llamadas reales; las otras tres se
encontraron **leyendo el código** antes de sondear, y se dicen así. En todas, la sonda de arriba
queda como prueba del arreglo:

| Cuándo | Llamada | Se esperaba | Se obtuvo | Qué se hizo |
|--------|---------|-------------|-----------|-------------|
| 2026-09-25 | Negocio recién registrado crea un servicio | 201 | 422 `professionalId` "Es requerido": **no había forma de obtener ni crear una profesional** | Se agregaron E-11 y E-12 y la profesional automática del registro (sondas 9 y 13) |
| 2026-09-25 | Refresh con un token ya usado | 401 (lo decía la ficha) | 200, **encontrado leyendo el código**: el token viejo no se revocaba | Rotación con revocación (sonda 45) |
| 2026-09-27 | Cuerpo que no es JSON | 400 | 500, **encontrado leyendo el código**: todo error desconocido salía como 500 | El manejador traduce los errores de Express (sonda 7) |
| 2026-09-27 | Cuerpo de más de 100 KB | 413 | 500, **encontrado leyendo el código**, por la misma causa | Ídem (sonda 8) |
| 2026-09-27 | Cualquier error | `problem+json` con `detail` | `{ "error": "..." }` sin texto para la persona | D-01 (todas las sondas de error) |

---

## 11. Huecos declarados

| # | Hueco | Consecuencia | Dueño | Fecha límite |
|---|-------|--------------|-------|--------------|
| H-01 | No hay URL de producción ni despliegue | La app publicada no tiene a dónde apuntar | _por asignar_ | _por asignar_ |
| H-02 | CORS abierto a todo origen | Aceptable en desarrollo; en producción debe limitarse | _por asignar_ | _por asignar_ |
| H-03 | La paginación no devuelve `pageSize` servido ni `total`; E-09 no acepta `pageSize` | Si la app pide más de 50, no se entera del recorte por la respuesta | _por asignar_ | _por asignar_ |
| H-04 | `type` desconocido se ignora en vez de dar 422 | Un filtro mal escrito devuelve todo el catálogo sin aviso | _por asignar_ | _por asignar_ |
| H-05 | No hay subida de imágenes ni miniaturas; `imageUrl` siempre `null` | Las tarjetas del catálogo no tienen foto | _por asignar_ | _por asignar_ |
| H-06 | Misma `clientRequestId` con cuerpo distinto devuelve la cita original en vez de 409 | Un defecto de la app que reuse la clave no se detecta | _por asignar_ | _por asignar_ |
| H-07 | Cancelar y responder comprueban y actualizan en dos pasos | Una carrera de milisegundos puede dejar el estado del segundo | _por asignar_ | _por asignar_ |
| H-08 | Sin sincronización incremental (`updatedSince`, instante del servidor, `updatedAt` en el JSON) | La app vuelve a traer todo cuando vence la caché | _por asignar_ | _por asignar_ |
| H-09 | Estados `completed` y `no_show` no los asigna ningún endpoint ([data-model.md](./data-model.md) D-06) | Una cita pasada queda `confirmed` para siempre | _por asignar_ | _por asignar_ |

---

## 12. Firma

| | |
|---|---|
| **Escrito por** | Lilly Signey Puentes Rincon y Lizeth Caicedo |
| **Verificado contra** | `beauty-salon-api` con el formato `problem+json` (commit posterior a `1dfbeef`), levantado con `beauty-salon-infra`; PostgreSQL 16.13 |
| **Fecha de verificación** | 2026-09-27 — 49 de 49 sondas |

Este contrato no se corrige en silencio: cada cambio se vuelve a sondear, se actualiza esta fecha y
lo que quede sin cumplir va a §11.
