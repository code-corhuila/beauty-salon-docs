# Convenciones de Git

> Estas reglas rigen el **repositorio del código** de ManiCita.
> Este repositorio de documentación es la excepción declarada en el [README raíz](../README.md):
> no usa ramas, todo se commitea directo a `main`.

## Ramas

- Desarrollo trunk-based con ramas cortas que salen de `main`.
- Nombres de rama: `feat/<scope>`, `fix/<scope>`, `chore/<scope>`, `docs/<scope>`.
  - Ejemplo: `feat/booking-slot-picker`, `fix/catalog-empty-state`.
- Una rama vive pocos días. Se rebasa sobre `main` antes de abrir el PR.

## Commits

- [Conventional Commits](https://www.conventionalcommits.org/): `tipo(scope): resumen`.
- Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `build`, `ci`.
- Modo imperativo, máximo 72 caracteres en la línea de resumen.

**Scopes propios de ManiCita.** Son los únicos válidos y salen de las features documentadas en
`01-architecture/features/`:

| Scope | Cubre |
|-------|-------|
| `auth` | Registro, inicio de sesión, sesión y roles |
| `catalog` | Catálogo de servicios y detalle del servicio |
| `booking` | Disponibilidad y creación de la cita |
| `appointments` | Mis citas de la clienta y detalle de la cita |
| `business` | Publicación de servicios, horarios y agenda del negocio |
| `core` | Cliente HTTP, base de datos local, tema, navegación |

Ejemplos:

- `feat(booking): calcular cupos a partir del horario y la duracion`
- `fix(catalog): mostrar estado vacio cuando no hay servicios publicados`
- `docs(architecture): documentar la feature de agendamiento`

## Pull Requests

- Un PR = una historia o un arreglo. Revisable (menos de ~400 líneas cuando se pueda).
- La descripción del PR enlaza la historia y lista qué probar en el dispositivo.
- CI en verde (lint + pruebas unitarias + pruebas de widget) antes de pedir revisión.
- Al menos una aprobación. **Squash-merge** hacia `main`.

> Con un equipo de dos, la aprobación la da quien **no** escribió el PR, y el docente la ratifica en
> la revisión del sprint. La regla no se elimina: se declara quién aprueba. Un PR sin aprobación no
> entra a `main`.

## Releases

- Versión de la app con [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`.
- El build number es un entero creciente, se incrementa en cada subida a la tienda.
- Los releases se etiquetan `vX.Y.Z` sobre `main`.
- Meta de versionado del semestre: `v0.1.0` al cierre del Sprint 1, `v0.2.0` al cierre del Sprint 2
  (MVP funcionando de punta a punta) y `v1.0.0` al cierre del Sprint 3.
