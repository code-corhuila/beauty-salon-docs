# Componente — DistintivoEstadoCita

- **Ubicación:** `src/shared/components/DistintivoEstadoCita.tsx`
- **Estado:** Draft

---

## Propósito

Muestra en qué estado está una cita: pendiente, confirmada, rechazada, cancelada, completada o no
asistió. Lo usan **dos features**: `appointments` (Mis citas y detalle de la cita, del lado de la
clienta) y `business` (agenda, del lado del negocio). Por eso vive en `shared/`.

El estado es el dato que más mira la clienta después de agendar ("¿ya me confirmaron?"), así que el
distintivo **nunca depende solo del color**: siempre lleva texto e ícono.

No se usa para otros estados que no sean de una cita (un servicio pausado, por ejemplo, tiene su
propio interruptor en la lista del negocio).

---

## Props

| Prop | Tipo | Requerido | Por defecto | Qué controla |
|------|------|-----------|-------------|--------------|
| `status` | `AppointmentStatus` (`'pending' \| 'confirmed' \| 'rejected' \| 'cancelled' \| 'completed' \| 'no_show'`) | Sí | — | El estado que se muestra; son los valores del contrato ([ADR-012](../../01-architecture/decisions/records/ADR-012-nombres-en-ingles.md)) |
| `size` | `'sm' \| 'md'` | No | `'sm'` | `sm` en listas (Mis citas, agenda), `md` en el encabezado del detalle |

> El componente traduce el estado a texto con i18n (`cita.estado.<status>`): quien lo usa pasa el
> valor del contrato, no un texto. Así ninguna pantalla escribe "Confirmada" a mano.

---

## Estados visuales

| `status` | Texto (es-CO) | Ícono (ionicons) | Color del texto y del borde |
|----------|---------------|------------------|-----------------------------|
| `pending` | Pendiente | `time-outline` | `color.warning` |
| `confirmed` | Confirmada | `checkmark-circle-outline` | `color.success` |
| `rejected` | Rechazada | `close-circle-outline` | `color.error` |
| `cancelled` | Cancelada | `remove-circle-outline` | `color.textSecondary` |
| `completed` | Completada | `checkmark-done-outline` | `color.textSecondary` |
| `no_show` | No asistió | `alert-circle-outline` | `color.textSecondary` |

Forma: píldora con fondo `color.surface`, borde de 1 px del mismo color del texto y radio
`radius.pill`. Los tres estados que ya no cambian (cancelada, completada, no asistió) van en gris a
propósito: son historial, no algo que pida atención.

---

## Tokens que usa

- Color: `color.warning`, `color.success`, `color.error`, `color.textSecondary`, `color.surface`
- Espaciado: `space.sm` horizontal, `space.xs` vertical; `space.xs` entre ícono y texto
- Radio: `radius.pill`
- Tipografía: `text.caption` en `sm`, `text.label` en `md`, peso 600

---

## Accesibilidad

- Se anuncia como texto: "Estado: Confirmada". El ícono es decorativo (`aria-hidden`), porque el
  texto ya dice lo mismo.
- No es interactivo: no tiene rol de botón ni área táctil propia.
- Contraste del texto sobre `color.surface`, medido: `warning` 5,8:1, `success` 6,3:1, `error`
  7,1:1 y `textSecondary` 6,1:1 en tema claro; entre 8,0:1 y 9,2:1 en tema oscuro. Todos cumplen
  AA en texto normal.
- Escala con la fuente del sistema: la píldora crece, no recorta el texto.

---

## Ejemplo de uso

```tsx
<DistintivoEstadoCita status={appointment.status} />

<DistintivoEstadoCita status={appointment.status} size="md" />
```
