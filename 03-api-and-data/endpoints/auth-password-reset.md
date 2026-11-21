# Endpoint — Cambiar la contraseña con el código

- **Feature:** [Autenticación](../../01-architecture/features/auth.md)
- **Ficha del contrato:** [E-24](../api-contract.md#e-24--post-v1authpasswordreset)
- **Método y ruta:** `POST /v1/auth/password/reset`
- **Requiere sesión:** No. Exige el código que llegó al correo con [E-23](./auth-password-forgot.md)
- **Idempotente:** No. El código sirve una sola vez
- **Agregado:** 2026-11-16

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `email` | body | string | Sí | El mismo del paso 1, en minúsculas |
| `code` | body | string | Sí | Exactamente 6 números. Viaja como texto: un código como `004211` no pierde los ceros |
| `newPassword` | body | string | Sí | De 8 a 64 caracteres, sin espacios, con al menos una letra y un número (la regla del [registro](./auth-register.md)). Viaja solo sobre TLS y nunca se registra en logs |

```json
{
  "email": "laura@correo.com",
  "code": "482913",
  "newPassword": "********"
}
```

La app valida antes de enviar que el código tenga 6 números, que la contraseña cumpla la regla y que
**Repite la contraseña nueva** sea igual. Ese tercer campo no viaja.

---

## Response

**Éxito (204):** sin cuerpo.

| Efecto | Comportamiento |
|--------|----------------|
| Contraseña | Se guarda el bcrypt de la nueva. La vieja deja de servir en [login](./auth-login.md) |
| Código | Queda usado (`used_at`): no sirve otra vez |
| Sesiones abiertas | **Se cierran todas:** `password_changed_at = now()` y [refrescar](./auth-refresh.md) con un `refreshToken` emitido antes responde 401 `INVALID_REFRESH_TOKEN`. El `accessToken` que ya tenga otro dispositivo sigue valiendo hasta vencer (60 minutos como máximo) |
| Sesión en este dispositivo | **No se abre.** La app vuelve a `/login` con el correo lleno y el aviso "Listo, cambiaste tu contraseña. Entra con la nueva." |

**Mapeo DTO a dominio:** no hay cuerpo. El caso de uso `resetPassword` devuelve `changed`.

---

## Errores

**Orden de comprobación:** los tres campos a la vez → hay un código vigente (sin usar, sin vencer)
de esa cuenta con menos de 5 intentos → el código coincide.

| Código | Cuándo | `code` | Qué hace la app |
|--------|--------|--------|-----------------|
| 400 | Correo sin cuenta, código errado, vencido, ya usado, anulado por uno nuevo, o 5 intentos errados | `INVALID_RESET_CODE`: "El código no es correcto o ya venció. Revisa el correo o pide uno nuevo." | Mensaje bajo el campo **Código**. Conserva la contraseña escrita |
| 422 | Campos inválidos | `VALIDATION_FAILED`, `errors.code`: "Son 6 números" · `errors.newPassword`: "De 8 a 64 caracteres, sin espacios, con al menos una letra y un número" · `errors.email` | Mensaje bajo cada campo. No debería llegar: la app valida lo mismo antes |
| 5xx o timeout | Transitorio | — | Banner de error de red. **No se reintenta solo**: un reintento con el mismo código respondería 400 aunque el primero hubiera funcionado |

Cada código errado suma un intento; al quinto, el código ya no sirve aunque después se escriba el
correcto, y hay que tocar **Reenviar código**.

---

## Caché y offline

- **Estrategia:** online-only.
- **Entidad cacheada:** ninguna. No se guardan tokens: no se abre sesión.
