# ADR-005 — Stack de desarrollo móvil (revisión: Ionic + Capacitor, solo Android)

- **ID:** ADR-005
- **Fecha:** 2026-09-17
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

[ADR-002](./ADR-002-mobile-stack.md) decidió React Native + TypeScript sobre Expo bajo la restricción
de correr en Android e iOS desde un computador Windows sin Mac, y el desempate real fue que **EAS
Build genera el binario de iOS en la nube**, sin necesitar Mac.

El alcance del producto cambió: **la primera entrega de ManiCita sale solo para Android**. iOS queda
fuera del MVP y se evalúa más adelante, si el proyecto continúa después del semestre. La restricción
que desempató ADR-002 desaparece con ese cambio de alcance, así que hay que revisar si React Native +
Expo sigue siendo la mejor opción o si el alcance real abre una alternativa mejor.

**Restricciones conocidas (actualizadas):**
- Equipo de dos personas, un semestre, sin presupuesto para servicios pagos.
- Alcance de la primera entrega: **solo Android**. iOS no condiciona esta decisión.
- Se necesitan notificaciones push para avisar de las citas.
- La app son listas, formularios y un selector de horarios, sin procesamiento pesado: el mismo perfil
  que ya describía [ADR-002](./ADR-002-mobile-stack.md).
- El build debe poder hacerse desde el mismo computador Windows del equipo, sin depender de un
  servicio de build en la nube de pago.

---

## Decisión

**Se decidió:** migrar a **Ionic React con TypeScript, sobre Capacitor**, compilando el APK/AAB de
forma local con Android Studio y Gradle. Se mantiene **React** como framework de UI (no Angular ni
Vue) a propósito, para no arrastrar a Ionic un cambio que no le corresponde: [ADR-006](./ADR-006-state-management-pattern.md)
(Zustand) y [ADR-008](./ADR-008-dependency-injection.md) (composition root + Context) ya asumen React,
y siguen aplicando sin tocar su razonamiento.

**Justificación:**
Al quedar Android como única plataforma de la primera entrega, el desempate que sostenía a Expo
—compilar iOS en la nube sin Mac— deja de aplicar. El perfil de la app (listas, formularios, selector
de horario) es exactamente el caso donde un WebView rinde bien sin costo perceptible para la usuaria,
y es el mismo perfil que ADR-002 ya usó para justificar una app híbrida. Capacitor compila Android de
forma local y gratuita con Android Studio/Gradle: no hay cola de build en un plan gratuito ni
dependencia de un servicio externo. El kit de componentes de Ionic (listas, formularios, selector de
fecha/hora) cubre buena parte de la UI del MVP sin construirla desde cero, lo que pesa con un equipo
de dos personas en un semestre.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| Ionic React + Capacitor, solo Android (elegida) | Build local sin Mac ni servicio pago, kit de componentes listo para listas y formularios, TypeScript, conserva React (Zustand y el composition root con Context siguen aplicando) | WebView en vez de componentes nativos; push, secure storage y SQLite hay que integrarlos con plugins de Capacitor por separado, ya no vienen incluidos como en Expo | — (elegida) |
| Mantener React Native + Expo ([ADR-002](./ADR-002-mobile-stack.md)) | Ya evaluado y funcionando; push, secure storage y SQLite incluidos en el flujo administrado | El desempate que la justificaba —build de iOS sin Mac— ya no aplica con el alcance a solo Android, y sigue exigiendo el flujo administrado de Expo sin necesidad real | El motivo original para pagar ese costo de ecosistema desapareció con el cambio de alcance |
| React Native con la CLI (sin Expo), solo Android | Control total del código nativo, sin depender del ecosistema Expo | Hay que configurar push y secure storage a mano, igual que con Capacitor, sin ganar el kit de componentes de Ionic | Mismo esfuerzo de configuración manual que Ionic, sin su beneficio principal |
| Ionic Angular o Ionic Vue | Mismo Capacitor, mismo build local en Android | Obliga a reemplazar Zustand y el composition root con Context por el patrón propio de Angular o Vue, decisiones ya validadas en [ADR-006](./ADR-006-state-management-pattern.md) y [ADR-008](./ADR-008-dependency-injection.md) | Cambiaría tres decisiones ya tomadas para llegar al mismo resultado que da quedarse en React |

---

## Consecuencias

**Positivas:**
- Build de Android completamente local y gratuito, sin depender de ningún servicio en la nube.
- El kit de componentes de Ionic acelera las pantallas de listas y formularios, que son la mayoría del
  MVP.
- Zustand y el composition root con Context siguen aplicando sin cambiar su razonamiento: se reafirman
  bajo el nuevo stack en [ADR-006](./ADR-006-state-management-pattern.md) y
  [ADR-008](./ADR-008-dependency-injection.md).

**Negativas / Costos:**
- Push, secure storage y SQLite ya no vienen incluidos: hay que integrar y mantener un plugin de
  Capacitor para cada uno (ver [ADR-007](./ADR-007-local-storage-capacitor.md) para SQLite).
- Si el proyecto retoma iOS más adelante, Capacitor vuelve a exigir Mac para compilar localmente (o un
  servicio de build en la nube de pago, como Ionic Appflow): el problema que resolvía EAS Build
  reaparecería tal cual.
- Cambia el bundler (**Vite** en vez de Metro) y el router (**React Router**, vía Ionic, en vez de
  React Navigation): obliga a reescribir `project-structure.md` y `navigation.md`, no solo a
  actualizar una referencia.

**Impacto en el sistema:**
- Features y pantallas afectadas: todas.
- Documentos a mantener sincronizados: [`project-structure.md`](../../project-structure.md),
  [`navigation.md`](../../navigation.md), [`layers-and-state.md`](../../layers-and-state.md), toda la
  sección `02-code-and-ui` y toda la sección `03-api-and-data`, además de
  [`security-rules.md`](../../../00-governance/security-rules.md) y
  [`definition-of-done.md`](../../../00-governance/definition-of-done.md).
- Supersede a [ADR-002](./ADR-002-mobile-stack.md). Obliga a revisar las tres ADRs que dependían de
  ella: ver [ADR-006](./ADR-006-state-management-pattern.md),
  [ADR-007](./ADR-007-local-storage-capacitor.md) y [ADR-008](./ADR-008-dependency-injection.md).

---

## Referencias

- Supersede a: [ADR-002](./ADR-002-mobile-stack.md)
- Relacionada con: [ADR-006](./ADR-006-state-management-pattern.md),
  [ADR-007](./ADR-007-local-storage-capacitor.md), [ADR-008](./ADR-008-dependency-injection.md)
- Documento de planificación de ManiCita, sección "Tipo de app y metodología"
