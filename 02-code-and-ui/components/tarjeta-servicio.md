# Componente — TarjetaServicio

- **Ubicación:** `src/shared/components/TarjetaServicio.tsx`
- **Estado:** Draft

---

## Propósito

Mostrar un servicio en una lista con lo que la clienta necesita para decidir de un vistazo: qué es,
cuánto vale, cuánto dura y quién lo presta. Se usa en el catálogo de la clienta y en la lista de
servicios del negocio.

Es el componente que más se repite en pantalla, así que su rendimiento y su accesibilidad importan
más que los de cualquier otro.

---

## Props

| Prop | Tipo | Requerido | Por defecto | Qué controla |
|------|------|-----------|-------------|--------------|
| `name` | `string` | Sí | — | Nombre del servicio |
| `priceCop` | `number` | Sí | — | Precio en pesos, se formatea como moneda dentro del componente |
| `durationMinutes` | `number` | Sí | — | Duración, se formatea como texto legible |
| `salonName` | `string` | Sí | — | Nombre del salón o de la profesional |
| `imageUrl` | `string` | No | — | Foto del servicio; sin ella se usa un fondo con `color.brandSoft` |
| `badge` | `'publicado' \| 'pausado'` | No | — | Solo en la vista del negocio |
| `onPress` | `() => void` | Sí | — | Abrir el detalle |

> La tarjeta recibe datos ya listos (`priceCop`, `durationMinutes`) y **no consulta nada**. El
> formateo a moneda y a texto de duración sí ocurre adentro, porque es presentación pura.

---

## Estados visuales

| Estado | Apariencia |
|--------|------------|
| Default | Fondo `color.surface`, borde `color.border`, radio `radius.md`, sombra `elevation.card` |
| Pressed | Escala al 98% y sombra reducida |
| Disabled | No aplica: una tarjeta pausada se muestra con su distintivo, no deshabilitada |
| Loading | El esqueleto es un componente aparte, `TarjetaServicioSkeleton`, con la misma altura para que la lista no salte |
| Error | No aplica |

---

## Tokens que usa

- Color: `color.surface`, `color.border`, `color.brand` en el precio, `color.textSecondary` en los
  metadatos, `color.brandSoft` como reemplazo de la foto
- Espaciado: `space.md` interno, `space.sm` entre líneas
- Radio: `radius.md`, `radius.pill` en el distintivo
- Tipografía: `text.label` en el nombre, `text.caption` en los metadatos

---

## Accesibilidad

- La tarjeta se anuncia como **una sola unidad**, no como cuatro textos sueltos: "Manicure
  semipermanente, 45 mil pesos, 60 minutos, Salón Nails Neiva".
- Rol `button`, porque toda la tarjeta es tocable.
- La imagen se marca como decorativa: su información ya está en la etiqueta de la tarjeta.
- El distintivo de pausado lleva texto, no solo un color distinto.
- Con la fuente más grande del sistema la tarjeta **crece en alto**; nunca recorta el nombre.

---

## Ejemplo de uso

```tsx
<TarjetaServicio
  name={service.name}
  priceCop={service.priceCop}
  durationMinutes={service.durationMinutes}
  salonName={service.salonName}
  imageUrl={service.imageUrl}
  onPress={() => navigation.navigate('ServiceDetail', { serviceId: service.id })}
/>
```
