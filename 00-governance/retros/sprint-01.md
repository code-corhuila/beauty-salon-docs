# Sprint Retrospective — Sprint 1 (Corte 1)

> Copia de [`_template-sprint-retro.md`](../_template-sprint-retro.md).
>
> **Cómo se escribió:** redactada el 2026-10-07 a partir de hechos verificables (historial de
> commits de los cuatro repos, tablero del proyecto y la revisión del docente del 2026-09-28).
> Las integrantes la revisan y ajustan en la reunión de retro; lo que no compartan se corrige aquí
> antes de cerrar el Sprint 2.

- **Sprint:** 1 — Corte 1, del 2026-08-21 (primer commit) al 2026-09-28 (revisión del docente)
- **Date:** 2026-10-07
- **Participants:** Lilly Signey Puentes Rincon, Lizeth Caicedo

---

## Sprint snapshot

| Metric | Value |
|--------|-------|
| Committed points | No se estimó en puntos: las historias del tablero no tienen estimación |
| Completed points | — (7 historias cerradas: HU-01 a HU-07) |
| Carried over | 0 historias. Las HU-08 a HU-13 (auth en la app) se crearon para el corte siguiente |
| Crash-free rate (release) | No aplica: no hubo release ni APK |

**Resultado del corte según la revisión del docente:** 00–03 al 100% (el más completo del curso, y
el manejo de ADR citado como ejemplo), 04–05 al 0%, y sin retro registrada. Las tres cosas se
atendieron el 2026-10-07.

---

## What went well

- **Diseñar el contrato antes del código funcionó.** La API se implementó contra los documentos de
  `03-api-and-data/endpoints/` y hoy cumple los 18 endpoints con 49 sondas en verde. Cuando el
  código y el documento no coincidían, se corrigió primero el documento.
- **Las pruebas de punta a punta contra PostgreSQL real encontraron dos defectos** que una revisión
  de código no había visto: el middleware de autenticación aplicado a nivel de router se filtraba a
  rutas vecinas, y validar el cupo antes de insertar confundía "nunca existió" con "se lo llevaron".
- **Cuando el stack cambió, se escribieron ADR nuevas en vez de editar las viejas.** El docente lo
  usó de ejemplo para el curso (regla R3).
- **Cada documento declara su deuda.** `data-model.md` y `api-contract.md` dicen qué falta (D-, H-)
  en vez de esconderlo, y eso hizo rápido saber qué quedaba pendiente.

## What did not go well

- **El stack cambió a mitad del corte** (2026-09-17: de React Native + Expo a Ionic + Capacitor, al
  definirse solo Android). Se reescribieron cuatro ADR y se abandonó una app que ya tenía tres
  features funcionando.
- **La organización de los repos cambió cuatro veces en nueve días** (del 2026-09-17 al
  2026-09-25): `beauty-salon` como frontend, luego como API, luego monorepo (ADR-010) y por último
  cuatro repos (ADR-011). Cada cambio obligó a actualizar documentos y rutas.
- **Hubo huecos en el contrato que solo aparecieron al implementar:** no existía el endpoint de
  refresco del token, ni uno que creara profesionales, y sin profesional un negocio nuevo no podía
  publicar ningún servicio.
- **04-quality y 05-release se dejaron para el final** y la revisión las encontró en cero.
- **El tablero no refleja el sprint:** las historias no tienen puntos ni iteración, y las HU-04 a
  HU-07 se escribieron después de hacer el trabajo, no antes.
- **La app avanzó poco:** solo la feature `catalog` está construida, y sin pruebas.

## What we will change (action items)

| Action | Owner | Due |
|--------|-------|-----|
| Estimar en puntos las HU-08 a HU-13 y crear el campo de iteración en el tablero antes de empezarlas | _por asignar_ | Inicio del Sprint 2 |
| Escribir cada historia en el tablero **antes** de trabajarla, no después | Las dos | Todo el Sprint 2 |
| Antes de cerrar una feature, recorrer la cadena completa: feature → pantalla → componente → endpoint → entidad → caso de prueba (regla R2) | Quien implementa la feature | Cada historia |
| Correr el smoke test de la API antes de cada commit que la toque | Quien toque la API | Todo el Sprint 2 |
| Escribir la retro el último día del sprint, no en la revisión siguiente | _por asignar_ | Cierre del Sprint 2 |
| Resolver los cuatro bloqueos de seguridad del APK (`appId`, `allowBackup`, `minifyEnabled`, `console`) | _por asignar_ | Antes de `v0.2.0` |

---

> Review last sprint's action items at the top of the next retro. Unfinished actions
> either carry over with a reason or are dropped explicitly.
