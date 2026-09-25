# Endpoint — Listar los servicios del negocio

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `GET /v1/business/services`
- **Requiere sesión:** Sí, con rol `business`
- **Idempotente:** Sí (lectura)

> Agregado el 2026-09-25. La pantalla [Mis servicios](../../01-architecture/screens/negocio-servicios.md)
> muestra los servicios propios **publicados y pausados**, pero [`GET /v1/services`](./catalog-list-services.md)
> solo devuelve los publicados, y de todos los negocios.

---

## Request

| Parámetro | En | Tipo | Requerido | Por omisión | Notas |
|-----------|----|------|-----------|-------------|-------|
| `page` | query | entero | No | 1 | Menor que 1 o no numérico → se sirve 1 |
| `pageSize` | query | entero | No | 20 | Mayor que 50 → se recorta a 50; menor que 1 o no numérico → 20 |

El negocio sale del token, nunca de la URL.

---

## Response

**Éxito (200):**

```json
{
  "items": [
    {
      "id": "svc_128",
      "name": "Manicure semipermanente",
      "type": "semi_permanent",
      "priceCop": 45000,
      "durationMinutes": 60,
      "imageUrl": null,
      "professional": { "id": "prf_12", "name": "Marcela Ruiz" },
      "business": { "id": "biz_7", "name": "Nails Neiva", "address": "Calle 8 # 5-32, Neiva" },
      "description": "Incluye limado, cutícula y esmaltado.",
      "isPublished": false,
      "schedule": [
        { "weekday": 1, "startTime": "09:00", "endTime": "18:00" }
      ]
    }
  ],
  "page": 1,
  "totalPages": 1
}
```

Cada ítem es el detalle de servicio (el de [crear servicio](./business-create-service.md)) más su
`schedule`, porque la pantalla de edición lo necesita para precargar el formulario.

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `items` | array | No | Vacío es `[]`, nunca nulo. Vacío es el estado `empty` del onboarding |
| `items[].isPublished` | boolean | No | `false` = pausado |
| `items[].imageUrl` | string | **Sí** | Nulo si el servicio no tiene imagen |
| `items[].schedule` | array | No | Días de atención, ordenados por `weekday` y `startTime` |
| `items[].schedule[].weekday` | entero | No | ISO: 1 = lunes … 7 = domingo |
| `items[].schedule[].startTime` / `endTime` | string | No | `HH:mm`, hora de Colombia |
| `page` | entero | No | La página servida, ya corregida |
| `totalPages` | entero | No | `max(1, ceil(total / pageSize))` |

**Orden:** por fecha de creación descendente y, si coincide, por `id` descendente.

---

## Errores

| Código | Cuándo | Cuerpo | Qué hace la app |
|--------|--------|--------|-----------------|
| 401 | Sin token o vencido | `{ "error": "Unauthorized" }` | Refresco transparente y un reintento |
| 403 | La sesión es de una clienta | `{ "error": "Forbidden" }` | La guarda no debería dejar llegar aquí |
| 5xx o timeout | Transitorio | — | Hasta 2 reintentos por ser GET; después, error con reintentar |

---

## Caché y offline

- **Estrategia:** online-only; la lista no se cachea (ver la pantalla).
- **Invalidación:** se vuelve a pedir tras crear, editar, pausar o publicar.
