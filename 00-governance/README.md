# 00 — Governance

> Esta sección define los acuerdos de trabajo del proyecto ManiCita.
> Todo lo que está aquí aplica antes del primer commit y por encima de cualquier convención local.

---

## Documentos de esta sección

| Archivo | Para qué sirve |
|---------|----------------|
| [agile-conventions.md](./agile-conventions.md) | Sprints, ceremonias y estimación |
| [git-conventions.md](./git-conventions.md) | Estrategia de ramas, formato de commits, PR y releases |
| [definition-of-ready.md](./definition-of-ready.md) | Checklist para que una historia entre al sprint |
| [definition-of-done.md](./definition-of-done.md) | Checklist que toda historia terminada debe cumplir |
| [security-rules.md](./security-rules.md) | Reglas de seguridad no negociables |
| [_template-sprint-retro.md](./_template-sprint-retro.md) | Plantilla para registrar una retrospectiva |

---

## Cómo aplica la gobernanza

Estas reglas aplican a **todo el proyecto**: todas las secciones, todas las features. Si una regla
choca con una convención local, gana la gobernanza, salvo que una ADR nueva
(`01-architecture/decisions/`) la reemplace explícitamente.

> Una regla de gobernanza solo cambia por acuerdo, y el cambio se documenta con su motivo antes
> del siguiente sprint.

---

## Retrospectivas registradas

| Sprint | Documento | Fecha |
|--------|-----------|-------|
| — | Ninguna todavía: los sprints aún no se han ejecutado | — |

> Cuando se cierre el Sprint 1 se copia `_template-sprint-retro.md` a `retros/sprint-01.md`
> y se agrega la fila aquí. La plantilla original no se toca.

---

## Preguntas que esta sección debe responder

- ¿Cómo se planea, se estima y se cierra el trabajo? → [agile-conventions.md](./agile-conventions.md)
- ¿Qué significa "lista" y "terminada" para una historia? → [DoR](./definition-of-ready.md) y [DoD](./definition-of-done.md)
- ¿Cómo se nombran ramas, commits y releases? → [git-conventions.md](./git-conventions.md)
- ¿Cuáles son las reglas de seguridad innegociables? → [security-rules.md](./security-rules.md)
