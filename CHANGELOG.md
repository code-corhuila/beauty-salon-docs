# Changelog
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) | [SemVer](https://semver.org/)
## [Unreleased]
### Added
- Cierre del informe del corte 1 (2026-10-07): retro del Sprint 1 en `00-governance/retros/sprint-01.md`;
  ADR-015 (cliente HTTP con axios, decisión ya tomada pero sin registrar); sección "Datos que la
  alimentan" en las 10 pantallas (caso de uso → endpoint → entidad del servidor → caché local);
  componentes `BotonSecundario` y `DistintivoEstadoCita`, que el detalle de la cita, la agenda y Mis
  citas usaban sin ficha
- `api-networking.md`: el repo es `beauty-salon-api`, ya no hay mock, y la URL de producción no
  existe todavía (H-01); se declara que axios solo tiene timeout total
- **04-quality adaptada (2026-10-07):** `testing-strategy.md` con las herramientas reales de cada
  repo, la pirámide, la cobertura y la tabla de reglas de negocio críticas; `performance-budgets.md`
  con línea base medida (JavaScript inicial 362 KB gzip); `mobile-security.md` como checklist con el
  estado de cada punto; 10 casos de prueba `test-cases/TC-001..TC-010`, uno por regla crítica
- **05-release adaptada (2026-10-07):** `ci-cd.md` (GitHub Actions por repo), `signing-and-stores.md`
  (llave, identidad, versionado, distribución escalonada, volver atrás), `observability.md`
  (eventos del embudo sin datos personales) y la checklist `releases/v0.1.0.md`
- ADR-013 (herramientas de prueba) y ADR-014 (distribución por GitHub Releases)

### Changed
- `definition-of-done.md` y `layers-and-state.md`: las pruebas se corren con Vitest
  (`npm run test.unit`), no con Jest; la app nunca tuvo `npm test` (ADR-013)
- README raíz: 04 y 05 dejan de figurar como fuera de alcance; decisiones 7 y 8

### Added
- Backend implementado en `beauty-salon`: Node.js + Express + PostgreSQL, los 13 endpoints del
  contrato (los 12 documentados más `auth-refresh`), probado de punta a punta contra PostgreSQL real
- `03-api-and-data/endpoints/auth-refresh.md` — endpoint `POST /v1/auth/refresh`, faltante en el
  contrato original: `authentication.md` ya describía el refresco de token del lado del cliente sin
  que existiera el endpoint que lo hace posible

### Changed
- **`beauty-salon` pasa a ser el repo de la API (Node.js + Express + PostgreSQL), no el de
  frontend.** El profesor indicó que ese repo debe usarse para la API; el frontend Ionic +
  Capacitor se mueve a un repo nuevo, aún sin crear. Nueva ADR-009. Actualizados: README raíz
  (Decisión 6), `01-architecture/README.md`, `plan-implementacion-login-catalogo.md`,
  `03-api-and-data/README.md` y `api-networking.md`
- **Stack móvil revisado de React Native + Expo a Ionic React + Capacitor**, con la primera entrega
  de ManiCita limitada a **Android**. Motivo: el desempate original de ADR-002 (compilar iOS en la
  nube sin Mac con EAS Build) dejó de aplicar al definirse el alcance solo-Android. Nuevas ADR-005
  (stack), ADR-006 (patrón de estado, reafirma Zustand), ADR-007 (almacenamiento local, SQLite vía
  `@capacitor-community/sqlite`) y ADR-008 (inyección de dependencias, reafirma composition root +
  Context). ADR-001, ADR-002, ADR-003 y ADR-004 quedan `Superseded`
- `project-structure.md`, `navigation.md`, `layers-and-state.md`, `coding-standards.md`,
  `security-rules.md`, `definition-of-done.md` y toda la sección `03-api-and-data` actualizados para
  reflejar Capacitor (SQLite, secure storage, push, build con Vite/Android Studio) en vez de Expo

### Added
- README raíz reescrito como documentación del proyecto ManiCita, con las decisiones de Fase 0
- 00-governance: convenciones ágiles, de git, DoR y DoD adaptadas a un equipo de dos personas con sprints de 2 semanas; reglas de seguridad con el inventario de datos sensibles de la app
- 01-architecture: estructura de carpetas para React Native, capas y patrón de estado, registro de 10 rutas de navegación
- 01-architecture: ADR-001 (patrón de estado), ADR-002 (stack móvil), ADR-003 (almacenamiento local) y ADR-004 (inyección de dependencias)
- 01-architecture: 5 documentos de feature y 10 de pantalla
- 02-code-and-ui: estándares de TypeScript, design system con tokens y contrastes verificados, reglas de accesibilidad e i18n
- 02-code-and-ui: 5 documentos de componente compartido
- 03-api-and-data: red, autenticación con dos roles, persistencia local y estrategia offline por feature
- 03-api-and-data: contrato de API diseñado con 12 documentos de endpoint y 4 de entidad local
- 01-architecture: `flows/manicita-flujos.html` con el BPMN de agendamiento anotado con rutas y endpoints, el mapa de navegación y la cadena de trazabilidad
- 01-architecture: `mockups/manicita-mockups.html` con las diez pantallas dibujadas en marco de
  teléfono, cuatro estados clave, una lámina en tema oscuro, los cinco componentes compartidos y la
  carta de tokens con sus contrastes

### Changed
- ADR-001 reemplaza la ADR de ejemplo del framework por la decisión real del proyecto
- Autoría: la documentación queda a nombre de Lilly Signey Puentes Rincon y Lizeth Caicedo. Las
  convenciones ágiles, las de git y los ADR-001, 002 y 004, que estaban escritos sobre la premisa de
  un equipo de una sola persona, se reescribieron para un equipo de dos: revisión cruzada de PR y
  verificación de la DoD por quien no implementó la historia

### Notes
- Las secciones 04-quality y 05-release quedan sin adaptar: fuera del alcance de esta entrega
- Con los mockups dibujados, los diez documentos de pantalla y el check de Referencia de UI de la
  Definition of Ready dejan de apuntar solo a un boceto a mano
## [1.0.0] - 2026-08-28
### Added
- Manual-style governance scaffold for mobile apps: numbered sections, each with a README and copy-and-fill templates
- `00-sdd-guide.md` — methodology and fill-in order
- 00-governance: agile, git, DoR/DoD, security rules + sprint-retro template
- 01-architecture: structure, layers & state, navigation, ADRs (with example ADR-001) + feature/screen templates
- 02-code-and-ui: coding standards, design system, accessibility, i18n + component template
- 03-api-and-data: networking, auth, persistence, offline-sync + endpoint/entity templates
- 04-quality: testing strategy, performance budgets, mobile security + test-case template
- 05-release: CI/CD, signing & stores, observability + release-checklist template
