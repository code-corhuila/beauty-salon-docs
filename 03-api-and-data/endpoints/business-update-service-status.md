# Endpoint — Pausar o publicar un servicio

- **Feature:** [Gestión del negocio](../../01-architecture/features/business.md)
- **Método y ruta:** `PATCH /v1/business/services/{serviceId}/status`
- **Requiere sesión:** Sí, con rol `business`

---

## Request

| Parámetro | En | Tipo | Requerido | Notas |
|-----------|----|------|-----------|-------|
| `serviceId` | path | string | Sí | Debe pertenecer al negocio autenticado |
| `isPublished` | body | boolean | Sí | `false` pausa, `true` vuelve a publicar |

```json
{ "isPublished": false }
```

---

## Response

**Éxito (200):** el servicio con su nuevo estado.

**Qué significa pausar, exactamente:**

| Efecto | Comportamiento |
|--------|----------------|
| Catálogo de la clienta | El servicio desaparece de `GET /v1/services` |
| Deep link al detalle | Devuelve 410, y la app muestra que ya no está disponible |
| Citas ya agendadas | **Se respetan.** Siguen en la agenda del negocio y en Mis citas de la clienta |
| Disponibilidad | Deja de ofrecer cupos nuevos |

> Pausar no es borrar. Una manicurista que se va de vacaciones no quiere perder su servicio ni
> cancelarle a las clientas que ya agendaron; quiere dejar de recibir citas nuevas.

---

## Errores

| Código | Significado | Qué hace la app |
|--------|-------------|-----------------|
| 403 | El servicio es de otro negocio | `Unauthorized` |
| 404 | No existe | `NotFound`, recarga la lista |
| 401 | Sesión expirada | Refresco transparente y un reintento |
| 5xx o timeout | Transitorio | Sin reintento automático. **El cambio optimista de la lista se revierte** y se muestra el error |

---

## Caché y offline

- **Estrategia:** online-only.
- **Entidad cacheada:** ninguna.
- **Invalidación:** invalida el caché del catálogo de la clienta.
