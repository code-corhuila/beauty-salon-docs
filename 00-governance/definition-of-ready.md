# Definition of Ready (DoR)

Una historia de usuario entra al sprint **solo cuando todo esto es cierto**:

- [ ] El valor de usuario está escrito (Como / Quiero / Para).
- [ ] Los criterios de aceptación están escritos y son verificables (Dado / Cuando / Entonces).
- [ ] Si toca UI, enlaza su pantalla especificada en `01-architecture/screens/`.
- [ ] Si llama al backend, el contrato de API está disponible o diseñado (stubbed).
- [ ] Los estados offline, de error y vacío están descritos.
- [ ] Las dependencias con otras historias están identificadas.
- [ ] La historia está estimada.
- [ ] La historia cabe en un sprint (si no cabe, se parte).

> Si alguna casilla queda sin marcar, la historia se queda en refinamiento: no entra al sprint.

---

## Cómo se cumple cada check en ManiCita

Ningún check se borró. Los que no aplican tal cual en un proyecto sin backend ni equipo de diseño
se cumplen así:

| Check | Cómo se cumple aquí |
|-------|---------------------|
| Referencia de UI | No hay diseñador ni Figma. La referencia es el documento de pantalla en `01-architecture/screens/` —que declara regiones, estados y acciones— dibujado en `01-architecture/mockups/manicita-mockups.html` con los tokens reales. Un boceto a mano fotografiado cuenta como apoyo, no como reemplazo |
| Contrato de API | **No existe backend real.** El contrato está diseñado en `03-api-and-data/endpoints/`, un documento por endpoint con request, response y tabla de errores. La DoR admite explícitamente el contrato stubbed |
| Estados offline / error / vacío | Salen de la estrategia por feature declarada en `03-api-and-data/offline-sync.md` y de la tabla de estados del documento de pantalla |
| Estimada por el equipo | La estiman las dos personas del equipo contra la historia de calibración (catálogo = 3 puntos), y se revisa con el docente en el refinamiento |

## Ejemplo de historia lista

**HU-004 — Agendar una cita**

- **Como** clienta, **quiero** escoger una hora libre de la profesional, **para** dejar mi cita
  confirmada sin escribir por WhatsApp.
- **Dado** que abro un servicio publicado y elijo una fecha, **cuando** el sistema calcula los cupos,
  **entonces** solo veo las horas que la profesional tiene realmente libres.
- **Dado** que confirmo una hora que otra clienta acaba de tomar, **cuando** el servidor rechaza el
  cupo, **entonces** la app me avisa y me vuelve a mostrar la disponibilidad actualizada.
- Pantalla: [`agendar-cita.md`](../01-architecture/screens/agendar-cita.md) ·
  Endpoints: [`disponibilidad`](../03-api-and-data/endpoints/booking-availability.md),
  [`crear cita`](../03-api-and-data/endpoints/booking-create-appointment.md)
- Estados: loading (consultando cupos), vacío (no hay cupos ese día), error (cupo tomado), offline
  (no se puede agendar sin conexión, la feature es online-only).
- Depende de: HU-001 y HU-003. Estimación: 8 puntos.
