# Endpoint — Detalle de un servicio

- **Feature:** [Catálogo de servicios](../../01-architecture/features/catalog.md)
- **Método y ruta:** `GET /v1/servicios/{servicioId}`
- **Requiere sesión:** No. Es la ruta que recibe el deep link compartido por WhatsApp

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `servicioId` | path | string | Sí | Identificador del servicio |

---

## Response

**Éxito (200):**

```json
{
  "id": "svc_128",
  "name": "Manicure semipermanente",
  "type": "semipermanente",
  "description": "Incluye limado, cutícula, esmaltado semipermanente y decoración sencilla.",
  "priceCop": 45000,
  "durationMinutes": 60,
  "imageUrl": "https://cdn.manicita.app/svc_128.jpg",
  "isPublished": true,
  "professional": { "id": "prf_12", "name": "Marcela Ruiz" },
  "business": {
    "id": "biz_7",
    "name": "Nails Neiva",
    "address": "Calle 8 # 5-32, Neiva"
  }
}
```

**Mapeo DTO a dominio:** el mismo de la lista, más `description` e `isPublished`.

> El celular del negocio **no viene** en esta respuesta. Solo aparece cuando hay una cita confirmada,
> por la regla de privacidad de [`security-rules.md`](../../00-governance/security-rules.md).

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 404 | El servicio no existe | `NotFound`. Estado vacío con acción de volver al catálogo |
| 410 | El servicio fue pausado o eliminado | Mismo tratamiento que el 404, con el mensaje de que ya no está disponible |
| 5xx o timeout | Transitorio | Retroceso y hasta 2 reintentos; después, caché si existe, o error con reintentar |

---

## Caché y offline

- **Estrategia:** read-through cache.
- **Entidad cacheada:** [`servicios`](../entities/servicios.md).
- **TTL:** 30 minutos.
- **Nota:** con datos cacheados el detalle se muestra, pero **el botón de agendar se deshabilita**,
  porque agendar es online-only.
