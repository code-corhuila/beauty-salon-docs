# Endpoint — Listar servicios publicados

- **Feature:** [Catálogo de servicios](../../01-architecture/features/catalog.md)
- **Método y ruta:** `GET /v1/services`
- **Requiere sesión:** No. El catálogo se explora sin cuenta a propósito

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `type` | query | string | No | `traditional`, `semi_permanent`, `acrylic`, `removal`, `nail_art` |
| `page` | query | number | No | Por defecto 1 |
| `pageSize` | query | number | No | Por defecto 20, máximo 50 |

Solo devuelve servicios en estado publicado. Los pausados no aparecen nunca en este endpoint.

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
      "imageUrl": "https://cdn.manicita.app/svc_128.jpg",
      "professional": { "id": "prf_12", "name": "Marcela Ruiz" },
      "business": { "id": "biz_7", "name": "Nails Neiva", "address": "Calle 8 # 5-32" }
    }
  ],
  "page": 1,
  "totalPages": 3
}
```

**Mapeo DTO a dominio:**

| Campo del DTO | Campo de dominio | Transformación |
|---------------|------------------|----------------|
| `priceCop` | `Service.priceCop` | Entero en pesos. La UI lo formatea con `Intl.NumberFormat`, el dominio no guarda texto |
| `durationMinutes` | `Service.durationMinutes` | Directo. Si no es múltiplo de 15, se descarta el servicio y se registra el dato inválido |
| `type` | `ServiceType` | string a enum; un tipo desconocido se mapea a `otro` y el servicio igual se muestra |
| `professional`, `business` | Se aplanan en `Service` y se guardan además en sus tablas | Ver [`service`](../entities/service.md) |

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 5xx o timeout | Transitorio | Retroceso y hasta 2 reintentos por ser GET; después, muestra el caché si existe, o el estado de error |
| Payload malformado | Contrato roto | `ServerError`. No se rellena con valores por defecto |

Este endpoint **nunca devuelve 404**: un catálogo sin resultados es un 200 con `items` vacío, y eso
es el estado `empty` de la pantalla, no un error.

---

## Caché y offline

- **Estrategia:** read-through cache.
- **Entidades cacheadas:** [`service`](../entities/service.md),
  [`professional`](../entities/professional.md), [`business`](../entities/business.md).
- **TTL:** 30 minutos. Vencido, se muestra lo cacheado y se refresca en segundo plano.
- **Invalidación:** al hacer pull-to-refresh y al recuperar la conexión.
