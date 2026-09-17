# Componente — BotonPrimario

- **Ubicación:** `src/shared/components/BotonPrimario.tsx`
- **Estado:** Draft

---

## Propósito

La acción principal de una pantalla: entrar, agendar, publicar, confirmar. **Hay uno solo por
pantalla.** Si una pantalla parece necesitar dos botones primarios, es que tiene dos propósitos y
hay que revisar el diseño, no agregar otro botón.

Para acciones secundarias o destructivas se usa `BotonSecundario`, no una variante de este.

---

## Props

| Prop | Tipo | Requerido | Por defecto | Qué controla |
|------|------|-----------|-------------|--------------|
| `label` | `string` | Sí | — | Texto del botón, ya traducido por quien lo usa |
| `onPress` | `() => void` | Sí | — | Acción al tocar |
| `isLoading` | `boolean` | No | `false` | Muestra el indicador y bloquea el toque |
| `isDisabled` | `boolean` | No | `false` | Deshabilita el botón |
| `disabledReason` | `string` | No | — | Motivo por el que está deshabilitado; se anuncia al lector de pantalla |
| `fullWidth` | `boolean` | No | `true` | Ocupa todo el ancho disponible |

> `disabledReason` no es opcional en la práctica: es obligatorio cada vez que `isDisabled` es true
> por una causa que la usuaria no puede deducir mirando la pantalla, como la falta de conexión.

---

## Estados visuales

| Estado | Apariencia |
|--------|------------|
| Default | Fondo `color.brand`, texto blanco, radio `radius.sm`, alto 48 |
| Pressed | Fondo `color.brand` al 85% de opacidad |
| Disabled | Fondo `color.disabled`, texto blanco, sin sombra |
| Loading | Indicador centrado del color del texto; el `label` se mantiene reservando el ancho para que el botón no cambie de tamaño |
| Error | No aplica: el error lo muestra la pantalla, no el botón |

---

## Tokens que usa

- Color: `color.brand`, `color.disabled`, texto blanco fijo sobre marca
- Espaciado: `space.lg` horizontal, `space.md` vertical
- Radio: `radius.sm`
- Tipografía: `text.label` en peso 600

---

## Accesibilidad

- Rol `button`; se anuncia con su `label`.
- Alto mínimo de 48 dp, que cubre el mínimo de ambas plataformas.
- En `loading` se anuncia como ocupado y no acepta toques repetidos.
- En `disabled` se anuncia el `disabledReason` después de la etiqueta.
- Contraste blanco sobre `color.brand`: ~5.6:1, cumple AA.

---

## Ejemplo de uso

```tsx
<BotonPrimario
  label={t('agendar.boton.confirmar')}
  onPress={handleConfirmPress}
  isLoading={status === 'submitting'}
  isDisabled={isOffline || selectedSlot === null}
  disabledReason={isOffline ? t('agendar.error.sinConexion') : undefined}
/>
```
