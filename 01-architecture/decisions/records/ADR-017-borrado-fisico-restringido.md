# ADR-017 — Borrado físico restringido de profesionales y servicios sin historia

- **ID:** ADR-017
- **Fecha:** 2026-10-28
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

Hasta esta fecha **ninguna fila se borraba desde la API**
([data-model.md §5](../../../03-api-and-data/data-model.md#5-claves-foráneas-y-política-de-borrado)).
Lo que la interfaz llamaba "quitar" un servicio era pausarlo (`is_published = false`, la única baja
lógica, §6), y las profesionales no se podían editar ni eliminar.

El proyecto de aula del corte 3 exige **CRUD completo de al menos tantas entidades como integrantes
tenga el equipo (dos), con al menos dos relacionadas entre sí**, y la ficha del proyecto declara que
esas dos son `professional` y `service` (`service.professional_id → professional`). Para cerrar los
dos CRUD faltaban tres operaciones: editar profesional, eliminar profesional y eliminar servicio.

Editar no plantea ninguna decisión. Eliminar sí, porque choca con la historia:

- `appointment.service_id` y `appointment.professional_id` son claves foráneas que **restringen** el
  borrado. Una cita es historia de dinero y de agenda, y no se puede quedar sin servicio ni
  profesional.
- `service.professional_id` también restringe: un servicio sin profesional no se puede agendar.
- [E-11](../../../03-api-and-data/api-contract.md#e-11--get-v1businessprofessionals) promete que la
  lista de profesionales **nunca está vacía**: sin profesional el negocio no puede crear servicios.

**Restricciones conocidas:**
- Ningún error del contrato puede ser un 500 ([api-contract.md §3](../../../03-api-and-data/api-contract.md#3-catálogo-de-códigos-de-estado)):
  una violación de clave foránea no puede llegar a la clienta como error interno.
- Las citas guardan copia del nombre y el precio del servicio, pero **no** del nombre de la
  profesional.

---

## Decisión

**Decidimos:** agregar **borrado físico**, permitido **solo cuando el registro no tiene historia**, y
mantener la pausa como la forma de retirar un servicio que sí la tiene:

- `DELETE /v1/business/services/{id}` ([E-21](../../../03-api-and-data/endpoints/business-delete-service.md)):
  borra el servicio y, en cascada, su horario, **solo si no tiene ninguna cita** en ningún estado. Si
  tiene, 409 `SERVICE_HAS_APPOINTMENTS` y la app ofrece pausarlo.
- `DELETE /v1/business/professionals/{id}` ([E-20](../../../03-api-and-data/endpoints/business-delete-professional.md)):
  borra la profesional **solo si no tiene servicios ni citas y no es la última del negocio**. Si no,
  409 `PROFESSIONAL_IN_USE` o `LAST_PROFESSIONAL`.
- `PUT /v1/business/professionals/{id}` ([E-19](../../../03-api-and-data/endpoints/business-update-professional.md))
  cambia el nombre; el nombre nuevo se ve también en las citas viejas.

La API comprueba las condiciones **antes** de borrar para responder 409 con un mensaje claro, y si
aun así la clave foránea rechaza el borrado (una cita creada en medio), traduce ese rechazo al mismo
409. Las claves foráneas **no cambian**: siguen restringiendo.

**Justificación:**
- Cumple el CRUD completo que pide el proyecto sin tocar la historia de nadie: lo único que se borra
  es lo que se creó por error o de prueba y nunca se usó.
- Las claves foráneas que ya existen hacen el trabajo pesado: la regla "no se borra lo que tiene
  historia" la garantiza el motor, no solo el código.
- Para lo que sí tiene historia, la pausa ya resuelve el caso real (dejar de ofrecer un servicio sin
  perder sus citas) y ya está implementada.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Borrado físico solo sin historia, 409 si la tiene (elegida) | No cambia el esquema; el motor garantiza la regla; la pausa sigue cubriendo el caso con historia | Una profesional o un servicio con una sola cita vieja ya no se pueden borrar nunca | — (elegida) |
| Baja lógica también para `professional` (columna `is_active`) | Se podría "eliminar" cualquier profesional sin perder historia | Migración nueva; cada consulta de profesionales tiene que filtrar; hay que decidir qué pasa con los servicios de una profesional inactiva | Más cambios en la API y en la base de lo que el problema necesita a tres semanas de la entrega |
| Que `DELETE /services/{id}` sea un alias de pausar | Cero riesgo para la historia | Un `DELETE` que responde 200 y deja el registro no es un borrado; confunde a quien lee el contrato | Engaña al contrato: un CRUD con un borrado falso no es un CRUD completo |
| Borrado en cascada (borrar también las citas) | El borrado siempre funciona | Se pierde la historia de dinero y de agenda, también la de la clienta | Inaceptable: una clienta perdería sus citas porque el negocio borró un servicio |
| Hacer el CRUD completo sobre otras entidades (cita, horario) | `appointment` ya tiene casi todos los verbos | Borrar o editar una cita libremente rompe la regla de negocio de los cupos; el horario no tiene sentido fuera de su servicio (entidad interna) | Las dos encajan peor que profesional y servicio, que son lo que el negocio administra de verdad |

---

## Consecuencias

**Positivas:**
- `professional` y `service` quedan con CRUD completo desde la app, como declara la ficha.
- La historia (citas) nunca se pierde, y la regla la sostiene el motor.
- Cuatro códigos estables nuevos para la app: `PROFESSIONAL_NOT_FOUND`, `LAST_PROFESSIONAL`,
  `PROFESSIONAL_IN_USE` y `SERVICE_HAS_APPOINTMENTS`.

**Negativas / costos:**
- La comprobación previa tiene carrera con una cita o un servicio creados en el mismo instante; la
  cubre la clave foránea, pero la API tiene que traducir ese error del motor a 409.
- Renombrar una profesional cambia el nombre que se ve en sus citas pasadas, porque la cita no guarda
  copia. Se acepta: editar es para corregir cómo se escribe el nombre, no para cambiar de persona.
- Un registro con historia queda para siempre; la única salida para un servicio es pausarlo, y una
  profesional con historia no se puede retirar en esta versión.

**Impacto en el sistema:**
- Feature afectada: [Gestión del negocio](../../features/business.md), con la pantalla nueva
  [BusinessProfessionalsScreen](../../screens/negocio-profesionales.md) y el botón de eliminar en
  [ServiceFormScreen](../../screens/negocio-servicio-form.md).
- Documentos que la aplican: [`api-contract.md`](../../../03-api-and-data/api-contract.md) (E-19 a
  E-21) y [`data-model.md`](../../../03-api-and-data/data-model.md) (§5 y §6).
- Historias: HU-15 y HU-16 en `beauty-salon-app`.

---

## Referencias

- Guía "Proyecto de aula del corte 3" (Programación Móvil 2026-B, c3-project), sección 3 (alcance:
  entidades con CRUD completo).
- [PostgreSQL: restricciones de clave foránea](https://www.postgresql.org/docs/16/ddl-constraints.html#DDL-CONSTRAINTS-FK)
- Relacionada con: [ADR-012](./ADR-012-nombres-en-ingles.md) (códigos de error y nombres en inglés), [ADR-009](./ADR-009-backend-repo-and-stack.md) (API sobre PostgreSQL)
