# Endpoint — Crear cuenta

- **Feature:** [Autenticación](../../01-architecture/features/auth.md)
- **Método y ruta:** `POST /v1/auth/register`
- **Requiere sesión:** No

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `role` | body | string | Sí | `client` o `business`. Define qué otros campos son obligatorios |
| `name` | body | string | Sí | Nombre de la persona |
| `phone` | body | string | Sí | Celular colombiano de 10 dígitos |
| `email` | body | string | Sí | Único en el sistema |
| `password` | body | string | Sí | Mínimo 8 caracteres |
| `salonName` | body | string | Solo si `role` es `business` | Nombre del salón |
| `address` | body | string | Solo si `role` es `business` | Dirección visible en el catálogo |

```json
{
  "role": "business",
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

**Efecto adicional cuando `role` es `business`** (desde el 2026-09-25): en la misma transacción se
crean el usuario, el negocio y **su primera profesional**, con el mismo `name` de la cuenta. Sin
ella el negocio no podría publicar ningún servicio, porque todo servicio exige una profesional. Su
identificador se obtiene con [listar profesionales](./business-list-professionals.md); la respuesta
del registro no cambia.

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
