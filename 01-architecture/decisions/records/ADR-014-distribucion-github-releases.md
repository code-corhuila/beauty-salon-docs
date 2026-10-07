# ADR-014 — Distribución por GitHub Releases, con CI en GitHub Actions

- **ID:** ADR-014
- **Fecha:** 2026-10-07
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

El framework da por hecho que la app llega a las personas por las tiendas (Google Play, App Store),
con despliegue por porcentajes y metadatos de tienda. ManiCita:

- Es solo Android en la primera entrega ([ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md)).
- Es un proyecto de semestre con un equipo de dos y una manicurista aliada como primera usuaria.
- No tiene la API desplegada en un servidor con HTTPS (hueco H-01 de
  [`api-contract.md`](../../../03-api-and-data/api-contract.md)).
- Ya usa GitHub para todo: los cuatro repos están en la organización `code-corhuila`, y
  `beauty-salon-api` ya tiene un `release.yml` que crea un GitHub Release con cada tag. La HU-03 del
  primer corte pedía, además, un GitHub Release con el instalable adjunto.

Hay que decidir por dónde llega el APK y qué construye los artefactos, porque
[`05-release/`](../../../05-release/) no se puede escribir sin eso.

**Restricciones conocidas:**
- Cero costo.
- Las credenciales de firma no pueden vivir en un repositorio
  ([`security-rules.md`](../../../00-governance/security-rules.md)).

---

## Decisión

**Decidimos:** el APK firmado se distribuye **adjunto a un GitHub Release** de `beauty-salon-app`, y
lo construye **GitHub Actions** a partir del tag `vX.Y.Z`. No se publica en Google Play durante el
semestre.

**Justificación:**
- Es gratis, está donde ya está el código, y el patrón ya funciona en la API (`release.yml`).
- GitHub Actions guarda la llave de firma como secreto cifrado del repositorio: se cumple la regla
  de no tener credenciales en el repo sin montar nada aparte.
- Google Play exige una cuenta de desarrollador paga, una política de privacidad publicada, una
  revisión que tarda días y, para cuentas personales nuevas, una prueba cerrada con un mínimo de
  testers durante dos semanas antes de producción. Todo eso para una app cuya API ni siquiera tiene
  despliegue público todavía.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| APK en GitHub Releases, construido por GitHub Actions (elegida) | Gratis; ya se usa en la API; cada versión queda con su APK y sus notas; volver atrás es descargar el anterior | Instalar exige permitir "orígenes desconocidos"; no hay actualización automática ni despliegue por porcentajes | — (elegida) |
| Google Play, pista de prueba interna | Actualizaciones automáticas; la experiencia real de una tienda | Cuenta paga; revisión y requisitos de testers para cuentas nuevas; sin API desplegada no hay nada útil que revisar | Costo y tiempo que no caben en el semestre |
| Firebase App Distribution | Gratis; avisa a los testers cuando hay versión nueva | Un servicio más, una cuenta más y un SDK de Google para algo que GitHub ya resuelve | Agrega una dependencia sin resolver un problema real con dos testers |
| Construir el APK a mano en Android Studio y compartirlo | Sin configurar nada | La llave queda en un portátil; nadie sabe de qué commit salió el APK | Rompe "los artefactos salen de CI" y la regla de credenciales |

---

## Consecuencias

**Positivas:**
- Cada versión queda trazable: tag → commit → APK → notas de versión.
- La API y la app usan el mismo mecanismo de release.

**Negativas / costos:**
- No hay despliegue escalonado automático: se reemplaza por tres pasos manuales (equipo →
  manicurista aliada → clientas) descritos en [`signing-and-stores.md`](../../../05-release/signing-and-stores.md).
- No hay actualización automática: cada clienta tiene que descargar el APK nuevo. Mientras sean
  pocas es aceptable; con clientas reales se revisa esta ADR.
- Sin bandera remota de versión mínima, los cambios rompientes se manejan con el versionado de la
  API (`/v1` → `/v2`).

**Impacto en el sistema:**
- Documentos que la aplican: [`05-release/ci-cd.md`](../../../05-release/ci-cd.md),
  [`05-release/signing-and-stores.md`](../../../05-release/signing-and-stores.md) y la
  checklist de cada release en [`05-release/releases/`](../../../05-release/releases/).
- Repos afectados: `beauty-salon-app` (nuevos `ci.yml` y `release.yml`) y `beauty-salon-api`
  (nuevo `ci.yml`; `release.yml` ya existe).

---

## Referencias

- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github) · [Secretos de GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)
- Relacionada con: [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) (solo Android), [ADR-011](./ADR-011-cuatro-repositorios.md) (cuatro repos)
