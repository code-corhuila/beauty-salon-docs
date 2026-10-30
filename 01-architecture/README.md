# 01 — Architecture

> **¿Qué es esto?** Cómo está organizada la app: estructura de carpetas, capas, manejo de estado,
> navegación y el registro de decisiones de arquitectura.

## Por qué existe esta sección

La arquitectura es el conjunto de restricciones que mantienen el código coherente mientras crece.
Se decide una vez, se escribe, y se hace cumplir en la revisión.

---

## Documentos de esta sección

| Archivo | Para qué sirve |
|---------|----------------|
| [project-structure.md](./project-structure.md) | Estructura de carpetas por feature y reglas de módulos |
| [layers-and-state.md](./layers-and-state.md) | Capas Presentation/Domain/Data y patrón de estado |
| [navigation.md](./navigation.md) | Modelo de rutas y reglas de navegación |
| [decisions/](./decisions/) | Registros de decisiones de arquitectura (ADRs) |
| [plan-implementacion-login-catalogo.md](./plan-implementacion-login-catalogo.md) | Plan de trabajo para construir `auth` y `catalog` en `beauty-salon-app` (ver [ADR-009](./decisions/records/ADR-009-backend-repo-and-stack.md) y [ADR-011](./decisions/records/ADR-011-cuatro-repositorios.md)) |
| [flows/](./flows/) | Diagramas de apoyo: BPMN anotado, mapa de navegación y cadena de trazabilidad |
| [mockups/](./mockups/) | Las diez pantallas dibujadas, sus estados clave, los componentes y los tokens |
| [features/](./features/) | Un documento por feature |
| [screens/](./screens/) | Un documento por pantalla |
| [_template-feature.md](./_template-feature.md) | Plantilla para documentar una feature |
| [_template-screen.md](./_template-screen.md) | Plantilla para especificar una pantalla |

---

## Features documentadas

| Feature | Documento | Pantallas | Sprint |
|---------|-----------|-----------|--------|
| Autenticación y sesión | [auth.md](./features/auth.md) | 2 | 1 (habilitadora) |
| Catálogo de servicios | [catalog.md](./features/catalog.md) | 2 | 2 |
| Agendamiento | [booking.md](./features/booking.md) | 1 | 2 |
| Mis citas | [appointments.md](./features/appointments.md) | 2 | 3 |
| Gestión del negocio | [business.md](./features/business.md) | 3 | 1 y 3 |

## Pantallas documentadas

| Pantalla | Documento | Ruta | Feature |
|----------|-----------|------|---------|
| LoginScreen | [login.md](./screens/login.md) | `/login` | auth |
| SignUpScreen | [registro.md](./screens/registro.md) | `/register` | auth |
| AccountScreen | [cuenta.md](./screens/cuenta.md) | `/account` | auth |
| CatalogScreen | [catalogo.md](./screens/catalogo.md) | `/services` | catalog |
| ServiceDetailScreen | [detalle-servicio.md](./screens/detalle-servicio.md) | `/service/:serviceId` | catalog |
| BookAppointmentScreen | [agendar-cita.md](./screens/agendar-cita.md) | `/book/:serviceId` | booking |
| MyAppointmentsScreen | [mis-citas.md](./screens/mis-citas.md) | `/my-appointments` | appointments |
| AppointmentDetailScreen | [detalle-cita.md](./screens/detalle-cita.md) | `/appointment/:appointmentId` | appointments |
| BusinessServicesScreen | [negocio-servicios.md](./screens/negocio-servicios.md) | `/business/services` | business |
| ServiceFormScreen | [negocio-servicio-form.md](./screens/negocio-servicio-form.md) | `/business/service/new` | business |
| BusinessProfessionalsScreen | [negocio-profesionales.md](./screens/negocio-profesionales.md) | `/business/professionals` | business |
| BusinessAgendaScreen | [business-agenda.md](./screens/negocio-agenda.md) | `/business/agenda` | business |

## Diagramas de apoyo

[`flows/manicita-flujos.html`](./flows/manicita-flujos.html) — se abre con doble clic, sin
dependencias externas. Contiene tres diagramas:

1. **BPMN de agendamiento anotado con las vistas** — el proceso de negocio con la ruta y el endpoint
   pegados a cada tarea. Si una tarea no tiene ruta, falta una pantalla; si no tiene endpoint, falta
   un contrato.
2. **Mapa de navegación** — los tres navegadores, las diez rutas y las redirecciones de las guardas.
3. **Cadena de trazabilidad** — pantalla → caso de uso → endpoint → entidad local, agrupada por feature.

> Los diagramas se derivan de los documentos, no al revés. Si un diagrama y un documento no
> coinciden, manda el documento.

---

> Estas diez filas son exactamente las diez rutas del registro de
> [navigation.md](./navigation.md). Si alguna vez dejan de coincidir, la incoherente es esta tabla.

## Mockups

[`mockups/manicita-mockups.html`](./mockups/manicita-mockups.html) — se abre con doble clic, sin
dependencias externas, igual que el documento de flujos. Contiene:

1. **Las diez pantallas** en marco de teléfono, agrupadas por los dos lados del marketplace, cada
   una con su nombre de pantalla y su ruta.
2. **Cuatro estados que hay que dibujar**: el catálogo vacío del primer día, el onboarding del
   negocio sin servicios, el cupo tomado al confirmar y la lista de citas sin conexión.
3. **Una lámina en tema oscuro**, para comprobar que los dos temas salen de los mismos tokens.
4. **Los cinco primeros componentes compartidos** con sus estados visuales. `BotonSecundario` y
   `DistintivoEstadoCita`, documentados el 2026-10-07, todavía no están dibujados en la lámina.
5. **Los tokens**: los once colores con su hex y sus contrastes, la escala tipográfica y la de
   espaciado.

> Los mockups se derivan de [`screens/`](./screens/) y de
> [`design-system.md`](../02-code-and-ui/design-system.md), no al revés. Si un mockup y un documento
> no coinciden, manda el documento.

## ADRs

| # | Título | Estado |
|---|--------|--------|
| [ADR-001](./decisions/records/ADR-001-state-management-pattern.md) | Patrón de manejo de estado | Superseded by ADR-006 |
| [ADR-002](./decisions/records/ADR-002-mobile-stack.md) | Stack de desarrollo móvil | Superseded by ADR-005 |
| [ADR-003](./decisions/records/ADR-003-local-storage.md) | Almacenamiento local | Superseded by ADR-007 |
| [ADR-004](./decisions/records/ADR-004-dependency-injection.md) | Inyección de dependencias | Superseded by ADR-008 |
| [ADR-005](./decisions/records/ADR-005-mobile-stack-ionic-capacitor.md) | Stack de desarrollo móvil (revisión: Ionic + Capacitor, solo Android) | Accepted |
| [ADR-006](./decisions/records/ADR-006-state-management-pattern.md) | Patrón de manejo de estado (reafirmación) | Accepted |
| [ADR-007](./decisions/records/ADR-007-local-storage-capacitor.md) | Almacenamiento local (revisión: SQLite vía Capacitor) | Accepted |
| [ADR-008](./decisions/records/ADR-008-dependency-injection.md) | Inyección de dependencias (reafirmación) | Accepted |

---

## Cómo se trabaja aquí

1. Se leen y se adoptan `project-structure.md` y `layers-and-state.md`.
2. Cada elección significativa (librería de estado, base de datos local, inyección de dependencias)
   se registra como ADR en `decisions/`.
3. Por cada feature se copia `_template-feature.md` a `features/<feature>.md` y se llena.
4. Por cada pantalla del documento de feature se copia `_template-screen.md` a `screens/<pantalla>.md`.
5. Se agrega la fila correspondiente en las tablas de arriba.

---

## Correlaciones con otras secciones

| Esta sección alimenta a... | Por qué |
|----------------------------|---------|
| `02-code-and-ui/` | Los límites entre capas definen dónde vive la UI y dónde la lógica |
| `03-api-and-data/` | La capa de datos implementa las reglas de red y persistencia |
| `04-quality/` | Las capas definen qué se prueba con pruebas unitarias y qué con pruebas de UI |

---

## Preguntas que esta sección debe responder

- ¿Dónde va el código de una feature nueva? → [project-structure.md](./project-structure.md)
- ¿Qué capa puede depender de cuál? → [layers-and-state.md](./layers-and-state.md)
- ¿Qué patrón único de estado usa la app? → [ADR-006](./decisions/records/ADR-006-state-management-pattern.md)
- ¿Cómo navegan las pantallas y dónde quedó registrada esa decisión? → [navigation.md](./navigation.md)
