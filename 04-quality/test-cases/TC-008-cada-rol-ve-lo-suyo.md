# Test Case — TC-008 · Cada rol ve solo lo suyo

> Copia de [`_template-test-case.md`](../_template-test-case.md). Pruebas automatizadas: sondas
> `FORBIDDEN_ROLE`, `FORBIDDEN_RESOURCE`, `AUTH_REQUIRED` y `SESSION_EXPIRED` del smoke test.

- **ID:** TC-008
- **Related story:** HU-007 registro e inicio de sesión ([auth](../../01-architecture/features/auth.md))
- **Feature / screen:** auth · guardas de ruta por rol
- **Platform(s):** Android (app) y API
- **Type:** Functional

**Regla que protege:** la agenda de un negocio tiene el nombre y el celular de sus clientas. Es el
dato más sensible de la app ([`security-rules.md`](../../00-governance/security-rules.md)).

---

## Preconditions

- Una cuenta de negocio N1 con servicios, otra cuenta de negocio N2 y una cuenta de clienta.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Con sesión de clienta, pedir `GET /v1/business/professionals` | 403 `FORBIDDEN_ROLE` |
| 2 | Con sesión de negocio, agendar una cita | 403 `FORBIDDEN_ROLE` |
| 3 | Con sesión de N2, editar un servicio de N1 (`PUT /v1/business/services/{id}`) | 403 `FORBIDDEN_RESOURCE` |
| 4 | Pedir "Mis citas" sin token | 401 `AUTH_REQUIRED` |
| 5 | Pedir "Mis citas" con un token inventado | 401 `SESSION_EXPIRED` |
| 6 | En la app, con sesión de clienta, escribir a mano una ruta `/business/...` | La guarda redirige al catálogo |

---

## Result

- **Status:** Pendiente de ejecución manual
- **Build:** —
- **Device / OS:** —
- **Notes / defects:** —
