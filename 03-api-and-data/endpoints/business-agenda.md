# Endpoint — Agenda del negocio

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `GET /v1/business/agenda`
- **Requiere sesión:** Sí, con rol `business`

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `date` | query | string | Sí | `YYYY-MM-DD`, el día que se está consultando |

El negocio se identifica por el token, nunca por un parámetro de la URL.

---

## Response

**Éxito (200):**

```json
{
  "date": "2026-09-12",
  "items": [
    {
      "id": "apt_501",
      "status": "pending",
      "startsAt": "2026-09-12T09:00:00-05:00",
      "service": { "id": "svc_128", "name": "Manicure semipermanente", "durationMinutes": 60 },
      "professional": { "id": "prf_12", "name": "Marcela Ruiz" },
      "client": { "name": "Laura Gómez", "phone": "3105551234" }
    }
  ]
}
```

**Mapeo DTO a dominio:** igual al de las citas de la clienta, más el bloque `client`.

> Este es el **único** endpoint que devuelve el celular de una clienta, y solo al negocio con el que
> ella agendó. Por eso su respuesta no se guarda nunca en la base local: ver
> [`persistence.md`](../persistence.md) y [`security-rules.md`](../../00-governance/security-rules.md).

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 403 | Sesión de clienta | `Unauthorized`; la guarda de navegación redirige antes de llegar aquí |
| 401 | Sesión expirada | Refresco transparente y un reintento |
| 5xx o timeout | Transitorio | Hasta 2 reintentos por ser GET; después, error con reintentar. **No hay caché al cual caer** |

Un día sin citas es un 200 con `items` vacío: estado `empty`, no error.

---

## Endpoint relacionado

Desde esta misma pantalla el negocio confirma o rechaza cada cita pendiente:
[`PATCH /v1/business/appointments/{id}/respond`](./business-respond-appointment.md).

---

## Caché y offline

- **Estrategia:** online-only, por privacidad, no por frescura.
- **Entidad cacheada:** ninguna.
- **TTL:** no aplica.
