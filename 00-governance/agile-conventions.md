# Convenciones ágiles

La metodología del proyecto es **Scrum**, con una adaptación honesta: ManiCita la desarrollan
**dos personas** durante un semestre. Las ceremonias se conservan porque cumplen una función
real, pero se ajustan a un equipo de dos en vez de simular un equipo grande que no existe.

## Cadencia

Sprints de **2 semanas**. El MVP está planificado en **3 sprints**:

| Sprint | Historias | Resultado |
|--------|-----------|-----------|
| Sprint 1 — la oferta | HU-001 publicar servicio, HU-002 definir horario | Una manicurista real puede cargar sus servicios |
| Sprint 2 — la demanda | HU-003 explorar catálogo, HU-004 agendar cita | El ciclo se cierra: se agenda sin WhatsApp |
| Sprint 3 — la gestión | HU-005 mis citas, HU-006 agenda del negocio | La app se usa todos los días, no una sola vez |

| Ceremonia | Frecuencia | Duración | Salida |
|-----------|------------|----------|--------|
| Planeación del sprint | Al inicio de cada sprint | 1 h | Sprint backlog comprometido |
| Bitácora diaria (reemplaza el standup) | Diaria | 5 min, por escrito | Bloqueos anotados en el issue |
| Refinamiento del backlog | Semanal | 45 min | Historias estimadas y en estado Ready |
| Revisión del sprint | Fin de sprint | 45 min | Demo en dispositivo físico ante el docente y la manicurista aliada |
| Retrospectiva | Fin de sprint | 30 min | Acciones concretas registradas en `retros/sprint-NN.md` |

> **Por qué la bitácora diaria es por escrito y no una reunión:** con dos personas en horarios de
> clase distintos, un standup sincrónico se cae la primera semana. Escrito en el issue sirve igual
> para coordinar y además deja el bloqueo del día registrado. Los bloqueos que no se escriben se
> repiten.

## Estimación

- Puntos de historia en escala Fibonacci: `1, 2, 3, 5, 8, 13`.
- Una historia mayor a `8` se parte antes de entrar al sprint.
- Se estima esfuerzo relativo, no horas.
- Referencia de calibración del proyecto: **listar el catálogo de servicios = 3 puntos**. Todo lo
  demás se estima comparando contra esa historia.

## Higiene del backlog

- Toda historia tiene valor de usuario explícito y criterios de aceptación (ver [definition-of-ready.md](./definition-of-ready.md)).
- Las historias que tocan UI enlazan su pantalla en `01-architecture/screens/`.
- Las historias que llaman al backend enlazan su documento de endpoint en `03-api-and-data/endpoints/`.
  Como todavía no existe backend real, el contrato está diseñado (stubbed) en esa carpeta: eso
  **sí cumple** la DoR.

## Roles

El framework trae una tabla de roles de equipo grande. Esta es la realidad del proyecto:

| Rol | Quién lo ejerce | De qué responde |
|-----|-----------------|-----------------|
| Product owner | El equipo, con el docente como aprobador | Prioridad del backlog, aceptación de historias |
| Tech lead | El equipo, en pareja | Arquitectura, ADRs, hacer cumplir la DoD |
| Desarrollo móvil | El equipo, una historia por persona | Implementación, pruebas y documentación |
| QA | Revisión cruzada: quien no implementó la historia la prueba en dispositivo real | Plan de pruebas y verificación en Android, única plataforma de la primera entrega |
| Usuaria validadora | Una manicurista aliada de Neiva | Prueba cada entrega y valida que el flujo del negocio se entienda |

> No hay QA dedicado: los cuatro roles los ejerce el mismo par de personas. Declararlo así es parte
> del acuerdo, y la mitigación es que **la DoD nunca la verifica quien implementó la historia**: se
> revisa cruzado. Aun así, el control externo de verdad sigue siendo la revisión del sprint **frente
> a una usuaria real**.
