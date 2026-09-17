# Endpoint — Disponibilidad de un servicio

- **Feature:** [Agendamiento](../../01-architecture/features/booking.md)
- **Método y ruta:** `GET /v1/servicios/{servicioId}/disponibilidad`
- **Requiere sesión:** No. Se puede mirar la disponibilidad antes de registrarse; la sesión se exige
  al confirmar

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `servicioId` | path | string | Sí | Servicio que se quiere agendar |
| `fecha` | query | string | Sí | Formato `YYYY-MM-DD`, hasta 14 días hacia adelante |

---

## Response

**Éxito (200):**

```json
{
  "date": "2026-09-12",
  "durationMinutes": 60,
  "slots": [
    { "id": "slt_20260912_0900", "startsAt": "2026-09-12T09:00:00-05:00", "isAvailable": true },
    { "id": "slt_20260912_1000", "startsAt": "2026-09-12T10:00:00-05:00", "isAvailable": false },
    { "id": "slt_20260912_1100", "startsAt": "2026-09-12T11:00:00-05:00", "isAvailable": true }
  ]
}
```

**Cómo se arma esa lista, del lado del servidor:**

```
horario de atención de la profesional ese día
  dividido en bloques del tamaño de durationMinutes
  menos los bloques ocupados por citas Pendientes o Confirmadas
```

**Mapeo DTO a dominio:**

| Campo del DTO | Campo de dominio | Transformación |
|---------------|------------------|----------------|
| `startsAt` | `Slot.startsAt` | ISO 8601 con zona a `Date`. La zona del servidor es `America/Bogota` |
| `isAvailable` | `Slot.isAvailable` | Directo, **y además** el caso de uso marca como no disponible todo cupo cuya hora ya pasó |
| `id` | `Slot.id` | Es el identificador que se envía al crear la cita |

> El servidor es la autoridad del cupo. El caso de uso `getAvailability` aplica la misma regla del
> lado del cliente solo para descartar las horas de hoy que ya pasaron mientras la clienta miraba la
> pantalla, y para poder probar la regla sin backend.

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 404 | El servicio no existe | `NotFound`, vuelve al catálogo |
| 410 | El servicio está pausado | Mensaje de que ya no se puede agendar |
| 422 | Fecha inválida o fuera del rango de 14 días | `ValidationFailed`; no debería ocurrir, el selector lo impide |
| 5xx o timeout | Transitorio | Hasta 2 reintentos por ser GET, con el timeout corto de 8 s, y después error con reintentar |

Un día sin cupos es un **200 con `slots` vacío**, no un 404: ese es el estado `empty` de la pantalla.

---

## Caché y offline

- **Estrategia:** online-only. **La disponibilidad no se cachea nunca.**
- **Entidad cacheada:** ninguna.
- **TTL:** no aplica. Un cupo guardado es un cupo mentiroso: pudo haberlo tomado otra clienta hace un
  minuto.
