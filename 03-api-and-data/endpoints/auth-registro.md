# Endpoint — Crear cuenta

- **Feature:** [Autenticación](../../01-architecture/features/auth.md)
- **Método y ruta:** `POST /v1/auth/registro`
- **Requiere sesión:** No

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `role` | body | string | Sí | `clienta` o `negocio`. Define qué otros campos son obligatorios |
| `name` | body | string | Sí | Nombre de la persona |
| `phone` | body | string | Sí | Celular colombiano de 10 dígitos |
| `email` | body | string | Sí | Único en el sistema |
| `password` | body | string | Sí | Mínimo 8 caracteres |
| `salonName` | body | string | Solo si `role` es `negocio` | Nombre del salón |
| `address` | body | string | Solo si `role` es `negocio` | Dirección visible en el catálogo |

```json
{
  "role": "negocio",
  "name": "Marcela Ruiz",
  "phone": "3115557788",
  "email": "marcela@correo.com",
  "password": "********",
  "salonName": "Nails Neiva",
  "address": "Calle 8 # 5-32, Neiva"
}
```

---

## Response

**Éxito (201):** el mismo cuerpo de [`auth-login`](./auth-login.md), con la sesión ya abierta. La
usuaria no tiene que volver a escribir sus datos para entrar.

**Mapeo DTO a dominio:** idéntico al de login.

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 409 | El correo ya está registrado | Error bajo el campo de correo, con enlace a iniciar sesión |
| 422 | Validación fallida | `ValidationFailed` con `errors` por campo; el formulario los muestra y **conserva lo escrito** |
| 5xx o timeout | Transitorio | Banner con reintentar, sin reintento automático |

Cuerpo de un 422:

```json
{
  "error": "ValidationFailed",
  "errors": { "phone": "Debe tener 10 dígitos" }
}
```

---

## Caché y offline

- **Estrategia:** online-only. Sin conexión el botón se deshabilita con el motivo visible.
- **Entidad cacheada:** ninguna.
