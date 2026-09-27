# 03 — API & Data

> **¿Qué es esto?** Las reglas de cómo la app habla con el backend y cómo guarda datos en el
> dispositivo.

## Por qué existe esta sección

En red y persistencia viven la mayoría de los errores y de los problemas de seguridad de una app
móvil: manejo de tokens, reintentos, comportamiento sin conexión y migraciones de esquema. Las reglas
se deciden una vez aquí y se aplican en la capa de datos de todas las features.

> **El backend de ManiCita ya está implementado** en Node.js + Express + PostgreSQL, en el repo
> `beauty-salon-api` ([ADR-009](../01-architecture/decisions/records/ADR-009-backend-repo-and-stack.md),
> [ADR-011](../01-architecture/decisions/records/ADR-011-cuatro-repositorios.md)),
> siguiendo exactamente el contrato diseñado en [`endpoints/`](./endpoints/). Mientras el frontend no
> esté conectado a una instancia real, se puede seguir sirviendo el contrato con un mock local: la
> [Definition of Ready](../00-governance/definition-of-ready.md) admite el contrato *stubbed* para
> ese propósito.

---

## Documentos de esta sección

| Archivo | Para qué sirve |
|---------|----------------|
| [api-contract.md](./api-contract.md) | **Contrato de API:** convenciones, forma única del error (`problem+json`), códigos de estado, las 18 fichas E-01..E-18, idempotencia, concurrencia, versionado, sondas y huecos. Manda sobre la API y sobre el cliente HTTP de la app |
| [data-model.md](./data-model.md) | Modelo de datos del servidor: entidades, invariantes con su marca (motor / solo dominio / pendiente), tablas, restricciones, índices y deuda. Verificado contra la base |
| [api-networking.md](./api-networking.md) | Cliente HTTP, timeouts, reintentos, mapeo de errores |
| [authentication.md](./authentication.md) | Tokens, refresco, roles, cierre de sesión |
| [persistence.md](./persistence.md) | Reglas y nombres de la base local, migraciones |
| [offline-sync.md](./offline-sync.md) | Estrategia offline por feature |
| [endpoints/](./endpoints/) | Un documento por endpoint |
| [entities/](./entities/) | Un documento por entidad local |
| [_template-endpoint-integration.md](./_template-endpoint-integration.md) | Plantilla de endpoint |
| [_template-entity.md](./_template-entity.md) | Plantilla de entidad |

---

## Endpoints documentados

| Endpoint | Documento | Feature | Sesión |
|----------|-----------|---------|--------|
| `POST /v1/auth/login` | [auth-login.md](./endpoints/auth-login.md) | auth | No |
| `POST /v1/auth/register` | [auth-register.md](./endpoints/auth-register.md) | auth | No |
| `POST /v1/auth/refresh` | [auth-refresh.md](./endpoints/auth-refresh.md) | auth | No (requiere `refreshToken`) |
| `POST /v1/auth/logout` | [auth-logout.md](./endpoints/auth-logout.md) | auth | No (requiere `refreshToken`) |
| `GET /v1/services` | [catalog-list-services.md](./endpoints/catalog-list-services.md) | catalog | No |
| `GET /v1/services/{id}` | [catalog-service-detail.md](./endpoints/catalog-service-detail.md) | catalog | No |
| `GET /v1/services/{id}/availability` | [booking-availability.md](./endpoints/booking-availability.md) | booking | No |
| `POST /v1/appointments` | [booking-create-appointment.md](./endpoints/booking-create-appointment.md) | booking | Sí, clienta |
| `GET /v1/appointments/mine` | [appointments-list-mine.md](./endpoints/appointments-list-mine.md) | appointments | Sí, clienta |
| `PATCH /v1/appointments/{id}/cancel` | [appointments-cancel.md](./endpoints/appointments-cancel.md) | appointments | Sí, clienta |
| `GET /v1/business/professionals` | [business-list-professionals.md](./endpoints/business-list-professionals.md) | business | Sí, negocio |
| `POST /v1/business/professionals` | [business-create-professional.md](./endpoints/business-create-professional.md) | business | Sí, negocio |
| `GET /v1/business/services` | [business-list-services.md](./endpoints/business-list-services.md) | business | Sí, negocio |
| `POST /v1/business/services` | [business-create-service.md](./endpoints/business-create-service.md) | business | Sí, negocio |
| `PUT /v1/business/services/{id}` | [business-update-service.md](./endpoints/business-update-service.md) | business | Sí, negocio |
| `PATCH /v1/business/services/{id}/status` | [business-update-service-status.md](./endpoints/business-update-service-status.md) | business | Sí, negocio |
| `GET /v1/business/agenda` | [business-agenda.md](./endpoints/business-agenda.md) | business | Sí, negocio |
| `PATCH /v1/business/appointments/{id}/respond` | [business-respond-appointment.md](./endpoints/business-respond-appointment.md) | business | Sí, negocio |

## Entidades locales documentadas

| Tabla | Documento | Versión de esquema | Qué guarda |
|-------|-----------|--------------------|------------|
| `service` | [service.md](./entities/service.md) | 2 | Catálogo cacheado |
| `business` | [business.md](./entities/business.md) | 2 | Nombre y dirección del salón |
| `professional` | [professional.md](./entities/professional.md) | 2 | Quién atiende cada servicio |
| `appointment` | [appointment.md](./entities/appointment.md) | 3 | Solo las citas de la clienta autenticada |

> Son cuatro y no más a propósito. Cupos, horarios y agenda del negocio **no se guardan**, y el
> porqué de cada exclusión está en [`persistence.md`](./persistence.md).

---

## Coherencia con las otras secciones

- Cada endpoint aparece en el documento de la feature que lo consume, en
  [`01-architecture/features/`](../01-architecture/features/).
- Cada entidad local guarda exactamente campos que algún endpoint documentado devuelve.
- Los errores de dominio (`SlotTaken`, `Unauthorized`, `ValidationFailed`) son los definidos en
  [`02-code-and-ui/coding-standards.md`](../02-code-and-ui/coding-standards.md).
- Las reglas de tokens y de datos sensibles vienen de
  [`00-governance/security-rules.md`](../00-governance/security-rules.md).

---

## Preguntas que esta sección debe responder

- ¿Cómo se hacen y se reintentan las peticiones? → [api-networking.md](./api-networking.md)
- ¿Dónde se guardan los tokens y cómo se refrescan? → [authentication.md](./authentication.md)
- ¿Qué se guarda localmente y cómo migran los esquemas? → [persistence.md](./persistence.md)
- ¿Qué pasa sin conexión? → [offline-sync.md](./offline-sync.md)
