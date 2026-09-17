# Componente — CampoFormulario

- **Ubicación:** `src/shared/components/CampoFormulario.tsx`
- **Estado:** Draft

---

## Propósito

Un campo de texto con etiqueta, ayuda y error. Es el ladrillo de los tres formularios de la app:
login, registro y creación de servicio.

Existe para que el error se muestre siempre igual y siempre en el mismo lugar. Cuando cada formulario
inventa su forma de mostrar errores, la usuaria tiene que aprender la app tres veces.

---

## Props

| Prop | Tipo | Requerido | Por defecto | Qué controla |
|------|------|-----------|-------------|--------------|
| `label` | `string` | Sí | — | Etiqueta **visible** sobre el campo |
| `value` | `string` | Sí | — | Valor actual |
| `onChangeText` | `(text: string) => void` | Sí | — | Cambio de texto |
| `error` | `string` | No | — | Mensaje de error bajo el campo |
| `helper` | `string` | No | — | Ayuda bajo el campo, se oculta cuando hay error |
| `keyboardKind` | `'texto' \| 'correo' \| 'telefono' \| 'numero' \| 'clave'` | No | `'texto'` | Teclado y comportamiento del campo |
| `isDisabled` | `boolean` | No | `false` | Campo no editable |

> La etiqueta es **visible y obligatoria**. No se admite usar solo el texto de sugerencia dentro del
> campo: desaparece apenas la usuaria escribe, y en un formulario largo como el de crear servicio
> deja a cualquiera sin saber qué estaba llenando.

---

## Estados visuales

| Estado | Apariencia |
|--------|------------|
| Default | Borde `color.border`, fondo `color.surface` |
| Focused | Borde `color.brand` de 2px |
| Disabled | Fondo `color.background`, texto `color.disabled` |
| Loading | No aplica: el que carga es el formulario, no el campo |
| Error | Borde `color.error`, mensaje en `color.error` con ícono de alerta a la izquierda |

---

## Tokens que usa

- Color: `color.border`, `color.brand`, `color.surface`, `color.error`, `color.textPrimary`,
  `color.textSecondary`
- Espaciado: `space.md` interno, `space.xs` entre campo y mensaje
- Radio: `radius.sm`
- Tipografía: `text.label` en la etiqueta, `text.body` en el valor, `text.caption` en ayuda y error

---

## Accesibilidad

- La etiqueta está asociada al campo: el lector de pantalla anuncia etiqueta, valor y error juntos.
- El error se marca con `accessibilityInvalid` y se anuncia al aparecer.
- El error no se comunica solo con el borde rojo: lleva ícono y texto.
- `keyboardKind: 'clave'` incluye el botón de mostrar u ocultar, que anuncia su estado y cumple el
  área táctil mínima.
- El campo enfocado nunca queda tapado por el teclado: `android:windowSoftInputMode="adjustResize"`
  (config por defecto de Capacitor) deja que el WebView redimensione el contenido.

---

## Ejemplo de uso

```tsx
<CampoFormulario
  label={t('negocio.servicio.duracion.label')}
  value={form.durationMinutes}
  onChangeText={handleDurationChange}
  keyboardKind="numero"
  helper={t('negocio.servicio.duracion.ayuda')}
  error={errors.durationMinutes}
/>
```
