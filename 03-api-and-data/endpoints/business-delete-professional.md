# Endpoint — Eliminar una profesional

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `DELETE /v1/business/professionals/{professionalId}`
- **Requiere sesión:** Sí, con rol `business`, dueño de la profesional
- **Idempotente:** El efecto sí (la profesional queda borrada); la respuesta no: repetirlo responde 404
- **Ficha del contrato:** [E-20](../api-contract.md#e-20--delete-v1businessprofessionalsprofessionalid)

> Agregado el 2026-10-28 para completar el CRUD de profesionales del c3-project (HU-15).
> **Diseñado, pendiente de implementar** en `beauty-salon-api`: todavía no tiene sonda en
> [`api-contract.md` §10](../api-contract.md#10-sondas).

---

## Request

| Parámetro | En | Tipo | Requerido | Reglas |
|-----------|----|------|-----------|--------|
| `professionalId` | path | string | Sí | Debe pertenecer al negocio autenticado |

Sin cuerpo.

---

## Response

**Éxito (204):** sin cuerpo. La fila de `professional` se borra de verdad (no hay baja lógica).

---

## Errores

**Orden de comprobación:** sesión → rol → existe → es del negocio → es la última → está en uso.

| Código | Cuándo | `code` | Qué hace la app |
|--------|--------|--------|-----------------|
| 401 | Sin token o vencido | `AUTH_REQUIRED` / `SESSION_EXPIRED` | Refresco transparente y un reintento |
| 403 | La sesión es de una clienta | `FORBIDDEN_ROLE` | La guarda no debería dejar llegar aquí |
| 404 | No existe | `PROFESSIONAL_NOT_FOUND`: "La profesional no existe." | Recarga la lista |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE`: "Esta profesional pertenece a otro negocio." | Recarga la lista |
| 409 | Es la única profesional del negocio | `LAST_PROFESSIONAL`: "El negocio debe tener al menos una profesional." | Mensaje; no se borra |
| 409 | Tiene servicios o citas, en cualquier estado | `PROFESSIONAL_IN_USE`: "Esta profesional tiene servicios o citas registradas y no se puede eliminar. Asigna sus servicios a otra profesional o páusalos." | Mensaje; no se borra |
| 5xx o timeout | Transitorio | — | Sin reintento automático. Al recargar, si ya no está en la lista, se dio por hecho |

---

## Notas

- **Por qué no se borra una profesional con historia:** `service.professional_id` y
  `appointment.professional_id` son claves foráneas que restringen el borrado
  ([data-model.md §5](../data-model.md#5-claves-foráneas-y-política-de-borrado)). Borrarla dejaría
  servicios inagendables y citas sin a quién referir. La API lo comprueba **antes** de intentar el
  borrado para responder 409 con un mensaje claro, y no un 500 por la violación de la clave foránea.
- **Por qué no puede quedar en cero:** [E-11](./business-list-professionals.md) promete una lista
  nunca vacía, y sin profesional el negocio no puede crear servicios. El registro del negocio crea la
  primera ([E-01](./auth-register.md)).
- Las dos comprobaciones (última y en uso) tienen carrera con una creación simultánea de servicio; se
  acepta, igual que el límite de 20 de E-12 (D-04). Si la carrera pasa, el motor rechaza el borrado
  por la clave foránea y la API lo traduce a 409 `PROFESSIONAL_IN_USE`.

---

## Caché y offline

- **Estrategia:** online-only.
- **Invalidación:** la lista de [profesionales](./business-list-professionals.md) se vuelve a pedir.
