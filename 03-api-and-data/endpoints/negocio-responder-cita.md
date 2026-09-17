# Endpoint — Confirmar o rechazar una cita

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `PATCH /v1/negocio/citas/{citaId}/responder`
- **Requiere sesión:** Sí, con rol `negocio`

Es la respuesta que cierra el ciclo: la clienta agendó y queda esperando que el negocio conteste.

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `citaId` | path | string | Sí | Debe pertenecer al negocio autenticado |
| `status` | body | string | Sí | `confirmada` o `rechazada` |
| `reason` | body | string | Solo si `status` es `rechazada` | Motivo que verá la clienta |

```json
{ "status": "rechazada", "reason": "Se me cruzó una cita más larga a esa hora" }
```

> El motivo es obligatorio al rechazar. Una cita que se cae sin explicación es exactamente el
> maltrato que la clienta ya vive por WhatsApp, y la app existe para reemplazar eso, no para
> automatizarlo.

---

## Response

**Éxito (200):** la cita con su nuevo estado, en el mismo formato de
[la agenda del negocio](./negocio-agenda.md).

| Efecto | Comportamiento |
|--------|----------------|
| `confirmada` | La clienta recibe la notificación y la cita queda en firme en Mis citas |
| `rechazada` | El cupo se libera y vuelve a aparecer en la disponibilidad; la clienta ve el motivo |

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 403 | La cita es de otro negocio | `Unauthorized` |
| 404 | La cita no existe | `NotFound`, recarga la agenda |
| 409 | La cita ya fue respondida, cancelada o ya pasó | Mensaje explicando el motivo y recarga de la agenda |
| 422 | Rechazo sin motivo | `ValidationFailed`, se pide el motivo |
| 401 | Sesión expirada | Refresco transparente y un reintento |
| 5xx o timeout | Transitorio | **Sin reintento automático**, es una escritura. Error con botón de reintentar |

---

## Caché y offline

- **Estrategia:** online-only.
- **Entidad cacheada:** ninguna. La agenda del negocio no se guarda en el dispositivo.
- **Invalidación:** responder invalida la agenda del negocio y las citas de la clienta.
