# Endpoint — Servicios más pedidos

- **Feature:** [Catálogo de servicios](../../01-architecture/features/catalog.md)
- **Ficha del contrato:** [E-22](../api-contract.md#e-22--get-v1servicespopular)
- **Método y ruta:** `GET /v1/services/popular`
- **Requiere sesión:** No. Lo usa la [pantalla de bienvenida](../../01-architecture/screens/bienvenida.md),
  que ve gente sin cuenta
- **Agregado:** 2026-11-16

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `limit` | query | number | No | Por defecto 8, mínimo 1, máximo 20. Un valor inválido se corrige al rango, no da error |

---

## Cómo se ordena

1. Solo servicios **publicados** (los pausados no aparecen nunca, igual que en E-05).
2. Primero los que tienen más citas en los **últimos 30 días** contados desde `now()`, por la fecha
   en que se **pidió** la cita (`created_at`), no por la fecha de la cita. Cuentan las citas
   `pending`, `confirmed` y `completed`; las `cancelled`, `rejected` y `no_show` no, porque no
   muestran interés real.
3. A igual número de citas, el servicio publicado más reciente primero, y después por `id` para que
   el orden sea estable.
4. Si en 30 días no hubo ninguna cita, la lista sale igual con los más recientes: el carrusel nunca
   queda vacío mientras haya servicios publicados.

El número de citas **no** se devuelve: es un dato del negocio que la clienta no necesita ver.

---

## Response

**Éxito (200):** la misma forma de `ServiceSummary` que E-05, sin paginar.

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
      "business": { "id": "biz_7", "name": "Nails Neiva", "address": "Calle 8 # 5-32" }
    }
  ]
}
```

**Mapeo DTO a dominio:** el mismo de [catalog-list-services.md](./catalog-list-services.md)
(`mapServiceListItem`). Un servicio con duración inválida se descarta.

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 5xx, timeout o sin red | Transitorio | No muestra el carrusel. No reintenta: la bienvenida sirve sin él |

Este endpoint **nunca devuelve 404**: sin servicios publicados es un 200 con `items` vacío.

---

## Caché y offline

- **Estrategia:** sin caché. Es un adorno de la entrada; no se guarda en SQLite.
- **Por qué no:** el catálogo ya tiene su caché para usarse sin conexión. Guardar también "lo más
  pedido" sumaría una tabla y una regla de vencimiento para algo que no hace falta sin red.
