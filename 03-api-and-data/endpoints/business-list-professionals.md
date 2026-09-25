# Endpoint — Listar las profesionales del negocio

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `GET /v1/business/professionals`
- **Requiere sesión:** Sí, con rol `business`
- **Idempotente:** Sí (lectura)

> Agregado el 2026-09-25. Crear un servicio exige `professionalId`, pero ningún endpoint devolvía
> ese identificador: el formulario de servicio no tenía de dónde sacarlo. Hueco de contrato
> encontrado al probar la API de punta a punta.

---

## Request

Sin parámetros. El negocio sale del token, nunca de la URL.

---

## Response

**Éxito (200):**

```json
{
  "items": [
    { "id": "prf_8k2m4n6p9q", "name": "Marcela Ruiz" },
    { "id": "prf_3h5j7k9m2n", "name": "Laura Díaz" }
  ]
}
```

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `items` | array | No | Las profesionales del negocio. Nunca vacío: el registro crea la primera |
| `items[].id` | string | No | Identificador; es el `professionalId` que pide crear o editar servicio |
| `items[].name` | string | No | Nombre visible en el catálogo |

**Orden:** por `name` ascendente y, si se repite, por `id` ascendente.

**Sin paginación, a propósito:** un negocio tiene como máximo **20** profesionales (lo impone
[crear profesional](./business-create-professional.md)), así que la colección no puede crecer sin
límite.

---

## Errores

| Código | Cuándo | Cuerpo | Qué hace la app |
|--------|--------|--------|-----------------|
| 401 | Sin token o vencido | `{ "error": "Unauthorized" }` | Refresco transparente y un reintento |
| 403 | La sesión es de una clienta | `{ "error": "Forbidden" }` | La guarda de rutas no debería dejar llegar aquí |
| 5xx o timeout | Transitorio | — | Hasta 2 reintentos por ser GET; después, error con reintentar |

---

## Caché y offline

- **Estrategia:** online-only, igual que toda la gestión del negocio.
- **Entidad cacheada:** ninguna.
