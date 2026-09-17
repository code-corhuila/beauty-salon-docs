# 02 — Code & UI

> **¿Qué es esto?** Los estándares de código y las reglas de interfaz: cómo se escribe el código y
> cómo se construye, se estiliza, se hace accesible y se traduce la interfaz.

## Por qué existe esta sección

La coherencia a nivel de código y de UI es lo que hace que una app se sienta un solo producto. Estas
reglas se hacen cumplir en la revisión y en el linter.

---

## Documentos de esta sección

| Archivo | Para qué sirve |
|---------|----------------|
| [coding-standards.md](./coding-standards.md) | Nombres, inmutabilidad, manejo de errores, asincronía |
| [design-system.md](./design-system.md) | Tokens, componentes y temas |
| [accessibility.md](./accessibility.md) | Reglas de accesibilidad alineadas con WCAG |
| [i18n.md](./i18n.md) | Localización y reglas de RTL |
| [components/](./components/) | Un documento por componente compartido |
| [_template-component.md](./_template-component.md) | Plantilla para documentar un componente |

---

## Componentes documentados

| Componente | Documento | Usado en |
|------------|-----------|----------|
| BotonPrimario | [boton-primario.md](./components/boton-primario.md) | Login, registro, detalle de servicio, agendar, formulario de servicio |
| CampoFormulario | [campo-formulario.md](./components/campo-formulario.md) | Login, registro, formulario de servicio |
| TarjetaServicio | [tarjeta-servicio.md](./components/tarjeta-servicio.md) | Catálogo, servicios del negocio |
| SelectorHorario | [selector-horario.md](./components/selector-horario.md) | Agendar cita |
| EstadoVacio | [estado-vacio.md](./components/estado-vacio.md) | Catálogo, mis citas, servicios del negocio, agenda |

> Un componente entra a `shared/` cuando lo usan **dos o más features**. Lo que use una sola feature
> se queda en su carpeta `presentation/`, aunque se vea reutilizable.

---

## Correlaciones con otras secciones

| Esta sección alimenta a... | Por qué |
|----------------------------|---------|
| `01-architecture/` | Los estándares aplican dentro de los límites de capa definidos allí |
| `03-api-and-data/` | El tipo `Result` y los errores de dominio definidos aquí son los que la capa de datos produce |
| `04-quality/` | Las reglas de linter y accesibilidad se verifican en CI |

---

## Preguntas que esta sección debe responder

- ¿Cómo se nombra, se estructura y se manejan los errores en el código? → [coding-standards.md](./coding-standards.md)
- ¿De dónde salen los colores, el espaciado y la tipografía? → [design-system.md](./design-system.md)
- ¿Cómo se garantiza que la app sea accesible? → [accessibility.md](./accessibility.md)
- ¿Cómo se traduce el texto de la interfaz? → [i18n.md](./i18n.md)
