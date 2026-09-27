# Endpoint — Crear una profesional

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `POST /v1/business/professionals`
- **Requiere sesión:** Sí, con rol `business`
- **Idempotente:** No. Un reintento crea otra profesional con el mismo nombre

> Agregado el 2026-09-25. Antes no existía ninguna forma de crear profesionales por la API, así que
> un negocio recién registrado no podía publicar servicios. Desde esa fecha, además,
> [el registro de un negocio](./auth-register.md) crea automáticamente su primera profesional; este
> endpoint sirve para agregar a las demás.

---

## Request

| Parámetro | En | Tipo | Requerido | Reglas |
|-----------|----|------|-----------|--------|
| `name` | body | string | Sí | No vacío después de recortar espacios, hasta 60 caracteres |

```json
{ "name": "Laura Díaz" }
```

---

## Response

**Éxito (201):**

```json
{ "id": "prf_3h5j7k9m2n", "name": "Laura Díaz" }
```

| Campo | Tipo | Nulo | Qué es |
|-------|------|------|--------|
| `id` | string | No | Identificador nuevo |
| `name` | string | No | El nombre, recortado de espacios |

---

## Errores

**Orden de comprobación:** sesión → rol → `name` → límite de 20.

| Código | Cuándo | `code` | Qué hace la app |
|--------|--------|--------|-----------------|
| 401 | Sin token o vencido | `AUTH_REQUIRED` / `SESSION_EXPIRED` | Refresco transparente y un reintento |
| 403 | La sesión es de una clienta | `FORBIDDEN_ROLE` | La guarda no debería dejar llegar aquí |
| 422 | `name` vacío o largo | `VALIDATION_FAILED`, `errors.name`: "Es requerido, hasta 60 caracteres" | Marca el campo |
| 422 | El negocio ya tiene 20 | `VALIDATION_FAILED`, `errors.name`: "Un negocio puede tener hasta 20 profesionales" | Mensaje bajo el campo |
| 5xx o timeout | Transitorio | — | **Sin reintento automático** (no es idempotente); error con botón de reintentar |

---

## Notas

- La profesional **no tiene** foto, teléfono ni especialidad, y no es un olvido: el catálogo solo
  muestra su nombre.
- No hay editar ni borrar profesional en esta versión. Borrarla dejaría servicios y citas históricas
  sin a quién referir.

---

## Caché y offline

- **Estrategia:** online-only.
- **Invalidación:** la lista de [profesionales](./business-list-professionals.md) se vuelve a pedir.
