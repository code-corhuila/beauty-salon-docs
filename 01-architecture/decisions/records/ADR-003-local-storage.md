# ADR-003 — Almacenamiento local

- **ID:** ADR-003
- **Fecha:** 2026-09-07
- **Estado:** Superseded by [ADR-007](./ADR-007-local-storage-capacitor.md)
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

La app necesita guardar datos en el dispositivo por dos razones concretas, no por costumbre:

1. El **catálogo de servicios** debe abrir con contenido aunque la conexión esté lenta o intermitente,
   que es la condición normal de una clienta en la calle en Neiva.
2. **Mis citas** debe poder consultarse sin datos, porque el momento en que una clienta necesita
   recordar la hora de su cita suele ser justo cuando va camino al salón.

La regla de `persistence.md` obliga a escoger **un solo** almacén local por app y registrarlo aquí.

**Restricciones conocidas:**
- El esquema va a cambiar durante el semestre: se necesitan migraciones versionadas.
- Los datos a guardar son relacionales: servicios que pertenecen a un negocio, atendidos por una
  profesional, con un horario y unas citas.
- Nada de datos sensibles de terceros en el dispositivo: la agenda del negocio no se cachea.
- El almacén debe funcionar dentro del flujo administrado de Expo, sin código nativo propio.

---

## Decisión

**Se decidió:** usar **SQLite a través de `expo-sqlite`, con Drizzle ORM** como capa de acceso
tipada, envuelto detrás de las interfaces de repositorio del dominio.

**Justificación:**
Los datos de ManiCita son relacionales y las consultas que importan son cruces: los servicios
publicados de un negocio, las citas de una clienta ordenadas por fecha. SQLite hace eso de forma
natural. Drizzle agrega tipos de TypeScript sobre el esquema, así que una columna que se renombra
rompe la compilación en vez de fallar en tiempo de ejecución frente a la usuaria, y trae un sistema
de migraciones versionadas que es justo lo que exige `persistence.md`. `expo-sqlite` viene incluido
en el stack elegido en [ADR-002](./ADR-002-mobile-stack.md), sin salir del flujo administrado.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| `expo-sqlite` + Drizzle ORM (elegida) | Relacional, consultas tipadas, migraciones versionadas, incluido en Expo | Hay que escribir el esquema y las migraciones a mano | — (elegida) |
| `expo-sqlite` con SQL crudo | Cero dependencias extra, control total del SQL | Sin tipos: los errores de columna aparecen en ejecución; las migraciones quedan artesanales | El riesgo de romper la app con un typo en una consulta no compensa la dependencia ahorrada |
| WatermelonDB | Pensado para offline-first, sincronización incorporada, muy rápido con listas grandes | Modelo de sincronización pesado; exige configuración nativa y adoptar su forma de trabajar | ManiCita **no es offline-first**: agendar exige servidor. Se pagaría la complejidad de la sincronización sin usarla |
| AsyncStorage o MMKV (clave-valor) | Trivial de usar, ideal para preferencias | No hay consultas ni relaciones: filtrar el catálogo obligaría a leer todo y filtrar en memoria | No sirve para datos relacionales; queda reservado para preferencias de UI |

---

## Consecuencias

**Positivas:**
- El catálogo y las citas propias abren sin conexión, que son los dos momentos que importan.
- El esquema está tipado: renombrar una columna rompe el build, no la app en el celular.
- Las migraciones quedan versionadas y hacia adelante, como exige `persistence.md`.

**Negativas / Costos:**
- Cada cambio de esquema exige escribir y probar su migración contra una base **con datos**, no vacía.
- Hay que mantener el mapeo entre las filas de la base y las entidades del dominio: son dos modelos
  distintos a propósito, y eso es código extra.

**Impacto en el sistema:**
- Features afectadas: catalog y appointments (las que cachean). auth guarda su token en
  `expo-secure-store`, no aquí. business consulta siempre en línea.
- Documentos a mantener sincronizados: [`persistence.md`](../../../03-api-and-data/persistence.md),
  [`offline-sync.md`](../../../03-api-and-data/offline-sync.md) y los documentos de
  [`entities/`](../../../03-api-and-data/entities/).

---

## Referencias

- Relacionada con: [ADR-002](./ADR-002-mobile-stack.md)
- [`persistence.md`](../../../03-api-and-data/persistence.md)
