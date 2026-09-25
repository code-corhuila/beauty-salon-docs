# Endpoint — Cerrar sesión

- **Feature:** [Autenticación](../../01-architecture/features/auth.md)
- **Método y ruta:** `POST /v1/auth/logout`
- **Requiere sesión:** No requiere `accessToken`; sí el `refreshToken` que se quiere revocar
- **Idempotente:** Sí. Cerrar dos veces la misma sesión responde igual

> Agregado el 2026-09-25. Antes, cerrar sesión era solo borrar los tokens del dispositivo, y
> **borrarlos no es revocarlos**: quien hubiera copiado el `refreshToken` podía seguir renovando
> la sesión durante 30 días.

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `refreshToken` | body | string | Sí | El guardado en el secure storage |

```json
{ "refreshToken": "eyJhbGciOi..." }
```

---

## Response

**Éxito (204):** sin cuerpo. El `refreshToken` queda revocado: [refrescar](./auth-refresh.md) con
él responde 401.

**Lo que no hace, y se declara:** el `accessToken` vigente **no** se revoca. Sigue siendo válido
hasta que venza (60 minutos como máximo). La app lo borra del dispositivo de todos modos.

---

## Errores

| Código | Cuándo | Cuerpo | Qué hace la app |
|--------|--------|--------|-----------------|
| 401 | `refreshToken` falta, está mal firmado o ya venció | `{ "error": "Unauthorized" }` | Nada distinto: borra los tokens locales y va al login igual |
| 5xx o timeout | Transitorio | — | Igual: borra los tokens locales y va al login. **Cerrar sesión nunca falla para la usuaria** |

Un `refreshToken` que ya estaba revocado responde **204**, no 401: el resultado que se pedía ya se
cumple.

---

## Caché y offline

- **Estrategia:** se intenta una vez. Sin conexión, la app cierra la sesión localmente y no reintenta.
- **Invalidación:** se vacían los tokens y la tabla local [`appointment`](../entities/appointment.md).
