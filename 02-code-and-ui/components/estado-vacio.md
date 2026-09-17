# Componente — EstadoVacio

- **Ubicación:** `src/shared/components/EstadoVacio.tsx`
- **Estado:** Draft

---

## Propósito

Ocupar la pantalla cuando no hay datos, explicando **por qué** está vacío y **qué hacer** para
llenarlo. Nunca solo un "sin resultados".

En ManiCita el vacío no es un caso raro: es el primer día de la app, cuando ningún negocio ha
publicado nada, y es la pantalla de una manicurista recién registrada. Por eso el estado vacío es un
componente de primera clase y no una etiqueta de texto centrada.

---

## Props

| Prop | Tipo | Requerido | Por defecto | Qué controla |
|------|------|-----------|-------------|--------------|
| `title` | `string` | Sí | — | Qué pasa, en una frase |
| `message` | `string` | Sí | — | Por qué pasa y qué se puede hacer |
| `actionLabel` | `string` | No | — | Texto de la acción de salida |
| `onAction` | `() => void` | No | — | Acción de salida |
| `illustration` | `'catalogo' \| 'citas' \| 'negocio'` | No | `'catalogo'` | Ilustración según el contexto |

> Si se pasa `actionLabel` hay que pasar `onAction`. Un estado vacío sin salida deja a la usuaria
> mirando una pantalla que no la lleva a ninguna parte.

---

## Estados visuales

| Estado | Apariencia |
|--------|------------|
| Default | Ilustración, título en `text.title`, mensaje en `text.body` centrado, acción abajo |
| Pressed | Solo aplica al botón de acción |
| Disabled | No aplica |
| Loading | No aplica: el vacío se muestra cuando la carga ya terminó |
| Error | No aplica: el error tiene su propio tratamiento, con reintentar |

> **Vacío y error no son el mismo estado.** Vacío significa que la respuesta llegó bien y no traía
> nada; error significa que no se pudo saber. Mostrar "no hay servicios" cuando en realidad falló la
> red es mentirle a la usuaria.

---

## Tokens que usa

- Color: `color.textPrimary`, `color.textSecondary`, `color.brandSoft` de fondo de la ilustración
- Espaciado: `space.xl` alrededor, `space.md` entre elementos
- Tipografía: `text.title`, `text.body`

---

## Accesibilidad

- Título y mensaje se anuncian juntos al entrar a la pantalla.
- La ilustración se marca como decorativa.
- El botón de acción cumple el área táctil mínima y el contraste AA.
- El bloque completo sigue siendo legible con la fuente más grande del sistema, con scroll si hace
  falta.

---

## Ejemplo de uso

```tsx
<EstadoVacio
  title={t('catalogo.vacio.titulo')}
  message={t('catalogo.vacio.mensaje')}
  actionLabel={t('catalogo.vacio.accion')}
  onAction={handleSharePress}
  illustration="catalogo"
/>
```
