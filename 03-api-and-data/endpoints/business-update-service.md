# Endpoint — Editar un servicio

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `PUT /v1/business/services/{serviceId}`
- **Requiere sesión:** Sí, con rol `business`
- **Idempotente:** Sí. Es un **reemplazo completo**: enviarlo dos veces deja el mismo estado

> Agregado el 2026-09-25. La pantalla [Mis servicios](../../01-architecture/screens/negocio-servicios.md)
> promete editar los servicios existentes, y solo existían crear y pausar.

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `serviceId` | path | string | Sí | Debe pertenecer al negocio autenticado |

El cuerpo es **exactamente el de [crear servicio](./business-create-service.md)**, con las mismas
reglas: `name`, `type`, `description`, `priceCop`, `durationMinutes`, `professionalId` y
`schedule`, todos obligatorios. Lo que no se envía no se conserva: no es un `PATCH`.

`isPublished` **no** se edita aquí; para eso está
[pausar o publicar](./business-update-service-status.md). Si llega, se ignora.

---

## Response

**Éxito (200):** el detalle del servicio actualizado, con la misma forma que devuelve crear
servicio.

**Qué pasa con lo que ya existía:**

| Efecto | Comportamiento |
|--------|----------------|
| Horario | Se **reemplaza** completo por el `schedule` enviado |
| Citas ya agendadas | **No cambian.** Guardan su propia copia de nombre, precio y duración del día en que se agendaron, y su hora se respeta aunque quede fuera del horario nuevo |
| Cupos nuevos | Se calculan con el horario y la duración nuevos |
| Estado publicado o pausado | No cambia |

---

## Errores

**Orden de comprobación:** sesión → rol → validación de campos → el servicio existe → es del
negocio → la profesional es del negocio → solape de horario con **otro** servicio de la misma
profesional (el propio servicio no cuenta).

| Código | Cuándo | `code` | Qué hace la app |
|--------|--------|--------|-----------------|
| 401 | Sin token o vencido | `AUTH_REQUIRED` / `SESSION_EXPIRED` | Refresco transparente y un reintento |
| 403 | Sesión de clienta, o servicio de otro negocio | `FORBIDDEN_ROLE` / `FORBIDDEN_RESOURCE` | `Unauthorized` |
| 404 | El servicio no existe | `SERVICE_NOT_FOUND` | Vuelve a la lista y la recarga |
| 409 | El horario se solapa con otro servicio de la misma profesional | `SCHEDULE_OVERLAP` | Mensaje bajo el horario |
| 422 | Validación de campos | `VALIDATION_FAILED`, mismos mensajes por campo que crear servicio | Marca los campos y conserva lo escrito |
| 422 | La profesional no es del negocio | `VALIDATION_FAILED`, `errors.professionalId`: "No pertenece a este negocio" | Recarga la lista de profesionales |
| 5xx o timeout | Transitorio | — | Se puede reintentar (es idempotente), una vez |

---

## Concurrencia

**Gana el último.** Si dos dispositivos del mismo negocio editan el mismo servicio, el segundo
reemplaza al primero sin aviso. Se acepta así porque un negocio es una sola persona y el caso es
raro; queda declarado como hueco del contrato.

---

## Caché y offline

- **Estrategia:** online-only.
- **Invalidación:** la lista de [servicios del negocio](./business-list-services.md) y el caché
  del catálogo de la clienta.
