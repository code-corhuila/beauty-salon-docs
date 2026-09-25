# Endpoint — Refrescar sesión

- **Feature:** [Autenticación](../../01-architecture/features/auth.md)
- **Método y ruta:** `POST /v1/auth/refresh`
- **Requiere sesión:** No requiere `accessToken` vigente (es justo lo que se está renovando), pero sí
  un `refreshToken` válido

> Este endpoint no estaba en la tabla original de 12 endpoints: se agregó el 2026-09-18 al
> implementar la API ([ADR-009](../../01-architecture/decisions/records/ADR-009-backend-repo-and-stack.md)),
> porque [`authentication.md`](../authentication.md) ya describía el comportamiento de refresco de
> token del lado del cliente sin que existiera el endpoint que lo hace posible. Es un hueco de
> contrato, no un rediseño: se documenta aquí primero, como exige el enfoque de este proyecto,
> antes de implementarlo.

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `refreshToken` | body | string | Sí | El guardado en el plugin de secure storage de Capacitor |

```json
{ "refreshToken": "eyJhbGciOi..." }
```

---

## Response

**Éxito (200):**

```json
{
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "eyJhbGciOi..."
}
```

Se emite un `refreshToken` nuevo en cada llamada (rotación): el interceptor debe reemplazar los dos
tokens guardados, no solo el `accessToken`.

Desde el 2026-09-25 la rotación **revoca el `refreshToken` anterior**: volver a usarlo responde 401.
Antes de esa fecha el anterior seguía sirviendo hasta vencer, y la fila "ya rotado" de la tabla de
errores no era cierta. La revocación se guarda en la tabla `revoked_refresh_token` del servidor,
la misma que usa [cerrar sesión](./auth-logout.md).

Consecuencia para la app: si dos peticiones refrescan a la vez con el mismo `refreshToken`, la
segunda recibe 401. El interceptor debe **serializar** el refresco (una sola llamada en vuelo; las
demás esperan su resultado).

**Mapeo DTO a dominio:** igual al de [`auth-login`](./auth-login.md) — ninguno de los dos campos
entra al dominio, van directo al plugin de secure storage.

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 401 | `refreshToken` inválido, vencido o ya rotado | El interceptor cierra sesión limpiamente, ver [`authentication.md`](../authentication.md) |
| 5xx o timeout | Transitorio | El interceptor lo trata igual que un 401 para no dejar a la usuaria en un estado intermedio: cierra sesión |

---

## Caché y offline

- **Estrategia:** online-only.
- **Entidad cacheada:** ninguna.
