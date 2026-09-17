# 03 — API & Data

> **¿Qué es esto?** Las reglas de cómo la app habla con el backend y cómo guarda datos en el
> dispositivo.

## Por qué existe esta sección

En red y persistencia viven la mayoría de los errores y de los problemas de seguridad de una app
móvil: manejo de tokens, reintentos, comportamiento sin conexión y migraciones de esquema. Las reglas
se deciden una vez aquí y se aplican en la capa de datos de todas las features.

> **El backend de ManiCita no existe todavía.** El contrato completo está diseñado en
> [`endpoints/`](./endpoints/) y se sirve con un mock local durante el desarrollo. La
> [Definition of Ready](../00-governance/definition-of-ready.md) admite explícitamente el contrato
> *stubbed*.

---

## Documentos de esta sección

| Archivo | Para qué sirve |
|---------|----------------|
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
| `POST /v1/auth/registro` | [auth-registro.md](./endpoints/auth-registro.md) | auth | No |
| `GET /v1/servicios` | [catalogo-listar-servicios.md](./endpoints/catalogo-listar-servicios.md) | catalog | No |
| `GET /v1/servicios/{id}` | [catalogo-detalle-servicio.md](./endpoints/catalogo-detalle-servicio.md) | catalog | No |
| `GET /v1/servicios/{id}/disponibilidad` | [agendamiento-disponibilidad.md](./endpoints/agendamiento-disponibilidad.md) | booking | No |
| `POST /v1/citas` | [agendamiento-crear-cita.md](./endpoints/agendamiento-crear-cita.md) | booking | Sí, clienta |
| `GET /v1/citas/mias` | [citas-listar-mis-citas.md](./endpoints/citas-listar-mis-citas.md) | appointments | Sí, clienta |
| `PATCH /v1/citas/{id}/cancelar` | [citas-cancelar-cita.md](./endpoints/citas-cancelar-cita.md) | appointments | Sí, clienta |
| `POST /v1/negocio/servicios` | [negocio-crear-servicio.md](./endpoints/negocio-crear-servicio.md) | business | Sí, negocio |
| `PATCH /v1/negocio/servicios/{id}/estado` | [negocio-pausar-servicio.md](./endpoints/negocio-pausar-servicio.md) | business | Sí, negocio |
| `GET /v1/negocio/agenda` | [negocio-agenda.md](./endpoints/negocio-agenda.md) | business | Sí, negocio |
| `PATCH /v1/negocio/citas/{id}/responder` | [negocio-responder-cita.md](./endpoints/negocio-responder-cita.md) | business | Sí, negocio |

## Entidades locales documentadas

| Tabla | Documento | Versión de esquema | Qué guarda |
|-------|-----------|--------------------|------------|
| `servicios` | [servicios.md](./entities/servicios.md) | 1 | Catálogo cacheado |
| `negocios` | [negocios.md](./entities/negocios.md) | 1 | Nombre y dirección del salón |
| `profesionales` | [profesionales.md](./entities/profesionales.md) | 1 | Quién atiende cada servicio |
| `citas` | [citas.md](./entities/citas.md) | 2 | Solo las citas de la clienta autenticada |

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
