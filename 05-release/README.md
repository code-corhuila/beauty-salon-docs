# 05 — Release

> **¿Qué es esto?** Cómo se construye ManiCita, cómo se firma, cómo llega al celular de la
> manicurista y de sus clientas, y cómo se observa una vez instalada.

## Por qué existe esta sección

El release es donde una app móvil más se diferencia de un backend: la firma, la distribución, las
actualizaciones forzadas y volver atrás. Estas reglas hacen que un release se pueda repetir y
deshacer.

> **Desviación declarada:** ManiCita no se publica en Google Play durante el semestre. El APK firmado
> se distribuye adjunto a un GitHub Release
> ([ADR-014](../01-architecture/decisions/records/ADR-014-distribucion-github-releases.md)). Por eso
> los documentos hablan de "distribución" donde el framework habla de "tienda", y no hay nada de iOS
> ([ADR-005](../01-architecture/decisions/records/ADR-005-mobile-stack-ionic-capacitor.md)).

> **Esta carpeta no guarda código ni binarios** (regla R1 del curso): los APK quedan adjuntos a los
> GitHub Releases de `beauty-salon-app`, y aquí solo van las checklists y las notas de versión.

---

## Documentos de esta sección

| Archivo | Para qué sirve |
|---------|----------------|
| [ci-cd.md](./ci-cd.md) | Pipelines de GitHub Actions de la app y de la API, disparadores y entornos de build |
| [signing-and-stores.md](./signing-and-stores.md) | Llave de firma, identidad de la app, versionado, distribución escalonada, actualización forzada y cómo volver atrás |
| [observability.md](./observability.md) | Reporte de errores, eventos de analítica, flags y señales de salud, sin datos personales |
| [releases/](./releases/) | Una checklist de go / no-go por release, con sus notas de versión |
| [_template-release-checklist.md](./_template-release-checklist.md) | Plantilla de la checklist (no se edita) |

---

## Releases

| Versión | Checklist | Decisión | Fecha |
|---------|-----------|----------|-------|
| v0.1.0 | [releases/v0.1.0.md](./releases/v0.1.0.md) | No-Go para el APK (pendientes de seguridad y firma); API lista para etiquetar | _por definir_ |

> Cada release copia `_template-release-checklist.md` a `releases/vX.Y.Z.md` y agrega su fila aquí.

---

## Correlaciones con otras secciones

| Esta sección depende de... | Por qué |
|----------------------------|---------|
| `00-governance/git-conventions.md` | El tag `vX.Y.Z` sobre `main` dispara el release |
| `04-quality/` | Las pruebas, los presupuestos y la checklist de seguridad son compuertas del release |
| `03-api-and-data/` | Un cambio rompiente de la API sube a `/v2` en vez de obligar a actualizar la app |

---

## Preguntas que esta sección debe responder

- ¿Cómo se convierte un commit en un APK instalable? → [ci-cd.md](./ci-cd.md)
- ¿Dónde vive la llave de firma? → [signing-and-stores.md](./signing-and-stores.md)
- ¿Cómo se escalona la distribución y cómo se vuelve atrás? → [signing-and-stores.md](./signing-and-stores.md)
- ¿Cómo se observa la app ya instalada? → [observability.md](./observability.md)
