# Componente — BotonSecundario

- **Ubicación:** `src/shared/components/BotonSecundario.tsx`
- **Estado:** Draft

---

## Propósito

Las acciones que no son la principal de la pantalla, incluidas las **destructivas**: cancelar una
cita (detalle de la cita, feature `appointments`) y rechazar una cita (agenda del negocio, feature
`business`). [`BotonPrimario`](./boton-primario.md) ya lo anuncia: "para acciones secundarias o
destructivas se usa `BotonSecundario`, no una variante de este".

Se separa del primario para que la jerarquía se vea: en una pantalla hay un solo botón relleno de
color de marca, y todo lo demás tiene menos peso visual. Una acción destructiva **nunca** debe verse
como la acción principal.

---

## Props

| Prop | Tipo | Requerido | Por defecto | Qué controla |
|------|------|-----------|-------------|--------------|
| `label` | `string` | Sí | — | Texto del botón, ya traducido por quien lo usa |
| `onPress` | `() => void` | Sí | — | Acción al tocar |
| `isDestructive` | `boolean` | No | `false` | Usa `color.error` en lugar de `color.brand` y se anuncia como destructivo |
| `isLoading` | `boolean` | No | `false` | Muestra el indicador y bloquea el toque |
| `isDisabled` | `boolean` | No | `false` | Deshabilita el botón |
| `disabledReason` | `string` | No | — | Motivo por el que está deshabilitado; se anuncia al lector de pantalla |
| `fullWidth` | `boolean` | No | `true` | Ocupa todo el ancho disponible; en la fila de la agenda va en `false` |

> `isDestructive` **no** ejecuta la acción de una vez: la pantalla que lo usa abre antes un diálogo
> de confirmación (cancelar) o de motivo (rechazar). El componente solo marca el peligro.

---

## Estados visuales

| Estado | Apariencia |
|--------|------------|
| Default | Fondo `color.surface`, borde de 1 px y texto en `color.brand` (o `color.error` si `isDestructive`), radio `radius.sm`, alto 48 |
| Pressed | Fondo `color.brandSoft` (o el color del texto al 8% de opacidad si es destructivo) |
| Disabled | Borde y texto en `color.disabled` |
| Loading | Indicador centrado del color del texto; el `label` reserva el ancho para que el botón no cambie de tamaño |
| Error | No aplica: el error lo muestra la pantalla, no el botón |

---

## Tokens que usa

- Color: `color.brand`, `color.error`, `color.brandSoft`, `color.surface`, `color.disabled`
- Espaciado: `space.lg` horizontal, `space.md` vertical
- Radio: `radius.sm`
- Tipografía: `text.label` en peso 600

---

## Accesibilidad

- Rol `button`; se anuncia con su `label`. Si `isDestructive`, el `label` dice la consecuencia
  ("Cancelar cita", no "Cancelar"), porque el color rojo no llega al lector de pantalla.
- Alto mínimo de 48 dp.
- En `disabled` se anuncia el `disabledReason` después de la etiqueta (por ejemplo, sin conexión no
  se puede cancelar).
- Contraste sobre `color.surface`: `brand` 5,6:1 y `error` 7,1:1 en tema claro. Cumple AA.

---

## Ejemplo de uso

```tsx
<BotonSecundario
  label={t('cita.boton.cancelar')}
  onPress={openCancelDialog}
  isDestructive
  isDisabled={isOffline}
  disabledReason={isOffline ? t('cita.error.sinConexionCancelar') : undefined}
/>
```
