# Feature — Gestión del negocio

- **Responsables:** Lilly Signey Puentes Rincon y Lizeth Caicedo
- **Estado:** Planned
- **Historias relacionadas:** HU-001 publicar el servicio, HU-002 definir el horario (Sprint 1),
  HU-006 agenda del negocio (Sprint 3)

---

## Propósito

Permitir que la manicurista publique sus servicios con precio, duración, profesional y horario, y
que reciba las citas ya organizadas. **Es la mitad del MVP, no una función secundaria**: sin
servicios publicados el catálogo de la clienta abre vacío y no hay nada que agendar.

Por eso el Sprint 1 completo es de esta feature: al terminarlo hay algo real que ponerle en las manos
a una manicurista de Neiva.

---

## Pantallas

| Pantalla | Ruta | Propósito |
|----------|------|-----------|
| [BusinessServicesScreen](../screens/negocio-servicios.md) | `/negocio/servicios` | Listar los servicios propios, publicarlos o pausarlos |
| [ServiceFormScreen](../screens/negocio-servicio-form.md) | `/negocio/servicio/nuevo` | Crear o editar un servicio con su profesional y su horario |
| [BusinessAgendaScreen](../screens/negocio-agenda.md) | `/negocio/agenda` | Ver las citas recibidas por día y confirmarlas o rechazarlas |

---

## Estado

- **Patrón:** Store con Zustand ([ADR-006](../decisions/records/ADR-006-state-management-pattern.md))
- **Objetos de estado:** `BusinessServicesState`, `ServiceFormState`, `BusinessAgendaState`
- **Transiciones clave:**
  - Formulario: `editing` a `validating` a `submitting` a `saved` o `error`. La validación es local y
    ocurre antes de enviar; los errores se muestran campo por campo.
  - Pausar un servicio es optimista en la lista y se revierte si el servidor falla.

---

## Datos

- **Casos de uso:** `createService`, `pauseService`, `setSchedule`, `getBusinessAgenda`,
  `respondAppointment`
- **Repositorios:** `BusinessRepository`, `AppointmentRepository`
- **Endpoints:** [`POST /v1/negocio/servicios`](../../03-api-and-data/endpoints/negocio-crear-servicio.md),
  [`PATCH /v1/negocio/servicios/{id}/estado`](../../03-api-and-data/endpoints/negocio-pausar-servicio.md),
  [`GET /v1/negocio/agenda`](../../03-api-and-data/endpoints/negocio-agenda.md),
  [`PATCH /v1/negocio/citas/{id}/responder`](../../03-api-and-data/endpoints/negocio-responder-cita.md)
- **Persistencia local:** ninguna. La agenda del negocio **no se cachea**, porque contiene nombre y
  celular de las clientas: es el dato más sensible de la app y no tiene por qué quedar en reposo en
  el dispositivo. Ver [`security-rules.md`](../../00-governance/security-rules.md).
- **Estrategia offline:** **online-only** en toda la feature.

---

## Reglas de negocio que implementa

- El horario se define **por profesional y por día de la semana**, no por servicio. Un servicio
  hereda el horario de la profesional que lo atiende.
- **Pausar no es borrar.** Un servicio pausado sale del catálogo, pero las citas ya agendadas se
  respetan y siguen apareciendo en la agenda.
- No se puede publicar un servicio sin precio, sin duración, sin profesional asignada o sin horario:
  faltando cualquiera de los cuatro, los cupos no se pueden calcular y el servicio sería inagendable.
- La duración es el campo del que salen los cupos, así que se pide en minutos y se valida como
  múltiplo de 15.

---

## Casos borde y estados

- [x] Loading — cargando servicios o agenda
- [x] Empty — negocio recién registrado sin servicios: la pantalla es una invitación a crear el
      primero, y es la pantalla más importante del onboarding del lado del negocio
- [x] Empty en la agenda — todavía no le han agendado nada
- [x] Error / reintento — falla el guardado: el formulario **conserva lo escrito**, nunca se limpia
- [x] Offline — no se puede publicar ni responder citas sin conexión; se avisa antes de que la
      manicurista llene el formulario completo, no después
- [x] Permiso denegado — sesión de clienta en una ruta de negocio: la guarda redirige al catálogo

---

## Decisiones

- [ADR-006](../decisions/records/ADR-006-state-management-pattern.md) — patrón de estado
- [ADR-007](../decisions/records/ADR-007-local-storage-capacitor.md) — por qué esta feature no cachea nada

---

## Pruebas

- **Unitarias:** `createService` rechazando cada campo obligatorio faltante y duraciones que no son
  múltiplo de 15; `pauseService` verificando que las citas existentes sobreviven; `setSchedule` con
  horarios que se solapan.
- **De componente:** `ServiceFormScreen` conservando los datos tras un error de red;
  `BusinessServicesScreen` en estado vacío.
- **Integración:** publicar un servicio y verificar que aparece en el catálogo de la clienta con
  cupos calculados.
