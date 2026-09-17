# ADR-007 — Almacenamiento local (revisión: SQLite vía Capacitor)

- **ID:** ADR-007
- **Fecha:** 2026-09-17
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

[ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md) cambió el stack móvil de Expo a Capacitor.
`expo-sqlite`, el paquete que sostenía a [ADR-003](./ADR-003-local-storage.md), no existe fuera del
flujo administrado de Expo, así que la elección de **cómo** acceder a SQLite hay que volver a hacerla.
Las dos razones de negocio para tener almacén local no cambiaron: el catálogo debe abrir con contenido
con señal mala, y "Mis citas" debe consultarse sin datos.

**Restricciones conocidas:** las mismas que en [ADR-003](./ADR-003-local-storage.md) — esquema
relacional con migraciones versionadas, datos relacionales (servicios, profesionales, citas), nada de
datos sensibles de terceros en el dispositivo. Se agrega una restricción propia del stack nuevo: el
almacén debe funcionar como **plugin de Capacitor para Android**, sin exigir código nativo propio del
equipo.

---

## Decisión

**Se decidió:** mantener **SQLite con Drizzle ORM** como capa de acceso tipada, cambiando únicamente
el plugin que expone la base de datos al dispositivo: **`@capacitor-community/sqlite`** en vez de
`expo-sqlite`. Como Drizzle no trae un driver oficial para Capacitor, se conecta con el driver
**`drizzle-orm/sqlite-proxy`**, que ejecuta cada consulta a través de una función *callback* propia que
llama al plugin de Capacitor. El resto de la decisión —tipos generados del esquema, migraciones
versionadas, todo detrás de las interfaces de repositorio del dominio— no cambia.

**Justificación:**
La razón de fondo de [ADR-003](./ADR-003-local-storage.md) —datos relacionales, consultas tipadas,
migraciones versionadas— no depende de Expo ni de React Native: depende de la forma de los datos de
ManiCita, que no cambió. Cambiar de `expo-sqlite` a `@capacitor-community/sqlite` es un cambio de
**driver**, no de decisión: `sqlite-proxy` existe en Drizzle exactamente para conectar drivers de
SQLite no soportados de forma nativa, como el de Capacitor, sin perder el esquema tipado ni el sistema
de migraciones.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| `@capacitor-community/sqlite` + Drizzle ORM vía `sqlite-proxy` (elegida) | Relacional, consultas tipadas, migraciones versionadas, conserva el mismo modelo mental de ADR-003 | Un salto extra de indirección (el proxy) frente a un driver oficial | — (elegida) |
| `@capacitor-community/sqlite` con SQL crudo | Cero dependencia del proxy de Drizzle | Sin tipos: los errores de columna aparecen en ejecución; migraciones artesanales | Mismo motivo de descarte que en ADR-003: el riesgo de un typo en una consulta no compensa la dependencia ahorrada |
| Ionic Storage (`@ionic/storage`) | Muy simple de integrar, pensado para Ionic | Es un almacén clave-valor (IndexedDB/SQLite por debajo sin control del esquema): no permite las consultas relacionales que exige el catálogo | No sirve para datos relacionales, igual que AsyncStorage/MMKV en ADR-003 |
| `@capacitor/preferences` (clave-valor) | Trivial de usar, ideal para preferencias | Sin consultas ni relaciones | No sirve para datos relacionales; queda reservado para preferencias de UI, igual que en ADR-003 |

---

## Consecuencias

**Positivas:**
- El catálogo y las citas propias siguen abriendo sin conexión.
- El esquema sigue tipado con Drizzle: renombrar una columna rompe el build, no la app en el celular.
- Las migraciones se conservan versionadas y hacia adelante.

**Negativas / Costos:**
- El driver `sqlite-proxy` es más código de conexión que un driver oficial: hay que escribir el
  adaptador que traduce las llamadas de Drizzle a la API async de `@capacitor-community/sqlite`.
- En Android, `@capacitor-community/sqlite` requiere confirmar la inicialización nativa del plugin
  (permisos de almacenamiento, versión mínima de SDK) antes de la primera consulta.

**Impacto en el sistema:**
- Features afectadas: catalog y appointments (las que cachean). auth sigue guardando su token fuera de
  SQLite, en el plugin de secure storage de Capacitor. business consulta siempre en línea.
- Documentos a mantener sincronizados: [`persistence.md`](../../../03-api-and-data/persistence.md),
  [`offline-sync.md`](../../../03-api-and-data/offline-sync.md) y los documentos de
  [`entities/`](../../../03-api-and-data/entities/).

---

## Referencias

- Supersede a: [ADR-003](./ADR-003-local-storage.md)
- Relacionada con: [ADR-005](./ADR-005-mobile-stack-ionic-capacitor.md)
- [`persistence.md`](../../../03-api-and-data/persistence.md)
