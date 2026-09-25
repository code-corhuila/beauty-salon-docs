# Endpoint — Iniciar sesión

- **Feature:** [Autenticación](../../01-architecture/features/auth.md)
- **Método y ruta:** `POST /v1/auth/login`
- **Requiere sesión:** No

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `email` | body | string | Sí | Se normaliza a minúsculas antes de enviar |
| `password` | body | string | Sí | Viaja solo sobre TLS y nunca se registra en logs |

```json
{
  "email": "laura@correo.com",
  "password": "********"
}
```

---

## Response

**Éxito (200):**

```json
{
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "eyJhbGciOi...",
  "user": {
    "id": "usr_128",
    "name": "Laura Gómez",
    "role": "client"
  }
}
```

**Mapeo DTO a dominio:**

| Campo del DTO | Campo de dominio | Transformación |
|---------------|------------------|----------------|
| `accessToken`, `refreshToken` | — | No entran al dominio: van directo al plugin de secure storage de Capacitor |
| `user.role` | `Session.role` | string a enum `client` o `business`; un valor desconocido es error, no se asume clienta |
| `user.id`, `user.name` | `Session.userId`, `Session.name` | Directo |

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 401 | Credenciales inválidas | `Unauthorized`. Mensaje bajo el campo de contraseña, sin decir cuál de los dos falló |
| 422 | Correo con formato inválido | `ValidationFailed`, error bajo el campo |
| 429 | Demasiados intentos | Mensaje pidiendo esperar unos minutos |
| 5xx o timeout | Transitorio | Banner con reintentar. **No se reintenta solo**: es un POST |

---

## Caché y offline

- **Estrategia:** online-only.
- **Entidad cacheada:** ninguna. Los tokens van al plugin de secure storage de Capacitor.
- **TTL:** el `accessToken` dura 60 minutos y lo refresca el interceptor, ver
  [`authentication.md`](../authentication.md).
