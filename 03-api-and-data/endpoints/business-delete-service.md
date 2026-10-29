# Endpoint — Eliminar un servicio

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `DELETE /v1/business/services/{serviceId}`
- **Requiere sesión:** Sí, con rol `business`, dueño del servicio
- **Idempotente:** El efecto sí (el servicio queda borrado); la respuesta no: repetirlo responde 404
- **Ficha del contrato:** [E-21](../api-contract.md#e-21--delete-v1businessservicesserviceid)

> Agregado el 2026-10-28 para completar el CRUD de servicios del c3-project (HU-16).
> **Diseñado, pendiente de implementar** en `beauty-salon-api`: todavía no tiene sonda en
> [`api-contract.md` §10](../api-contract.md#10-sondas).

---

## Request

| Parámetro | En | Tipo | Requerido | Reglas |
|-----------|----|------|-----------|--------|
| `serviceId` | path | string | Sí | Debe pertenecer al negocio autenticado |

Sin cuerpo.

---

## Response

**Éxito (204):** sin cuerpo. Se borran de verdad la fila de `service` y, en cascada, sus filas de
`schedule`.

---

## Errores

**Orden de comprobación:** sesión → rol → existe → es del negocio → tiene citas.

| Código | Cuándo | `code` | Qué hace la app |
|--------|--------|--------|-----------------|
| 401 | Sin token o vencido | `AUTH_REQUIRED` / `SESSION_EXPIRED` | Refresco transparente y un reintento |
| 403 | La sesión es de una clienta | `FORBIDDEN_ROLE` | La guarda no debería dejar llegar aquí |
| 404 | No existe | `SERVICE_NOT_FOUND`: "El servicio no existe." | Recarga la lista |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE`: "Este servicio pertenece a otro negocio." | Recarga la lista |
| 409 | Tiene al menos una cita, en cualquier estado | `SERVICE_HAS_APPOINTMENTS`: "Este servicio tiene citas registradas y no se puede eliminar. Puedes pausarlo para que deje de aparecer en el catálogo." | Mensaje con acceso directo a pausarlo |
| 5xx o timeout | Transitorio | — | Sin reintento automático. Al recargar, si ya no está en la lista, se dio por hecho |

---

## Eliminar contra pausar

| | Eliminar (este endpoint) | [Pausar](./business-update-service-status.md) |
|---|---|---|
| Cuándo | Servicio creado por error o de prueba, **sin ninguna cita** | Servicio con historia, o que se deja de prestar por un tiempo |
| Qué pasa con el registro | Desaparece de la base | Queda con `is_published = false` |
| Se puede deshacer | No | Sí, volviendo a publicar |
| Citas | No puede tener | Se respetan |

> Las citas guardan copia del nombre y el precio, pero siguen apuntando al servicio por
> `appointment.service_id`, que restringe el borrado
> ([data-model.md §5](../data-model.md#5-claves-foráneas-y-política-de-borrado)). Por eso un servicio
> con citas solo se pausa. La API lo comprueba antes de borrar para responder 409 y no un 500; si una
> cita se crea justo en medio, el motor rechaza el borrado y la API lo traduce al mismo 409.

---

## Caché y offline

- **Estrategia:** online-only.
- **Invalidación:** la lista de [servicios del negocio](./business-list-services.md) se vuelve a pedir
  y se invalida el caché del catálogo de la clienta. Si la clienta abre un enlace viejo al servicio,
  recibe 404 y la app muestra que no existe.
