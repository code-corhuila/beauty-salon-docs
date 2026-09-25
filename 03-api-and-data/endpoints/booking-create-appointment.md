# Endpoint — Crear la cita

- **Feature:** [Agendamiento](../../01-architecture/features/booking.md)
- **Método y ruta:** `POST /v1/appointments`
- **Requiere sesión:** Sí, con rol `client`

Es el endpoint donde el MVP se cumple o no se cumple.

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `serviceId` | body | string | Sí | Servicio que se agenda |
| `slotId` | body | string | Sí | Cupo devuelto por [disponibilidad](./booking-availability.md) |
| `clientRequestId` | body | string | Sí | UUID generado en el cliente para que el servidor pueda descartar envíos duplicados |

```json
{
  "serviceId": "svc_128",
  "slotId": "slt_20260912_0900",
  "clientRequestId": "b3f1c2a4-7d21-4e39-9a10-2c5f8e6d1b40"
}
```

> `clientRequestId` existe porque este POST **no se reintenta automáticamente**, pero la usuaria sí
> puede tocar dos veces el botón o reintentar tras un timeout. Sin él, un reintento manual crearía
> dos citas a la misma hora.

---

## Response

**Éxito (201):**

```json
{
  "id": "apt_501",
  "status": "pending",
  "startsAt": "2026-09-12T09:00:00-05:00",
  "service": { "id": "svc_128", "name": "Manicure semipermanente", "priceCop": 45000, "durationMinutes": 60 },
  "professional": { "id": "prf_12", "name": "Marcela Ruiz" },
  "business": { "id": "biz_7", "name": "Nails Neiva", "address": "Calle 8 # 5-32, Neiva" },
  "createdAt": "2026-09-07T15:42:10-05:00"
}
```

**Mapeo DTO a dominio:**

| Campo del DTO | Campo de dominio | Transformación |
|---------------|------------------|----------------|
| `status` | `AppointmentStatus` | string a enum: `pending`, `confirmed`, `rejected`, `cancelled`, `completed`, `no_show`. Un valor desconocido es error |
| `startsAt`, `createdAt` | `Date` | ISO 8601 con zona |
| `service`, `professional`, `business` | Se aplanan en `Appointment` | Ver [`appointment`](../entities/appointment.md) |

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| **409** | **El cupo ya fue tomado** | `SlotTaken`: la pantalla pasa al estado del mismo nombre, avisa que alguien acaba de tomar esa hora y **recarga la disponibilidad automáticamente** |
| 401 | Sesión expirada | El interceptor refresca y reintenta una vez; si falla, cierra sesión |
| 403 | Sesión de negocio intentando agendar | `Unauthorized`; la guarda no debería haber dejado llegar hasta aquí |
| 410 | El servicio fue pausado mientras se agendaba | Mensaje y vuelta al catálogo |
| 422 | Cupo inexistente o vencido | Se recarga la disponibilidad |
| 5xx o timeout | Transitorio | **Sin reintento automático.** Error con botón de reintentar, que reenvía el mismo `clientRequestId` |

---

## Caché y offline

- **Estrategia:** online-only, sin excepción.
- **Entidad cacheada:** la cita creada se guarda en [`appointment`](../entities/appointment.md) para que aparezca
  de inmediato en Mis citas.
- **Invalidación:** crear una cita invalida el caché de Mis citas.
