# Endpoint — Publicar un servicio

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `POST /v1/negocio/servicios`
- **Requiere sesión:** Sí, con rol `negocio`

Es el endpoint del Sprint 1 y el que llena el catálogo. Sin él, la app de la clienta abre vacía.

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `name` | body | string | Sí | Hasta 60 caracteres |
| `type` | body | string | Sí | `tradicional`, `semipermanente`, `acrilicas`, `retiro`, `decoracion` |
| `description` | body | string | Sí | Qué incluye el servicio |
| `priceCop` | body | number | Sí | Entero en pesos, mayor a 0 |
| `durationMinutes` | body | number | Sí | Múltiplo de 15, entre 15 y 240 |
| `professionalId` | body | string | Sí | Profesional que lo atiende |
| `schedule` | body | array | Sí | Horario de atención por día de la semana |

```json
{
  "name": "Manicure semipermanente",
  "type": "semipermanente",
  "description": "Incluye limado, cutícula, esmaltado semipermanente y decoración sencilla.",
  "priceCop": 45000,
  "durationMinutes": 60,
  "professionalId": "prf_12",
  "schedule": [
    { "weekday": 1, "startTime": "09:00", "endTime": "18:00" },
    { "weekday": 2, "startTime": "09:00", "endTime": "18:00" },
    { "weekday": 6, "startTime": "09:00", "endTime": "14:00" }
  ]
}
```

> `schedule` va en la misma petición que el servicio a propósito. Son dos cosas distintas en el
> modelo de datos, pero para la manicurista es un solo acto: publicar lo que ofrece y cuándo. Partirlo
> en dos pantallas sería fiel al modelo y hostil con la usuaria.

---

## Response

**Éxito (201):** el servicio creado con el mismo formato de
[detalle de servicio](./catalogo-detalle-servicio.md), con `isPublished` en true.

**Mapeo DTO a dominio:** igual al del detalle. El servidor devuelve el `id` generado, que la app usa
para navegar de vuelta a la lista con el servicio ya visible.

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 422 | Validación fallida | `ValidationFailed` con `errors` por campo. **El formulario conserva todo lo escrito** |
| 403 | Sesión de clienta | `Unauthorized` |
| 409 | Horario que se solapa con otro servicio de la misma profesional | Mensaje que señala el día en conflicto |
| 401 | Sesión expirada | Refresco transparente y un reintento |
| 5xx o timeout | Transitorio | Sin reintento automático. Error con reintentar, conservando el formulario |

---

## Caché y offline

- **Estrategia:** online-only.
- **Entidad cacheada:** ninguna. La lista de servicios del negocio se consulta siempre en línea.
- **Invalidación:** publicar invalida el caché del catálogo de la clienta.
