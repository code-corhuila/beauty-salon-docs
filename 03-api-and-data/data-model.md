# Modelo de datos — ManiCita

```
Fecha:              2026-09-27
Verificado contra:  PostgreSQL 16.13, base manicita, esquema public
                    beauty-salon-api en el commit 1dfbeef (migración 0001_initial_schema)
Rige sobre:         las migraciones de beauty-salon-api (src/db/migrations/)
```

Este documento es el **único sitio donde vive el modelo de datos del servidor**. Quien implemente no
debería necesitar abrir el código ni conectarse al motor para saber qué hay, de qué tipo, con qué
regla y dónde vive esa regla hoy.

La base del dispositivo (SQLite, solo caché) no está aquí: está en [`entities/`](./entities/) y en
[`persistence.md`](./persistence.md).

---

## Cómo se lee este documento

Toda regla lleva una de estas tres marcas, y solo hay tres:

| Marca | Significa |
|-------|-----------|
| **motor** | Existe en la base ahora mismo. Una inserción manual la respeta o falla |
| **solo dominio** | La garantiza el código de `beauty-salon-api` y nada más. Una inserción manual la salta sin ruido |
| **pendiente** | No existe todavía. Se nombra la tarea que la va a poner (ver §13) |

Criterio para decidir qué baja al motor: **si la regla se puede expresar en el motor, se expresa en
el motor**, y el código la repite para dar un mensaje legible. Las reglas marcadas *solo dominio*
que sí se podrían expresar en el motor están en la deuda (§13).

---

## 0. Convención de nombres

Decidida en [ADR-012](../01-architecture/decisions/records/ADR-012-nombres-en-ingles.md).

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Entidad (clase) | `PascalCase`, inglés, singular | `Appointment` |
| Tabla | `snake_case`, inglés, singular | `appointment` |
| Atributo | `snake_case`, inglés | `price_cop` |
| Clave primaria | `id` | `id` |
| Clave foránea | `<entidad>_id` | `business_id` |
| Campo del JSON | `camelCase` | `priceCop` |
| Valor de enumeración | minúsculas, inglés; el mismo en la base y en el JSON | `no_show` |
| Identificador visible | prefijo por tipo + 10 caracteres aleatorios | `apt_x7k2m9q4rb` |

**Palabras reservadas:** `user` es palabra reservada de PostgreSQL. Se resolvió **renombrando** la
tabla a `user_account`. Sus claves foráneas siguen a la entidad, no a la tabla: `user_id` en
`business` y en `revoked_refresh_token`, y `client_id` en `appointment`, porque ahí la relación es
con la clienta.

**Identificadores:** son `text` generados por la API con `nanoid` (alfabeto sin caracteres
ambiguos). No son secuenciales: una URL con `apt_x7k2m9q4rb` no dice cuántas citas hay ni permite
recorrerlas.

| Prefijo | Entidad |
|---------|---------|
| `usr_` | `UserAccount` |
| `biz_` | `Business` |
| `prf_` | `Professional` |
| `svc_` | `Service` |
| `sch_` | `Schedule` |
| `apt_` | `Appointment` |
| `slt_` | Cupo (no se guarda; ver §1) |

---

## 1. Glosario del dominio

Lo que no está en este glosario no puede aparecer como nombre de tabla ni como campo del JSON.

| Término | Qué es exactamente en este proyecto |
|---------|-------------------------------------|
| **Cuenta** (`UserAccount`) | Una persona registrada, con correo y contraseña. Tiene exactamente un rol |
| **Rol** (`role`) | `client` (clienta que agenda) o `business` (dueña de un salón o manicurista independiente). No hay más roles; no existe administrador |
| **Clienta** (`client`) | Una cuenta con rol `client`. En `appointment` es `client_id` |
| **Negocio** (`Business`) | El salón o la manicurista independiente que publica servicios. Una cuenta `business` tiene exactamente un negocio |
| **Profesional** (`Professional`) | La persona que atiende. Pertenece a un negocio. Cada servicio y cada cita tienen una. **No es una cuenta**: no inicia sesión |
| **Servicio** (`Service`) | Lo que se ofrece en el catálogo: nombre, tipo, precio, duración, profesional y horario |
| **Tipo de servicio** (`type`) | `traditional`, `semi_permanent`, `acrylic`, `removal`, `nail_art` |
| **Horario** (`Schedule`) | Una franja semanal de atención de un servicio: día (1 = lunes … 7 = domingo), hora de inicio y de fin, en hora de Colombia |
| **Cupo** (slot) | Una hora concreta en la que se puede agendar un servicio. **No se guarda**: se calcula partiendo el horario de ese día en bloques de la duración del servicio. Su identificador `slt_AAAAMMDD_HHmm` codifica fecha y hora |
| **Cita** (`Appointment`) | La reserva de una clienta sobre un cupo. Guarda **su propia copia** del nombre, precio y duración del servicio del día en que se agendó |
| **Estado de la cita** (`status`) | `pending`, `confirmed`, `rejected`, `cancelled`, `completed`, `no_show` (ver §2.6) |
| **Pausar** un servicio | Poner `is_published = false`. No es borrar: deja de ofrecer cupos nuevos, pero las citas ya agendadas se respetan |
| **Catálogo** | Los servicios publicados de todos los negocios |
| **Agenda** | Las citas de un negocio en un día |
| **Clave de solicitud** (`client_request_id`) | Un UUID que genera la app al agendar, para que un reintento no cree dos citas |
| **Refresh token revocado** | El identificador (`jti`) de un token de refresco que ya no sirve, por rotación o por cierre de sesión |

---

## 2. Entidades, agregados e invariantes

Un **agregado** es el conjunto que se guarda y se valida junto. Por eso decide qué endpoints
existen: `Schedule` no tiene endpoint propio, porque solo existe dentro de un `Service`.

```
UserAccount ──1:0..1── Business ──1:N── Professional
                          │                  │
                          └──1:N── Service ──┘ (N:1)
                                     │
                                     └──1:N── Schedule   (interna del agregado Service)

UserAccount (client) ──1:N── Appointment ──N:1── Service / Professional / Business
UserAccount ──1:N── RevokedRefreshToken
```

### 2.1 `UserAccount` — raíz de agregado

Una persona registrada que puede iniciar sesión.

| Invariante | Marca |
|------------|-------|
| `role` es `client` o `business` | **motor** (`user_account_role_check`) |
| `email` es único, comparando exacto | **motor** (`user_account_email_key`) |
| `email` es único **sin distinguir mayúsculas** | **solo dominio**: el código pasa el correo a minúsculas antes de guardarlo y de buscarlo; una inserción manual con `Ana@x.com` junto a `ana@x.com` pasa. **pendiente** índice único sobre `lower(email)` (D-01) |
| `email` tiene formato de correo | **solo dominio** |
| `phone` tiene exactamente 10 dígitos | **solo dominio** |
| `name` no es vacío | **solo dominio** (el motor solo exige que no sea nulo) |
| La contraseña tiene al menos 8 caracteres | **solo dominio** (el motor nunca la ve; ver §9) |
| Una cuenta `business` tiene exactamente un negocio | **solo dominio**: el registro crea ambos en la misma transacción; el motor garantiza *a lo sumo uno* (`business_user_id_key`) |

**Relaciones:** 1 : 0..1 con `Business`; 1 : N con `Appointment` (como clienta); 1 : N con
`RevokedRefreshToken`.

### 2.2 `Business` — raíz de agregado

El salón o la manicurista independiente. Incluye a sus profesionales.

| Invariante | Marca |
|------------|-------|
| Cada cuenta tiene a lo sumo un negocio | **motor** (`business_user_id_key`) |
| La cuenta dueña tiene rol `business` | **solo dominio** (el motor no cruza `user_id` con `role`) |
| `name` y `address` no son vacíos | **solo dominio** |
| Al registrarse, el negocio nace con una profesional (la dueña) | **solo dominio** (misma transacción del registro) |

**Relaciones:** N : 1 con `UserAccount`; 1 : N con `Professional`, `Service` y `Appointment`.

### 2.3 `Professional` — entidad interna del agregado `Business`

Quien atiende. No inicia sesión; se crea y se lista solo a través de su negocio
(`/v1/business/professionals`).

| Invariante | Marca |
|------------|-------|
| Pertenece a un negocio existente | **motor** (`professional_business_id_fkey`) |
| `name` no es vacío y tiene hasta 60 caracteres, sin espacios al borde | **solo dominio** |
| Un negocio tiene como máximo 20 profesionales | **solo dominio**, y además con carrera: dos altas simultáneas pueden dejar 21. Ver D-04 |

**Relaciones:** N : 1 con `Business`; 1 : N con `Service` y `Appointment`.

### 2.4 `Service` — raíz de agregado

Lo que se publica en el catálogo, con su horario.

| Invariante | Marca |
|------------|-------|
| `price_cop` es mayor que cero | **motor** (`service_price_cop_check`) |
| `duration_minutes` es mayor que cero y múltiplo de 15 | **motor** (`service_duration_minutes_check`) |
| `duration_minutes` está entre 15 y 240 | **solo dominio**: el motor acepta 255, 300… **pendiente** (D-02) |
| `type` es uno de los cinco tipos | **motor** (`service_type_check`) |
| `name` tiene hasta 60 caracteres y no es vacío; `description` no es vacía | **solo dominio** |
| La profesional pertenece **al mismo negocio** que el servicio | **solo dominio**: son dos claves foráneas independientes; el motor aceptaría una profesional de otro negocio. **pendiente** (D-03) |
| Tiene al menos una franja de horario | **solo dominio** |
| Sus franjas no se solapan con las de **otro** servicio de la misma profesional | **solo dominio**, y con carrera: dos altas simultáneas pueden solaparse. No se puede expresar con una restricción simple porque cruza dos tablas |
| Pausar no borra: `is_published = false` | **solo dominio** (no hay endpoint de borrado; ver §6) |

**Relaciones:** N : 1 con `Business` y `Professional`; 1 : N con `Schedule` y `Appointment`.

### 2.5 `Schedule` — entidad interna del agregado `Service`

Una franja semanal. No tiene endpoint propio: se crea y se **reemplaza completa** al crear o editar
el servicio.

| Invariante | Marca |
|------------|-------|
| `weekday` está entre 1 (lunes) y 7 (domingo) | **motor** (`schedule_weekday_check`) |
| `end_time` es posterior a `start_time` | **motor** (`schedule_check`) |
| Horas en formato `HH:mm` | **solo dominio** (el motor guarda `time`, acepta segundos) |

**Relaciones:** N : 1 con `Service`.

### 2.6 `Appointment` — raíz de agregado

La reserva de una clienta sobre un cupo.

| Invariante | Marca |
|------------|-------|
| `status` es uno de los seis valores | **motor** (`appointment_status_check`) |
| **Una profesional no tiene dos citas activas (`pending` o `confirmed`) a la misma hora** | **motor** (`uq_appointment_professional_slot_active`, índice único parcial). Es la regla que evita el doble agendamiento; la API la traduce a `409 SlotTaken` |
| La misma clienta con la misma `client_request_id` no crea dos citas | **motor** (`uq_appointment_client_request`) |
| `starts_at` coincide con un cupo del horario del servicio y está en el futuro al crearla | **solo dominio** |
| `client_id` es una cuenta con rol `client` | **solo dominio** |
| `professional_id` y `business_id` son los del servicio | **solo dominio** (se copian del servicio al crear) |
| `service_name`, `price_cop` y `duration_minutes` son una **copia** del servicio al agendar y no cambian después | **solo dominio** (nada los actualiza; editar el servicio no los toca) |
| `price_cop` y `duration_minutes` de la copia son mayores que cero | **solo dominio**: la tabla no repite los `CHECK` de `service`. **pendiente** (D-05) |
| `rejection_reason` tiene valor si y solo si `status` es `rejected` | **solo dominio**. **pendiente** (D-05) |
| Transiciones válidas: `pending → confirmed \| rejected` (negocio), `pending \| confirmed → cancelled` (clienta, solo antes de la hora) | **solo dominio** |
| `completed` y `no_show` | **pendiente**: el motor los acepta, pero **ningún endpoint los asigna todavía** (D-06) |

**Relaciones:** N : 1 con `UserAccount` (clienta), `Service`, `Professional` y `Business`.

### 2.7 `RevokedRefreshToken` — raíz de agregado (técnica)

Un token de refresco que ya no sirve.

| Invariante | Marca |
|------------|-------|
| Un `jti` se revoca una sola vez | **motor** (`revoked_refresh_token_pkey`); la API usa `ON CONFLICT DO NOTHING` para distinguir "lo revoqué ahora" de "ya estaba revocado" |
| Solo se guarda el `jti`, nunca el token | **solo dominio** |

**Relaciones:** N : 1 con `UserAccount`.

---

## 3. Modelo físico

Generado de la salida de §11.1, no de memoria. `schema_migration` es la tabla con la que el
ejecutor de migraciones registra lo aplicado.

**Sobre los tipos:** los textos son `text`, sin longitud en el motor; los límites de longitud son
*solo dominio* y están en §2. `timestamptz` guarda el instante (internamente en UTC). `time` de
`schedule` es **hora de reloj en Colombia**, sin zona, porque una franja "de 9:00 a 12:00" no es un
instante.

| Tabla | Columna | Tipo | Nulo | Por omisión | Qué es |
|-------|---------|------|------|-------------|--------|
| `appointment` | `id` | text | no | — | Identidad, `apt_…` |
| `appointment` | `client_id` | text | no | — | La clienta que agendó |
| `appointment` | `service_id` | text | no | — | El servicio agendado |
| `appointment` | `professional_id` | text | no | — | Quién atiende (copiado del servicio) |
| `appointment` | `business_id` | text | no | — | El negocio (copiado del servicio) |
| `appointment` | `status` | text | no | — | Uno de los seis estados |
| `appointment` | `starts_at` | timestamp with time zone | no | — | Instante de inicio |
| `appointment` | `service_name` | text | no | — | Copia del nombre al agendar |
| `appointment` | `price_cop` | integer | no | — | Copia del precio al agendar, en pesos |
| `appointment` | `duration_minutes` | integer | no | — | Copia de la duración al agendar |
| `appointment` | `rejection_reason` | text | **sí** | — | Motivo del rechazo. Nulo = no fue rechazada |
| `appointment` | `cancel_reason` | text | **sí** | — | Motivo que dio la clienta al cancelar. Nulo = no canceló, o canceló sin decir por qué |
| `appointment` | `client_request_id` | text | no | — | Clave de idempotencia generada por la app |
| `appointment` | `created_at` | timestamp with time zone | no | `now()` | Cuándo se agendó |
| `appointment` | `updated_at` | timestamp with time zone | no | `now()` | Último cambio de estado |
| `business` | `id` | text | no | — | Identidad, `biz_…` |
| `business` | `user_id` | text | no | — | La cuenta dueña |
| `business` | `name` | text | no | — | Nombre del salón |
| `business` | `address` | text | no | — | Dirección visible en el catálogo |
| `business` | `created_at` | timestamp with time zone | no | `now()` | Alta |
| `business` | `updated_at` | timestamp with time zone | no | `now()` | Último cambio (hoy no hay endpoint que lo cambie) |
| `professional` | `id` | text | no | — | Identidad, `prf_…` |
| `professional` | `business_id` | text | no | — | Negocio al que pertenece |
| `professional` | `name` | text | no | — | Nombre visible |
| `professional` | `created_at` | timestamp with time zone | no | `now()` | Alta |
| `professional` | `updated_at` | timestamp with time zone | no | `now()` | Último cambio (hoy no hay endpoint que lo cambie) |
| `revoked_refresh_token` | `jti` | text | no | — | Identificador del token revocado |
| `revoked_refresh_token` | `user_id` | text | no | — | Dueño del token |
| `revoked_refresh_token` | `expires_at` | timestamp with time zone | no | — | Cuándo vence el token; después la fila sobra |
| `revoked_refresh_token` | `revoked_at` | timestamp with time zone | no | `now()` | Cuándo se revocó |
| `schedule` | `id` | text | no | — | Identidad, `sch_…` |
| `schedule` | `service_id` | text | no | — | Servicio al que pertenece |
| `schedule` | `weekday` | smallint | no | — | 1 = lunes … 7 = domingo |
| `schedule` | `start_time` | time without time zone | no | — | Inicio de la franja, hora de Colombia |
| `schedule` | `end_time` | time without time zone | no | — | Fin de la franja, hora de Colombia |
| `schema_migration` | `version` | text | no | — | Nombre del archivo de migración aplicado |
| `schema_migration` | `applied_at` | timestamp with time zone | no | `now()` | Cuándo se aplicó |
| `service` | `id` | text | no | — | Identidad, `svc_…` |
| `service` | `business_id` | text | no | — | Negocio que lo publica |
| `service` | `professional_id` | text | no | — | Quién lo presta |
| `service` | `name` | text | no | — | Nombre visible |
| `service` | `type` | text | no | — | Uno de los cinco tipos |
| `service` | `description` | text | no | — | Qué incluye |
| `service` | `price_cop` | integer | no | — | Precio en pesos colombianos, sin decimales |
| `service` | `duration_minutes` | integer | no | — | Duración, múltiplo de 15 |
| `service` | `image_url` | text | **sí** | — | URL de la imagen. Nulo = el servicio no tiene imagen (hoy ninguno la tiene: no hay endpoint de subida) |
| `service` | `is_published` | boolean | no | `true` | `false` = pausado |
| `service` | `created_at` | timestamp with time zone | no | `now()` | Alta; ordena el catálogo |
| `service` | `updated_at` | timestamp with time zone | no | `now()` | Última edición o pausa |
| `user_account` | `id` | text | no | — | Identidad, `usr_…` |
| `user_account` | `role` | text | no | — | `client` o `business` |
| `user_account` | `name` | text | no | — | Nombre de la persona |
| `user_account` | `phone` | text | no | — | Celular, 10 dígitos |
| `user_account` | `email` | text | no | — | Correo, en minúsculas |
| `user_account` | `password_hash` | text | no | — | Resultado de bcrypt; nunca la contraseña |
| `user_account` | `created_at` | timestamp with time zone | no | `now()` | Alta |
| `user_account` | `updated_at` | timestamp with time zone | no | `now()` | Último cambio (hoy no hay endpoint que lo cambie) |

---

## 4. Restricciones

Con su nombre real en el motor. Todas son **motor** por definición; la columna final dice qué regla
de §2 sostienen.

| Nombre real | Tabla | Tipo | Qué garantiza |
|-------------|-------|------|---------------|
| `user_account_pkey` | `user_account` | primaria | Identidad |
| `user_account_email_key` | `user_account` | única | Un correo, una cuenta (comparación exacta) |
| `user_account_role_check` | `user_account` | comprobación | `role` ∈ {`client`, `business`} |
| `business_pkey` | `business` | primaria | Identidad |
| `business_user_id_key` | `business` | única | A lo sumo un negocio por cuenta |
| `business_user_id_fkey` | `business` | foránea | La cuenta dueña existe |
| `professional_pkey` | `professional` | primaria | Identidad |
| `professional_business_id_fkey` | `professional` | foránea | El negocio existe |
| `service_pkey` | `service` | primaria | Identidad |
| `service_business_id_fkey` | `service` | foránea | El negocio existe |
| `service_professional_id_fkey` | `service` | foránea | La profesional existe (no que sea del mismo negocio) |
| `service_price_cop_check` | `service` | comprobación | `price_cop > 0` |
| `service_duration_minutes_check` | `service` | comprobación | `duration_minutes > 0` y múltiplo de 15 |
| `service_type_check` | `service` | comprobación | `type` es uno de los cinco |
| `schedule_pkey` | `schedule` | primaria | Identidad |
| `schedule_service_id_fkey` | `schedule` | foránea | El servicio existe; se borra con él |
| `schedule_weekday_check` | `schedule` | comprobación | `weekday` entre 1 y 7 |
| `schedule_check` | `schedule` | comprobación | `end_time > start_time` |
| `appointment_pkey` | `appointment` | primaria | Identidad |
| `appointment_client_id_fkey` | `appointment` | foránea | La clienta existe |
| `appointment_service_id_fkey` | `appointment` | foránea | El servicio existe |
| `appointment_professional_id_fkey` | `appointment` | foránea | La profesional existe |
| `appointment_business_id_fkey` | `appointment` | foránea | El negocio existe |
| `appointment_status_check` | `appointment` | comprobación | `status` es uno de los seis |
| `uq_appointment_professional_slot_active` | `appointment` | índice único parcial | Sin doble agendamiento (activas: `pending`, `confirmed`) |
| `uq_appointment_client_request` | `appointment` | índice único | Idempotencia de la creación |
| `revoked_refresh_token_pkey` | `revoked_refresh_token` | primaria | Un `jti` se revoca una vez |
| `revoked_refresh_token_user_id_fkey` | `revoked_refresh_token` | foránea | El dueño existe |
| `schema_migration_pkey` | `schema_migration` | primaria | Una migración se registra una vez |

> Los dos `uq_…` son **índices únicos**, no restricciones: por eso aparecen en §11.3 y no en
> §11.2. Garantizan lo mismo que una restricción única, con la ventaja de admitir la condición
> `WHERE` que hace falta para "solo citas activas".

---

## 5. Claves foráneas y política de borrado

El motor reporta `NO ACTION` en todas salvo una (salida en §11.4). `NO ACTION` se comporta como
**restringir**: borrar el padre falla mientras tenga hijos.

| Relación | Al borrar el padre | Por qué |
|----------|--------------------|---------|
| `business.user_id → user_account` | Restringir | Borrar una cuenta dejaría un salón sin dueña |
| `professional.business_id → business` | Restringir | Las profesionales son del negocio |
| `service.business_id → business` | Restringir | Un servicio sin negocio no tiene dirección ni dueña |
| `service.professional_id → professional` | Restringir | Un servicio sin profesional no se puede agendar |
| `schedule.service_id → service` | **Cascada** | El horario no existe fuera de su servicio (entidad interna, §2.5), y no tiene valor histórico: las citas guardan su propia hora |
| `appointment.client_id → user_account` | Restringir | Las citas son historia de dinero y de agenda del negocio |
| `appointment.service_id → service` | Restringir | Ídem. La cita además guarda copia del nombre y el precio |
| `appointment.professional_id → professional` | Restringir | Ídem |
| `appointment.business_id → business` | Restringir | Ídem |
| `revoked_refresh_token.user_id → user_account` | Restringir | Mientras exista la fila, el token sigue revocado |

**¿Este dato se borra de verdad?** Hoy **ninguna fila se borra desde la API**, con una excepción:
editar un servicio borra y vuelve a crear sus filas de `schedule`. No hay endpoints de borrado de
cuenta, negocio, profesional, servicio ni cita. Lo que la interfaz llama "quitar" un servicio es
pausarlo (§6).

---

## 6. Baja lógica

**Solo `service` tiene baja lógica.** Las demás entidades no se pueden dar de baja en esta versión.

| Pregunta | Respuesta |
|----------|-----------|
| ¿Qué columna lo marca? | `service.is_published`, `false` = pausado |
| ¿Qué consultas lo filtran? | El catálogo público (`GET /v1/services`), el detalle público (responde **410**), la disponibilidad (410) y crear cita (410) |
| ¿Qué consultas **no** lo filtran? | La lista del negocio (`GET /v1/business/services`), editar, pausar/publicar, y **toda consulta de citas**: Mis citas y la agenda siguen mostrando la cita, con la copia del nombre y el precio que guarda la propia cita |
| ¿Se puede reactivar? | Sí: `PATCH /v1/business/services/{id}/status` con `isPublished: true` |
| ¿La unicidad cuenta a los dados de baja? | No aplica: `service` no tiene restricciones de unicidad aparte de su `id` |
| ¿Qué ve la app? | La clienta: desaparece del catálogo y un enlace viejo muestra "ya no está disponible". El negocio: lo sigue viendo con el distintivo "Pausado" |

**Consecuencia para la sincronización incremental:** como no hay borrado físico, un servicio
pausado se puede comunicar como un cambio de `is_published`. Hoy la app no sincroniza de forma
incremental (usa caché con vencimiento; ver [`offline-sync.md`](./offline-sync.md)).

---

## 7. Patrones de acceso e índices

### 7.1 Las consultas reales

| # | Consulta | Frecuencia | Índice que la sirve |
|---|----------|------------|---------------------|
| Q1 | Catálogo: servicios publicados, opcionalmente por `type`, ordenados por `created_at DESC, id DESC` | Alta — pantalla de inicio | `idx_service_type` solo con filtro; sin filtro, ninguno (ver 7.3) |
| Q2 | Servicio por `id` (detalle, disponibilidad, crear cita, editar, pausar) | Alta | `service_pkey` |
| Q3 | Franjas de un servicio en un día de la semana | Alta — disponibilidad | `idx_schedule_service` |
| Q4 | Citas activas de una profesional en un rango de un día | Alta — disponibilidad | `uq_appointment_professional_slot_active` (sus columnas son justo `professional_id, starts_at` y su condición es justo "activas") |
| Q5 | Cita por `client_id` + `client_request_id` (idempotencia) | Alta — cada agendamiento | `uq_appointment_client_request` |
| Q6 | Mis citas: por `client_id`, ordenadas por `starts_at DESC, id DESC` | Media | `idx_appointment_client` (filtra; el orden se resuelve aparte) |
| Q7 | Agenda: por `business_id` en un rango de `starts_at` | Media | `idx_appointment_business` (filtra; el rango se resuelve aparte) |
| Q8 | Cuenta por `email` (login, registro) | Media | `user_account_email_key` |
| Q9 | Negocio por `user_id` | **Alta — en cada petición del lado del negocio** | `business_user_id_key` |
| Q10 | Profesionales de un negocio, por `name, id` | Baja | `idx_professional_business` |
| Q11 | Servicios de un negocio (lista propia) | Media | `idx_service_business` |
| Q12 | Franjas de los otros servicios de una profesional (chequeo de solape) | Baja — al crear o editar | `idx_service_professional` + `idx_schedule_service` |
| Q13 | Revocar un `jti` | Media — cada refresco y logout | `revoked_refresh_token_pkey` |

### 7.2 Índices que existen

Los 21 de §11.3: una primaria por tabla (7 + `schema_migration`), `user_account_email_key`,
`business_user_id_key`, los dos `uq_appointment_…`, y los índices de apoyo
`idx_professional_business`, `idx_service_business`, `idx_service_professional`, `idx_service_type`,
`idx_schedule_service`, `idx_appointment_client`, `idx_appointment_business`,
`idx_appointment_starts_at` e `idx_appointment_status`.

### 7.3 Índices que faltan — pendiente

| Índice | Para | Tarea |
|--------|------|-------|
| Parcial sobre `service (created_at DESC, id DESC) WHERE is_published` | Q1 sin filtro | D-07 |
| `appointment (client_id, starts_at DESC, id DESC)` en lugar de `idx_appointment_client` | Q6 con su orden | D-07 |
| `appointment (business_id, starts_at)` en lugar de `idx_appointment_business` | Q7 con su rango | D-07 |
| Único sobre `user_account (lower(email))` | La regla de §2.1 | D-01 |

Con los volúmenes actuales (datos de prueba) ninguna de estas consultas es lenta; se declaran para
que no se olviden cuando haya datos reales.

### 7.4 Índices a retirar y por qué

| Índice | Por qué sobra |
|--------|---------------|
| `idx_appointment_status` | Ninguna consulta de 7.1 filtra solo por estado. Donde el estado importa (Q4), lo resuelve el índice parcial |
| `idx_appointment_starts_at` | Ninguna consulta filtra solo por fecha: Q6 y Q7 siempre llevan clienta o negocio delante |

Siguen existiendo porque la migración `0001` ya está aplicada y **no se edita**. Se retiran en una
migración nueva (D-07). Cada índice se paga en cada escritura de cita.

---

## 8. Auditoría y marcas de tiempo

| Tabla | `created_at` | `updated_at` |
|-------|--------------|--------------|
| `user_account`, `business`, `professional` | Sí | Sí, pero hoy nada las modifica |
| `service` | Sí | Sí: editar y pausar/publicar |
| `appointment` | Sí | Sí: confirmar, rechazar, cancelar |
| `schedule` | No | No: sus filas no se actualizan, se reemplazan al editar el servicio |
| `revoked_refresh_token` | `revoked_at` | No: una fila no cambia nunca |
| `schema_migration` | `applied_at` | No |

- **Quién las escribe:** al insertar, el **motor** (`DEFAULT now()`). Al actualizar, **solo
  dominio**: cada `UPDATE` de la API pone `updated_at = now()` a mano. Una actualización manual la
  deja mintiendo. **pendiente** un disparador que la mantenga (D-08).
- **Zona horaria:** `timestamptz` guarda el instante; el motor lo maneja en UTC. La API lo devuelve
  siempre con desplazamiento explícito de Colombia (`2026-09-27T09:00:00-05:00`). Colombia no tiene
  horario de verano, así que el desplazamiento es siempre `-05:00`. La hora local es asunto de la
  pantalla.
- **Excepción deliberada:** `schedule.start_time` y `end_time` son `time` **sin zona**, porque son
  hora de reloj en Colombia ("abre a las 9:00"), no un instante.

---

## 9. Datos personales y retención

| Campo | Para qué se usa | Cuánto se conserva | Qué pasa si la persona pide borrarlo |
|-------|-----------------|--------------------|--------------------------------------|
| `user_account.name` | Saludo; el negocio lo ve en su agenda | Mientras exista la cuenta | **pendiente**: no hay proceso (D-09) |
| `user_account.email` | Iniciar sesión | Mientras exista la cuenta | **pendiente** (D-09) |
| `user_account.phone` | El negocio lo ve en su agenda para contactar a la clienta | Mientras exista la cuenta | **pendiente** (D-09) |
| `user_account.password_hash` | Verificar la contraseña | Mientras exista la cuenta | **pendiente** (D-09) |
| `business.address` | Se muestra en el catálogo. **Puede ser la casa** de una manicurista independiente | Mientras exista el negocio | **pendiente** (D-09) |
| `business.name`, `professional.name` | Se muestran en el catálogo | Mientras existan | **pendiente** (D-09) |
| `appointment` (clienta + servicio + hora) | La agenda del negocio y Mis citas. Revela hábitos de la persona | Indefinido: es historia de dinero y de agenda | **pendiente**: decidir si se anonimiza la clienta y se conserva la cita (D-09) |
| `revoked_refresh_token.user_id` | Mantener revocado el token | Hasta `expires_at`; hoy nadie borra las filas vencidas | Se puede borrar sin consecuencia pasado `expires_at` (D-10) |

Reglas que se revisan:

- **Las contraseñas no se guardan.** Se guarda el resultado de **bcrypt** (función de derivación
  con sal incluida, costo 10). No es cifrado: no hay forma de recuperar la contraseña.
- **No se recogen** ubicación, identificador del dispositivo, token de notificaciones, foto ni
  documento de identidad. Si alguna feature los necesita, se declaran aquí antes de guardarlos.
- La agenda del negocio (nombre y celular de clientas) **no se guarda en el dispositivo**; ver
  [`persistence.md`](./persistence.md).

---

## 10. Semilla

| Dato | Por qué medio entra |
|------|---------------------|
| Catálogos fijos: roles, estados de cita, tipos de servicio | **En la migración `0001`**, como restricciones `CHECK`, no como tablas. Son parte del esquema: cambiar uno es una migración nueva |
| Usuario administrador | **No existe.** No hay rol de administrador ni endpoint que lo necesite. Si llega a hacer falta, se crea al arrancar el servicio leyendo una variable de entorno, nunca en una migración |
| Datos de demostración | **Por la API, nunca por SQL.** Hoy no hay un sembrador dedicado: los datos de prueba los crea [`scripts/smoke-test.ps1`](https://github.com/code-corhuila/beauty-salon-api/blob/main/scripts/smoke-test.ps1) llamando a los endpoints, así que obedecen las mismas reglas que lo que teclea una persona |

Una base recién creada tiene el esquema y **ninguna fila**, salvo la de `schema_migration` que
registra la `0001`.

---

## 11. Cómo se comprueba que este documento no miente

**Si el documento contradice al motor, gana el motor**, y se corrige el documento.

Consultas ejecutadas el **2026-09-27** contra la base de `beauty-salon-infra`, con:

```
docker compose exec -T db psql -U manicita -d manicita
```

### 11.1 Columnas — debe devolver 57 filas

```sql
SELECT table_name, ordinal_position, column_name,
       data_type, is_nullable, coalesce(column_default, '(ninguno)')
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;
```

```
      table_name       | ordinal_position |    column_name    |        data_type         | is_nullable | coalesce
-----------------------+------------------+-------------------+--------------------------+-------------+-----------
 appointment           |                1 | id                | text                     | NO          | (ninguno)
 appointment           |                2 | client_id         | text                     | NO          | (ninguno)
 appointment           |                3 | service_id        | text                     | NO          | (ninguno)
 appointment           |                4 | professional_id   | text                     | NO          | (ninguno)
 appointment           |                5 | business_id       | text                     | NO          | (ninguno)
 appointment           |                6 | status            | text                     | NO          | (ninguno)
 appointment           |                7 | starts_at         | timestamp with time zone | NO          | (ninguno)
 appointment           |                8 | service_name      | text                     | NO          | (ninguno)
 appointment           |                9 | price_cop         | integer                  | NO          | (ninguno)
 appointment           |               10 | duration_minutes  | integer                  | NO          | (ninguno)
 appointment           |               11 | rejection_reason  | text                     | YES         | (ninguno)
 appointment           |               12 | cancel_reason     | text                     | YES         | (ninguno)
 appointment           |               13 | client_request_id | text                     | NO          | (ninguno)
 appointment           |               14 | created_at        | timestamp with time zone | NO          | now()
 appointment           |               15 | updated_at        | timestamp with time zone | NO          | now()
 business              |                1 | id                | text                     | NO          | (ninguno)
 business              |                2 | user_id           | text                     | NO          | (ninguno)
 business              |                3 | name              | text                     | NO          | (ninguno)
 business              |                4 | address           | text                     | NO          | (ninguno)
 business              |                5 | created_at        | timestamp with time zone | NO          | now()
 business              |                6 | updated_at        | timestamp with time zone | NO          | now()
 professional          |                1 | id                | text                     | NO          | (ninguno)
 professional          |                2 | business_id       | text                     | NO          | (ninguno)
 professional          |                3 | name              | text                     | NO          | (ninguno)
 professional          |                4 | created_at        | timestamp with time zone | NO          | now()
 professional          |                5 | updated_at        | timestamp with time zone | NO          | now()
 revoked_refresh_token |                1 | jti               | text                     | NO          | (ninguno)
 revoked_refresh_token |                2 | user_id           | text                     | NO          | (ninguno)
 revoked_refresh_token |                3 | expires_at        | timestamp with time zone | NO          | (ninguno)
 revoked_refresh_token |                4 | revoked_at        | timestamp with time zone | NO          | now()
 schedule              |                1 | id                | text                     | NO          | (ninguno)
 schedule              |                2 | service_id        | text                     | NO          | (ninguno)
 schedule              |                3 | weekday           | smallint                 | NO          | (ninguno)
 schedule              |                4 | start_time        | time without time zone   | NO          | (ninguno)
 schedule              |                5 | end_time          | time without time zone   | NO          | (ninguno)
 schema_migration      |                1 | version           | text                     | NO          | (ninguno)
 schema_migration      |                2 | applied_at        | timestamp with time zone | NO          | now()
 service               |                1 | id                | text                     | NO          | (ninguno)
 service               |                2 | business_id       | text                     | NO          | (ninguno)
 service               |                3 | professional_id   | text                     | NO          | (ninguno)
 service               |                4 | name              | text                     | NO          | (ninguno)
 service               |                5 | type              | text                     | NO          | (ninguno)
 service               |                6 | description       | text                     | NO          | (ninguno)
 service               |                7 | price_cop         | integer                  | NO          | (ninguno)
 service               |                8 | duration_minutes  | integer                  | NO          | (ninguno)
 service               |                9 | image_url         | text                     | YES         | (ninguno)
 service               |               10 | is_published      | boolean                  | NO          | true
 service               |               11 | created_at        | timestamp with time zone | NO          | now()
 service               |               12 | updated_at        | timestamp with time zone | NO          | now()
 user_account          |                1 | id                | text                     | NO          | (ninguno)
 user_account          |                2 | role              | text                     | NO          | (ninguno)
 user_account          |                3 | name              | text                     | NO          | (ninguno)
 user_account          |                4 | phone             | text                     | NO          | (ninguno)
 user_account          |                5 | email             | text                     | NO          | (ninguno)
 user_account          |                6 | password_hash     | text                     | NO          | (ninguno)
 user_account          |                7 | created_at        | timestamp with time zone | NO          | now()
 user_account          |                8 | updated_at        | timestamp with time zone | NO          | now()
(57 rows)
```

### 11.2 Restricciones — debe devolver 27 filas

`contype`: `p` primaria, `f` foránea, `u` única, `c` comprobación.

```sql
SELECT conrelid::regclass AS tabla, conname, contype
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY 1, 3, 2;
```

```
         tabla         |              conname               | contype
-----------------------+------------------------------------+---------
 schema_migration      | schema_migration_pkey              | p
 user_account          | user_account_role_check            | c
 user_account          | user_account_pkey                  | p
 user_account          | user_account_email_key             | u
 business              | business_user_id_fkey              | f
 business              | business_pkey                      | p
 business              | business_user_id_key               | u
 professional          | professional_business_id_fkey      | f
 professional          | professional_pkey                  | p
 service               | service_duration_minutes_check     | c
 service               | service_price_cop_check            | c
 service               | service_type_check                 | c
 service               | service_business_id_fkey           | f
 service               | service_professional_id_fkey       | f
 service               | service_pkey                       | p
 schedule              | schedule_check                     | c
 schedule              | schedule_weekday_check             | c
 schedule              | schedule_service_id_fkey           | f
 schedule              | schedule_pkey                      | p
 appointment           | appointment_status_check           | c
 appointment           | appointment_business_id_fkey       | f
 appointment           | appointment_client_id_fkey         | f
 appointment           | appointment_professional_id_fkey   | f
 appointment           | appointment_service_id_fkey        | f
 appointment           | appointment_pkey                   | p
 revoked_refresh_token | revoked_refresh_token_user_id_fkey | f
 revoked_refresh_token | revoked_refresh_token_pkey         | p
(27 rows)
```

### 11.3 Índices — debe devolver 21 filas

```sql
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

```
       tablename       |                indexname                |                                     indexdef
-----------------------+-----------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 appointment           | appointment_pkey                        | CREATE UNIQUE INDEX appointment_pkey ON public.appointment USING btree (id)
 appointment           | idx_appointment_business                | CREATE INDEX idx_appointment_business ON public.appointment USING btree (business_id)
 appointment           | idx_appointment_client                  | CREATE INDEX idx_appointment_client ON public.appointment USING btree (client_id)
 appointment           | idx_appointment_starts_at               | CREATE INDEX idx_appointment_starts_at ON public.appointment USING btree (starts_at)
 appointment           | idx_appointment_status                  | CREATE INDEX idx_appointment_status ON public.appointment USING btree (status)
 appointment           | uq_appointment_client_request           | CREATE UNIQUE INDEX uq_appointment_client_request ON public.appointment USING btree (client_id, client_request_id)
 appointment           | uq_appointment_professional_slot_active | CREATE UNIQUE INDEX uq_appointment_professional_slot_active ON public.appointment USING btree (professional_id, starts_at) WHERE (status = ANY (ARRAY['pending'::text, 'confirmed'::text]))
 business              | business_pkey                           | CREATE UNIQUE INDEX business_pkey ON public.business USING btree (id)
 business              | business_user_id_key                    | CREATE UNIQUE INDEX business_user_id_key ON public.business USING btree (user_id)
 professional          | idx_professional_business               | CREATE INDEX idx_professional_business ON public.professional USING btree (business_id)
 professional          | professional_pkey                       | CREATE UNIQUE INDEX professional_pkey ON public.professional USING btree (id)
 revoked_refresh_token | revoked_refresh_token_pkey              | CREATE UNIQUE INDEX revoked_refresh_token_pkey ON public.revoked_refresh_token USING btree (jti)
 schedule              | idx_schedule_service                    | CREATE INDEX idx_schedule_service ON public.schedule USING btree (service_id)
 schedule              | schedule_pkey                           | CREATE UNIQUE INDEX schedule_pkey ON public.schedule USING btree (id)
 schema_migration      | schema_migration_pkey                   | CREATE UNIQUE INDEX schema_migration_pkey ON public.schema_migration USING btree (version)
 service               | idx_service_business                    | CREATE INDEX idx_service_business ON public.service USING btree (business_id)
 service               | idx_service_professional                | CREATE INDEX idx_service_professional ON public.service USING btree (professional_id)
 service               | idx_service_type                        | CREATE INDEX idx_service_type ON public.service USING btree (type)
 service               | service_pkey                            | CREATE UNIQUE INDEX service_pkey ON public.service USING btree (id)
 user_account          | user_account_email_key                  | CREATE UNIQUE INDEX user_account_email_key ON public.user_account USING btree (email)
 user_account          | user_account_pkey                       | CREATE UNIQUE INDEX user_account_pkey ON public.user_account USING btree (id)
(21 rows)
```

### 11.4 Definiciones y política de borrado — debe devolver 19 filas

Complementa a 11.2 con la definición de cada foránea, única y comprobación. `confdeltype`:
`a` = NO ACTION, `c` = CASCADE. Es la fuente de §4 y §5.

```sql
SELECT conrelid::regclass AS tabla, conname, contype, confdeltype,
       pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace AND contype IN ('f', 'c', 'u')
ORDER BY 1, 2;
```

```
         tabla         |              conname               | contype | confdeltype |                                   definicion
-----------------------+------------------------------------+---------+-------------+------------------------------------------------------------------------------------------------------------------------------------------
 user_account          | user_account_email_key             | u       |             | UNIQUE (email)
 user_account          | user_account_role_check            | c       |             | CHECK ((role = ANY (ARRAY['client'::text, 'business'::text])))
 business              | business_user_id_fkey              | f       | a           | FOREIGN KEY (user_id) REFERENCES user_account(id)
 business              | business_user_id_key               | u       |             | UNIQUE (user_id)
 professional          | professional_business_id_fkey      | f       | a           | FOREIGN KEY (business_id) REFERENCES business(id)
 service               | service_business_id_fkey           | f       | a           | FOREIGN KEY (business_id) REFERENCES business(id)
 service               | service_duration_minutes_check     | c       |             | CHECK (((duration_minutes > 0) AND ((duration_minutes % 15) = 0)))
 service               | service_price_cop_check            | c       |             | CHECK ((price_cop > 0))
 service               | service_professional_id_fkey       | f       | a           | FOREIGN KEY (professional_id) REFERENCES professional(id)
 service               | service_type_check                 | c       |             | CHECK ((type = ANY (ARRAY['traditional'::text, 'semi_permanent'::text, 'acrylic'::text, 'removal'::text, 'nail_art'::text])))
 schedule              | schedule_check                     | c       |             | CHECK ((end_time > start_time))
 schedule              | schedule_service_id_fkey           | f       | c           | FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE
 schedule              | schedule_weekday_check             | c       |             | CHECK (((weekday >= 1) AND (weekday <= 7)))
 appointment           | appointment_business_id_fkey       | f       | a           | FOREIGN KEY (business_id) REFERENCES business(id)
 appointment           | appointment_client_id_fkey         | f       | a           | FOREIGN KEY (client_id) REFERENCES user_account(id)
 appointment           | appointment_professional_id_fkey   | f       | a           | FOREIGN KEY (professional_id) REFERENCES professional(id)
 appointment           | appointment_service_id_fkey        | f       | a           | FOREIGN KEY (service_id) REFERENCES service(id)
 appointment           | appointment_status_check           | c       |             | CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'rejected'::text, 'cancelled'::text, 'completed'::text, 'no_show'::text])))
 revoked_refresh_token | revoked_refresh_token_user_id_fkey | f       | a           | FOREIGN KEY (user_id) REFERENCES user_account(id)
(19 rows)
```

---

## 12. Firma

| | |
|---|---|
| **Escrito por** | Lilly Signey Puentes Rincon y Lizeth Caicedo |
| **Verificado contra** | PostgreSQL 16.13 levantado con `beauty-salon-infra`; `beauty-salon-api` en el commit `1dfbeef`, migración `0001_initial_schema` |
| **Fecha de verificación** | 2026-09-27 |

Este documento no se corrige en silencio: cada cambio de esquema es una migración nueva, se vuelven
a ejecutar las consultas de §11, se actualiza la fecha de arriba y lo que quede sin cumplir se
declara en §13.

---

## 13. Deuda declarada

| # | Qué prometió el documento | Qué hace hoy el sistema | Dueño | Tarea que lo cierra |
|---|---------------------------|-------------------------|-------|---------------------|
| D-01 | Correo único sin distinguir mayúsculas | Solo el código lo normaliza; el motor compara exacto | _por asignar_ | Migración: índice único sobre `lower(email)` |
| D-02 | Duración entre 15 y 240 minutos | El motor acepta cualquier múltiplo de 15 | _por asignar_ | Migración: ampliar `service_duration_minutes_check` |
| D-03 | La profesional de un servicio es del mismo negocio | Dos foráneas independientes; el motor no lo cruza | _por asignar_ | Migración: única `(id, business_id)` en `professional` y foránea compuesta desde `service` |
| D-04 | Máximo 20 profesionales por negocio | Solo el código, con carrera entre dos altas simultáneas | _por asignar_ | Bloquear la fila del negocio (`SELECT … FOR UPDATE`) al crear profesional |
| D-05 | Copias de precio y duración positivas; `rejection_reason` solo en rechazadas | Solo el código | _por asignar_ | Migración: `CHECK` en `appointment` |
| D-06 | Estados `completed` y `no_show` | El motor los acepta, ningún endpoint los asigna | _por asignar_ | Decidir quién los marca (el negocio, o un proceso al pasar la hora) y agregar el endpoint |
| D-07 | Índices alineados con las consultas de §7.1 | Faltan tres, sobran dos | _por asignar_ | Migración de índices (§7.3 y §7.4) |
| D-08 | `updated_at` siempre cierto | Solo el código lo actualiza | _por asignar_ | Migración: disparador `BEFORE UPDATE` |
| D-09 | Qué pasa si una persona pide borrar sus datos | No hay proceso ni endpoint | _por asignar_ | Decidir la política (borrar o anonimizar) y el endpoint |
| D-10 | Filas de `revoked_refresh_token` vencidas se descartan | Se acumulan | _por asignar_ | Limpieza periódica (`DELETE … WHERE expires_at < now()`) |
