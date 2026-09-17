# Endpoint — Cancelar una cita

- **Feature:** [Mis citas](../../01-architecture/features/appointments.md)
- **Método y ruta:** `PATCH /v1/citas/{citaId}/cancelar`
- **Requiere sesión:** Sí, con rol `clienta`

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `citaId` | path | string | Sí | Debe pertenecer a la clienta autenticada |
| `reason` | body | string | No | Motivo opcional; se le muestra al negocio |

```json
{ "reason": "Me salió un compromiso" }
```

---

## Response

**Éxito (200):** la cita completa con `status` en `cancelada`, con el mismo formato de
[listar mis citas](./citas-listar-mis-citas.md).

El cupo queda libre de inmediato y vuelve a aparecer en la disponibilidad del servicio.

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 403 | La cita es de otra clienta | `Unauthorized`. No debería ocurrir desde la app |
| 404 | La cita no existe | `NotFound`, vuelve a Mis citas |
| 409 | Ya está cancelada, o ya pasó | Mensaje explicando el motivo y recarga de la lista |
| 401 | Sesión expirada | Refresco transparente y un reintento |
| 5xx o timeout | Transitorio | **Sin reintento automático**, es una escritura. Error con botón de reintentar |

---

## Caché y offline

- **Estrategia:** online-only. Sin conexión el botón de cancelar queda deshabilitado con el motivo
  visible.
- **Por qué no se encola para enviarla al reconectar:** una cancelación que se queda guardada en el
  celular es peor que no cancelar. La manicurista sigue reservando la hora y pierde el cupo igual,
  pero además cree que la clienta va a llegar.
- **Invalidación:** cancelar invalida el caché de Mis citas.
