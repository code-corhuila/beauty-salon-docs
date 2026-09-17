# Componente — SelectorHorario

- **Ubicación:** `src/shared/components/SelectorHorario.tsx`
- **Estado:** Draft

---

## Propósito

Mostrar los cupos de un día como una cuadrícula de horas y dejar que la clienta escoja una. Es el
componente donde ocurre la acción central del producto.

**No calcula nada.** Recibe la lista de cupos ya calculada por el caso de uso `getAvailability` y solo
la dibuja. La regla de negocio vive en el dominio, no aquí.

---

## Props

| Prop | Tipo | Requerido | Por defecto | Qué controla |
|------|------|-----------|-------------|--------------|
| `slots` | `Slot[]` | Sí | — | Cupos del día: hora de inicio y si está disponible |
| `selectedSlotId` | `string \| null` | Sí | — | Cupo seleccionado |
| `onSelect` | `(slotId: string) => void` | Sí | — | Selección de una hora |
| `columns` | `number` | No | `3` | Columnas de la cuadrícula; baja a 2 cuando la fuente del sistema es grande |

---

## Estados visuales

| Estado | Apariencia |
|--------|------------|
| Default | Celda con borde `color.border`, texto `color.textPrimary`, radio `radius.sm` |
| Pressed | Fondo `color.brandSoft` |
| Selected | Fondo `color.brand`, texto blanco |
| Disabled (cupo ocupado) | Texto `color.disabled` **y tachado**, sin borde |
| Loading | Cuadrícula de celdas en gris con animación suave, misma altura que la real |
| Error | No aplica: el error lo muestra la pantalla |

---

## Tokens que usa

- Color: `color.brand`, `color.brandSoft`, `color.border`, `color.textPrimary`, `color.disabled`
- Espaciado: `space.sm` entre celdas, `space.md` alrededor de la cuadrícula
- Radio: `radius.sm`
- Tipografía: `text.label` en la hora

---

## Accesibilidad

Este es el componente con mayor riesgo de accesibilidad de la app, porque tiene celdas pequeñas y
comunica disponibilidad:

- Cada celda anuncia hora y estado: "10:30 de la mañana, disponible" u "ocupada".
- La disponibilidad **no se comunica solo con color**: el cupo ocupado además va tachado.
- Área táctil de 48 dp por celda, ampliada con `padding` aunque la celda se vea más pequeña.
- La cuadrícula se anuncia como grupo de opciones, con la seleccionada marcada.
- Con la fuente más grande del sistema baja a 2 columnas en vez de recortar la hora.
- Cuando la disponibilidad se recarga sola tras un cupo tomado, el cambio se anuncia.

---

## Ejemplo de uso

```tsx
<SelectorHorario
  slots={state.slots}
  selectedSlotId={state.selectedSlot?.id ?? null}
  onSelect={handleSlotSelect}
/>
```
