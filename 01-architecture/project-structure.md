# Estructura del proyecto

ManiCita se desarrolla en **Ionic React con TypeScript sobre Capacitor**, para Android en la primera
entrega — ver [ADR-005](./decisions/records/ADR-005-mobile-stack-ionic-capacitor.md).
El código se organiza **por feature, no por tipo técnico**. Cada feature es dueña de sus tres capas.

```
src/
├── core/                       Compartido por todas las features
│   ├── di/                     Composition root: fábricas de repositorios y AppProviders
│   ├── network/                Cliente axios, interceptores, mapeo de errores
│   ├── storage/                Base de datos SQLite (Drizzle sobre @capacitor-community/sqlite) y
│   │                           wrapper del plugin de secure storage de Capacitor
│   ├── theme/                  Design tokens, tipografía, tema claro y oscuro
│   ├── routing/                Navegador raíz, tipos de rutas y guardas de sesión
│   ├── session/                SessionState global (perfil y rol, nunca tokens): lo abre auth y lo
│   │                           leen las guardas y las demás features
│   └── domain/                 Entidades compartidas por varias features (Service, Appointment)
├── features/
│   ├── auth/                   Registro, inicio de sesión, sesión y rol
│   ├── catalog/                Catálogo de servicios y detalle
│   ├── booking/                Disponibilidad y creación de la cita
│   ├── appointments/           Mis citas de la clienta
│   └── business/               Publicación de servicios, horarios y agenda del negocio
│       ├── presentation/       Pantallas, componentes propios y stores de Zustand
│       ├── domain/             Entidades, casos de uso, interfaces de repositorio
│       └── data/               Implementaciones de repositorio, data sources, DTOs, mappers
├── shared/                     Componentes de UI reutilizables por varias features
│   └── components/
├── locales/                    Archivos de traducción (es-CO, en)
└── App.tsx                     Arranque de la app, providers y navegador raíz
```

Las cinco features tienen la misma estructura interna de tres carpetas; arriba solo se expande
`business/` para no repetir el árbol cinco veces.

## Reglas

- Una feature = una carpeta bajo `features/`. **Sin imports entre features**: lo que dos features
  necesiten se comparte por `core/` o por `shared/`.
- Un archivo declara un tipo principal y el nombre del archivo coincide con él.
- `shared/` contiene solo UI reutilizable y sin lógica de negocio. Nada que sepa qué es una cita.
- Ninguna feature entra al `data/` ni al `domain/` de otra feature.
- La regla se hace cumplir en CI con la regla `import/no-restricted-paths` de ESLint, no solo en
  revisión: una regla de arquitectura que solo vive en la cabeza de quien revisa se rompe sola.

### Cómo se resuelven los dos cruces reales de ManiCita

El árbol de arriba tiene dos puntos donde la regla de "sin imports entre features" se pone a prueba,
y conviene dejar resuelto el criterio antes de escribir código:

| Cruce | Solución |
|-------|----------|
| `booking` necesita mostrar el servicio que se está agendando, que pertenece a `catalog` | El tipo `Service` vive en `core/domain/` porque lo comparten tres features (catalog, booking, business). Los casos de uso de catálogo siguen en `catalog/` |
| `business` necesita ver las citas que le llegan, y `appointments` también muestra citas | Son dos features distintas sobre la misma entidad: `appointments` es la vista de la clienta sobre **sus** citas, `business` es la vista del negocio sobre **su agenda**. Cada una tiene su caso de uso y su endpoint; comparten el tipo `Appointment` en `core/domain/`, no el repositorio |

> El tipo compartido en `core/domain/` es la única excepción a la regla, y existe porque la
> alternativa —duplicar `Service` en tres features y mapear entre copias— produce exactamente el
> tipo de inconsistencia que la regla busca evitar.

## Nombres

| Cosa | Convención | Ejemplo |
|------|------------|---------|
| Carpeta de feature | `kebab-case`, en inglés | `appointments/` |
| Tipo, interfaz, clase | `PascalCase` | `AppointmentRepository` |
| Archivo de componente | `PascalCase.tsx`, igual al componente | `ServiceCard.tsx` |
| Archivo de módulo | `camelCase.ts`, igual al export principal | `appointmentRepository.ts` |
| Hook | `useAlgo.ts` | `useAvailability.ts` |
| Caso de uso | verbo + sustantivo, archivo `camelCase.ts` | `bookAppointment.ts` |
| Store de Zustand | `use<Feature>Store` | `useCatalogStore` |
| Objeto de estado | `<Pantalla>State` | `CatalogState` |
| Prueba | igual al archivo probado + `.test.ts(x)` | `bookAppointment.test.ts` |

> **Por qué el código va en inglés y la documentación en español:** el código convive con las APIs de
> React, Ionic y Capacitor, que están en inglés, y mezclar `bookAppointment` con `obtenerCitas` en el mismo
> archivo se lee peor que cualquiera de las dos opciones puras. La documentación va en español porque
> la leen personas, no el compilador. La excepción son las rutas de navegación, que sí van en
> español: ver [navigation.md](./navigation.md).

## Configuración de TypeScript

- `strict: true` sin excepciones. `any` explícito prohibido por ESLint.
- Alias de import absolutos (`@core/*`, `@features/*`, `@shared/*`) configurados en `tsconfig.json`
  y resueltos por Vite (`resolve.alias` en `vite.config.ts`, o el plugin `vite-tsconfig-paths`). Nada
  de `../../../`.
