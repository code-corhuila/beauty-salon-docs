# Endpoint — Pedir el código para recuperar la contraseña

- **Feature:** [Autenticación](../../01-architecture/features/auth.md)
- **Ficha del contrato:** [E-23](../api-contract.md#e-23--post-v1authpasswordforgot)
- **Método y ruta:** `POST /v1/auth/password/forgot`
- **Requiere sesión:** No. Lo usa [Recuperar contraseña](../../01-architecture/screens/recuperar-clave.md),
  justamente porque la persona no puede entrar
- **Agregado:** 2026-11-16

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `email` | body | string | Sí | Se recortan los espacios y se normaliza a minúsculas antes de enviar |

```json
{ "email": "laura@correo.com" }
```

---

## Response

**Éxito (202), siempre el mismo:**

```json
{ "message": "Si el correo tiene una cuenta, le enviamos un código." }
```

**Lo que pasa del lado del servidor:**

| Caso | Qué hace la API |
|------|-----------------|
| El correo tiene cuenta | Genera un código de 6 números, guarda solo su HMAC-SHA256 en `password_reset`, anula los códigos anteriores sin usar y envía el correo. El código vence a los **15 minutos** |
| Ya pidió uno hace menos de 60 s | No crea otro ni envía correo: **a lo sumo un correo por minuto por cuenta** |
| El correo no tiene cuenta | Nada. Responde el mismo 202 |
| El servidor de correo falla | Lo escribe en la consola de la API y responde el mismo 202 |

> **Por qué siempre 202:** si la respuesta cambiara según exista o no la cuenta, cualquiera podría
> usar este endpoint para averiguar qué correos están registrados en ManiCita.

**Mapeo DTO a dominio:** no hay. La app no lee el cuerpo: pasa al paso del código y muestra su propio
aviso ("Si {correo} tiene una cuenta, ya te llegó el código. Revisa también el correo no deseado.").

**El correo:** asunto "Tu código de ManiCita: NNNNNN", con el código grande, el aviso de que vence en 15
minutos y sirve una sola vez, y la frase "Si no lo pediste, ignora este correo: tu contraseña sigue
igual." En local llega a **Mailpit** (`http://localhost:8025`), que levanta `beauty-salon-infra`; sin
`SMTP_HOST` el código se escribe en la consola de la API.

---

## Errores

| Código | Cuándo | `code` | Qué hace la app |
|--------|--------|--------|-----------------|
| 422 | El correo no tiene formato de correo | `VALIDATION_FAILED`, `errors.email`: "Formato de correo inválido" | No debería llegar: **Enviar código** está desactivado mientras el correo no cumple el formato. Si llega, banner con el mensaje |
| 5xx o timeout | Transitorio | — | Banner de error de red. **No se reintenta solo**: es un POST |

---

## Caché y offline

- **Estrategia:** online-only. Sin conexión el botón queda desactivado con el aviso "Necesitas
  conexión para recuperar tu contraseña."
- **Entidad cacheada:** ninguna.
- **Reenvío:** el botón **Reenviar código** espera 60 s, lo mismo que la API, para no pedir un correo
  que no se va a enviar.
