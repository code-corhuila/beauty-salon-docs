# ADR-002 — Stack de desarrollo móvil

- **ID:** ADR-002
- **Fecha:** 2026-09-07
- **Estado:** Superseded by [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md)
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

El documento de planificación de ManiCita ya decidió que la app sería **híbrida**, con tres razones:
las clientas de Neiva usan Android y iPhone, el proyecto lo desarrollan dos personas en un
semestre, y la app son listas, formularios y un selector de horarios, sin procesamiento pesado.

Falta decidir **con qué tecnología híbrida**, y esa decisión define carpetas, lenguaje, librerías,
pruebas y naming en toda la documentación: sin ella no se puede escribir ni la estructura del
proyecto ni los estándares de código.

**Restricciones conocidas:**
- Un equipo de dos personas, un semestre, sin presupuesto para servicios pagos.
- Se necesitan **notificaciones push** para avisar de las citas.
- Debe correr en Android e iOS desde una sola base de código.
- La entrega se desarrolla en un computador Windows: compilar para iOS localmente no es posible.

---

## Decisión

**Se decidió:** desarrollar ManiCita en **React Native con TypeScript, sobre Expo**, con EAS Build
para generar los binarios.

**Justificación:**
TypeScript sobre React Native permite apoyarse en JavaScript, que es el lenguaje que ya se maneja, y
Expo resuelve por sí solo las tres piezas que más tiempo consumen en un proyecto de una persona:
notificaciones push con `expo-notifications`, almacenamiento seguro de tokens con `expo-secure-store`
y base de datos local con `expo-sqlite`. El desempate real fue la restricción de Windows: **con EAS
Build el binario de iOS se genera en la nube**, sin Mac. Con cualquier alternativa que exija
compilación local de iOS, la mitad del requisito híbrido quedaría sin poder probarse.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| React Native + TypeScript sobre Expo (elegida) | Un solo código para ambas plataformas, TypeScript, push y SQLite incluidos, build de iOS en la nube sin Mac, prueba en celular físico por QR | Menos control del código nativo; las builds en la nube hacen cola en el plan gratuito | — (elegida) |
| React Native sin Expo, con la CLI | Control total del código nativo, sin dependencia del ecosistema Expo | Hay que configurar push, secure storage y firma a mano; iOS exige Mac | El costo de configuración se come semanas del semestre, y sin Mac no hay iOS |
| Flutter con Dart | Muy buen rendimiento, UI consistente entre plataformas, herramientas maduras | Dart es un lenguaje nuevo que habría que aprender antes de escribir la primera pantalla; iOS también exige Mac para compilar localmente | La curva del lenguaje compite con el tiempo del semestre, que es el recurso escaso |
| Nativo con Kotlin y Swift | El mejor rendimiento y acceso total a la plataforma | Dos bases de código, dos lenguajes, el doble de trabajo, y una de las dos imposible sin Mac | Contradice la decisión de app híbrida ya tomada y justificada en la planificación |

---

## Consecuencias

**Positivas:**
- Una sola base de código para las dos plataformas que usan las clientas de Neiva.
- Las tres capacidades que el MVP necesita del dispositivo vienen resueltas por el ecosistema.
- La manicurista aliada puede probar cada entrega abriendo un enlace en su celular.

**Negativas / Costos:**
- Dependencia del ciclo de versiones de Expo: subir de versión mayor puede exigir migraciones.
- Si más adelante hiciera falta una librería nativa sin soporte, habría que salir del flujo
  administrado. Se acepta el riesgo: el MVP no lo requiere.
- El rendimiento de listas largas exige cuidado, y por eso queda como regla explícita en
  [`coding-standards.md`](../../../02-code-and-ui/coding-standards.md).

**Impacto en el sistema:**
- Features y pantallas afectadas: todas.
- Documentos a mantener sincronizados: [`project-structure.md`](../../project-structure.md), toda la
  sección `02-code-and-ui` y toda la sección `03-api-and-data`.

---

## Referencias

- Relacionada con: [ADR-001](./ADR-001-state-management-pattern.md),
  [ADR-003](./ADR-003-local-storage.md), [ADR-004](./ADR-004-dependency-injection.md)
- Documento de planificación de ManiCita, sección "Tipo de app y metodología"
