# Endpoint — Listar mis citas

- **Feature:** [Mis citas](../../01-architecture/features/appointments.md)
- **Método y ruta:** `GET /v1/appointments/mine`
- **Requiere sesión:** Sí, con rol `client`

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `scope` | query | string | No | `upcoming` o `past`. Sin el parámetro devuelve ambas |
| `page` | query | number | No | Por defecto 1 |

La clienta se identifica por el token, no por un parámetro. Un `clientId` en la URL permitiría pedir
las citas de otra persona cambiando un número.

---

## Response

**Éxito (200):**

```json
{
  "items": [
    {
      "id": "apt_501",
      "status": "confirmed",
      "startsAt": "2026-09-12T09:00:00-05:00",
      "service": { "id": "svc_128", "name": "Manicure semipermanente", "priceCop": 45000, "durationMinutes": 60 },
      "professional": { "id": "prf_12", "name": "Marcela Ruiz" },
      "business": { "id": "biz_7", "name": "Nails Neiva", "address": "Calle 8 # 5-32, Neiva" },
      "rejectionReason": null
    }
  ],
  "page": 1,
  "totalPages": 1
}
```

**Mapeo DTO a dominio:** el mismo de [crear cita](./booking-create-appointment.md), más
`rejectionReason`, que solo tiene valor cuando el estado es `rejected`.

La separación entre próximas y pasadas la hace el caso de uso comparando `startsAt` con la hora
actual, no el servidor: así las dos pestañas se llenan con una sola petición.

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 401 | Sesión expirada | Refresco transparente y un reintento; si falla, cierra sesión |
| 5xx o timeout | Transitorio | Hasta 2 reintentos por ser GET; después, caché si existe, o error con reintentar |

Sin citas es un 200 con `items` vacío: es el estado `empty`, no un error.

---

## Caché y offline

- **Estrategia:** read-through cache.
- **Entidad cacheada:** [`appointment`](../entities/appointment.md), solo las de la clienta autenticada.
- **TTL:** 5 minutos, más corto que el del catálogo porque el estado de la cita lo cambia el negocio.
- **Invalidación:** al agendar, al cancelar, con pull-to-refresh y al recuperar la conexión.
