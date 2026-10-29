# Endpoint — Editar una profesional

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `PUT /v1/business/professionals/{professionalId}`
- **Requiere sesión:** Sí, con rol `business`, dueño de la profesional
- **Idempotente:** Sí. Aplicarlo dos veces con el mismo nombre deja el mismo estado
- **Ficha del contrato:** [E-19](../api-contract.md#e-19--put-v1businessprofessionalsprofessionalid)

> Agregado el 2026-10-28 para completar el CRUD de profesionales del c3-project (HU-15).
> **Diseñado, pendiente de implementar** en `beauty-salon-api`: todavía no tiene sonda en
> [`api-contract.md` §10](../api-contract.md#10-sondas).

---

## Request

| Parámetro | En | Tipo | Requerido | Reglas |
|-----------|----|------|-----------|--------|
| `professionalId` | path | string | Sí | Debe pertenecer al negocio autenticado |
| `name` | body | string | Sí | No vacío después de recortar espacios, hasta 60 caracteres |

```json
{ "name": "Laura Díaz Rojas" }
```

---

## Response

**Éxito (200):**

```json
{ "id": "prf_3h5j7k9m2n", "name": "Laura Díaz Rojas" }
```

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `id` | string | No | El mismo identificador |
| `name` | string | No | El nombre nuevo, recortado de espacios |

---

## Errores

**Orden de comprobación:** sesión → rol → `name` → existe → es del negocio.

| Código | Cuándo | `code` | Qué hace la app |
|--------|--------|--------|-----------------|
| 401 | Sin token o vencido | `AUTH_REQUIRED` / `SESSION_EXPIRED` | Refresco transparente y un reintento |
| 403 | La sesión es de una clienta | `FORBIDDEN_ROLE` | La guarda no debería dejar llegar aquí |
| 422 | `name` vacío o largo | `VALIDATION_FAILED`, `errors.name`: "Es requerido, hasta 60 caracteres" | Marca el campo |
| 404 | No existe | `PROFESSIONAL_NOT_FOUND`: "La profesional no existe." | Mensaje y recarga la lista |
| 403 | Es de otro negocio | `FORBIDDEN_RESOURCE`: "Esta profesional pertenece a otro negocio." | Mensaje y recarga la lista |
| 5xx o timeout | Transitorio | — | Un reintento automático (es idempotente); si vuelve a fallar, error con botón de reintentar |

---

## Notas

- Solo cambia el nombre: la profesional no tiene más campos ([E-12](./business-create-professional.md)).
- **El nombre nuevo se ve en todas partes, también en las citas viejas.** La cita guarda copia del
  nombre y el precio del servicio, pero **no** del nombre de la profesional: Mis citas y la agenda lo
  leen de `professional` en cada consulta. Es aceptable porque editar sirve para corregir cómo se
  escribe el nombre, no para cambiar de persona; para eso se crea otra profesional.

---

## Caché y offline

- **Estrategia:** online-only.
- **Invalidación:** la lista de [profesionales](./business-list-professionals.md) se vuelve a pedir, y
  el caché del catálogo de la clienta, porque muestra el nombre de la profesional.
