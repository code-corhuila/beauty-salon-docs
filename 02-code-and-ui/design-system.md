# Design System

Todos los valores visuales viven como **tokens** en `src/core/theme/`. Las pantallas referencian
tokens, nunca valores crudos.

## Color

| Token | Claro | Oscuro | Uso |
|-------|-------|--------|-----|
| `color.brand` | `#A8456B` | `#E8A0BC` | Botón primario, elementos seleccionados, precio |
| `color.brandSoft` | `#F7E8EE` | `#3A2630` | Fondo de chips activos y de avisos de marca |
| `color.background` | `#FBF7F8` | `#0F0C0E` | Fondo de pantalla |
| `color.surface` | `#FFFFFF` | `#1A1518` | Tarjetas, campos, hojas modales |
| `color.textPrimary` | `#1F1A1D` | `#F5EFF2` | Títulos y cuerpo |
| `color.textSecondary` | `#6B5F65` | `#B7A9AF` | Metadatos: duración, dirección |
| `color.border` | `#E7DDE1` | `#2E262A` | Bordes de tarjeta y separadores |
| `color.success` | `#2F6B4F` | `#7FBF9E` | Cita confirmada |
| `color.warning` | `#8A5C00` | `#E2B25C` | Cita pendiente |
| `color.error` | `#A32B2B` | `#F09A9A` | Errores y cita rechazada |
| `color.disabled` | `#9A9096` | `#6E646A` | Texto y controles deshabilitados |

Verificación de contraste hecha sobre los pares que de verdad se usan:

| Par | Ratio | Cumple |
|-----|-------|--------|
| `textPrimary` sobre `background` (claro) | ~15:1 | AA y AAA |
| `brand` sobre `surface` blanco | ~5.6:1 | AA en texto normal |
| Blanco sobre `brand` (botón primario) | ~5.6:1 | AA en texto normal |
| `textSecondary` sobre `background` | ~5.4:1 | AA en texto normal |
| `disabled` sobre `surface` | ~3.1:1 | Solo para texto grande e íconos, nunca para cuerpo |

> El rosa de marca se eligió oscuro a propósito. El rosa pastel que uno esperaría en una app de
> manicure no alcanza 4.5:1 sobre blanco, así que serviría de fondo pero no de texto ni de botón.
> El pastel quedó como `brandSoft`, que solo se usa detrás de texto oscuro.

## Espaciado

Escala fija de 4: `space.xs 4` · `space.sm 8` · `space.md 12` · `space.lg 16` · `space.xl 24` ·
`space.xxl 32`. No existen valores intermedios: si algo necesita 14, se usa 12 o 16.

## Radio

`radius.sm 8` (campos, chips) · `radius.md 12` (tarjetas) · `radius.pill 999` (chips de filtro y
distintivos de estado).

## Tipografía

| Token | Tamaño / interlineado | Peso | Uso |
|-------|-----------------------|------|-----|
| `text.display` | 28 / 34 | 700 | Título de pantalla |
| `text.title` | 20 / 26 | 600 | Nombre del servicio en el detalle |
| `text.body` | 16 / 24 | 400 | Cuerpo, descripciones |
| `text.label` | 14 / 20 | 500 | Etiquetas de campo, precio en la tarjeta |
| `text.caption` | 12 / 16 | 400 | Metadatos y ayudas |

Los tamaños son el punto de partida, no un techo: todos escalan con el ajuste de fuente del sistema.
Nada de `allowFontScaling={false}`.

## Elevación

`elevation.card` (sombra sutil, borde de 1px en tema oscuro donde la sombra no se ve) y
`elevation.modal`.

## Reglas

- Cero colores, tamaños o fuentes quemados en las pantallas: todo sale de tokens.
- Las pantallas se arman con la librería de componentes de `src/shared/components/`. Nada de
  componentes estilizados de un solo uso.
- Los temas claro y oscuro salen del **mismo** conjunto de tokens: se cambian los valores, no los
  componentes. Un componente que consulta si el tema es oscuro para decidir un color está mal escrito.
- Se respetan las convenciones de plataforma: áreas seguras, gestos nativos, controles propios de
  cada sistema.

## Componentes

Cada componente compartido declara props, estados visuales y contrato de accesibilidad, y se
documenta con [`_template-component.md`](./_template-component.md).

| Componente | Documento | Usado en |
|------------|-----------|----------|
| BotonPrimario | [boton-primario.md](./components/boton-primario.md) | Todas las pantallas con acción principal |
| CampoFormulario | [campo-formulario.md](./components/campo-formulario.md) | Login, registro, formulario de servicio |
| TarjetaServicio | [tarjeta-servicio.md](./components/tarjeta-servicio.md) | Catálogo, servicios del negocio |
| SelectorHorario | [selector-horario.md](./components/selector-horario.md) | Agendar cita |
| EstadoVacio | [estado-vacio.md](./components/estado-vacio.md) | Catálogo, mis citas, servicios del negocio, agenda |
| BotonSecundario | [boton-secundario.md](./components/boton-secundario.md) | Detalle de la cita, agenda del negocio |
| DistintivoEstadoCita | [distintivo-estado-cita.md](./components/distintivo-estado-cita.md) | Mis citas, detalle de la cita, agenda del negocio |

Un componente se encarga de estilo y disposición. **No tiene lógica de negocio ni pide datos.**
