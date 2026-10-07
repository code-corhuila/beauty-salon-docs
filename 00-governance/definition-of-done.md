# Definition of Done (DoD)

Una historia está **terminada solo cuando todo esto es cierto**:

- [ ] Los criterios de aceptación se cumplen y se verificaron.
- [ ] El código está en `main` mediante un PR revisado y aprobado.
- [ ] Tiene pruebas unitarias y de componente, y pasan.
- [ ] Corre en **Android** sin regresiones (única plataforma de la primera entrega, ver
      [ADR-005](../01-architecture/decisions/records/ADR-005-mobile-stack-ionic-capacitor.md)).
- [ ] No introduce advertencias nuevas de linter, de tipos ni de accesibilidad.
- [ ] Maneja los estados loading, vacío, error y offline.
- [ ] Los textos están localizados: no hay strings de usuario quemados en el código.
- [ ] Los eventos de analítica o de reporte de errores están agregados donde corresponde.
- [ ] La documentación quedó actualizada (documento de feature, y ADR si se tomó una decisión arquitectónica).

> Una historia que no cumple la DoD completa **no está terminada**: sigue abierta. El trabajo parcial
> no se cierra "para terminarlo después".

---

## Cómo se verifica en ManiCita

| Check | Verificación concreta |
|-------|-----------------------|
| Pruebas | `npm run test.unit` en verde (Vitest, [ADR-013](../01-architecture/decisions/records/ADR-013-herramientas-de-prueba.md)). Casos de uso con prueba unitaria; pantallas con prueba de React Testing Library que cubre al menos los estados loaded, vacío y error. Si la historia toca una regla de negocio crítica, su [caso de prueba](../04-quality/test-cases/) se ejecuta y se marca. En la API, `pwsh scripts/smoke-test.ps1` en verde |
| Plataforma | Emulador Android (API 34) vía Android Studio. Al menos una vez por sprint, en el celular físico de la manicurista aliada |
| Sin advertencias | `npm run lint` (ESLint con `--max-warnings=0`) y `npx tsc --noEmit` sin errores, con el set de reglas declarado en [`02-code-and-ui/coding-standards.md`](../02-code-and-ui/coding-standards.md) |
| Estados | La pantalla implementa las cinco filas de su tabla de estados en `01-architecture/screens/` |
| Textos localizados | Ninguna cadena literal visible al usuario dentro de los widgets; todas salen de las claves definidas en [`02-code-and-ui/i18n.md`](../02-code-and-ui/i18n.md) |
| Accesibilidad | Se corre la checklist de verificación de [`02-code-and-ui/accessibility.md`](../02-code-and-ui/accessibility.md) sobre las pantallas tocadas |
| Documentación | El documento de feature refleja lo que quedó construido. Si cambió una decisión, se escribe una ADR nueva que supersede la anterior |

> **La regla que más se rompe en este proyecto es la de los estados.** Una pantalla que solo dibuja
> el caso feliz se ve terminada en el emulador con datos de prueba y falla apenas la manicurista
> abre la app sin servicios cargados o sin señal. Por eso los estados son un check propio y no una
> nota al pie de los criterios de aceptación.
