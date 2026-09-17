# Feature — Agendamiento

- **Responsables:** Lilly Signey Puentes Rincon y Lizeth Caicedo
- **Estado:** Planned
- **Historias relacionadas:** HU-004 agendar la cita sobre un cupo real (Sprint 2)

---

## Propósito

Permitir que la clienta escoja fecha y hora **solo entre los cupos que la profesional tiene realmente
libres**, y deje su cita registrada. Es la feature donde el ciclo del producto se cierra: si esto
funciona una vez de punta a punta, el MVP cumplió.

---

## Pantallas

| Pantalla | Ruta | Propósito |
|----------|------|-----------|
| [BookAppointmentScreen](../screens/agendar-cita.md) | `/agendar/:servicioId` | Elegir fecha, ver las horas libres, confirmar la cita |

---

## Estado

- **Patrón:** Store con Zustand ([ADR-006](../decisions/records/ADR-006-state-management-pattern.md))
- **Objeto de estado:** `BookingState`, con `selectedDate`, `slots`, `selectedSlot`, `status` y
  `error`
- **Transiciones clave:**
  - Elegir fecha: `loading` a `loaded` con los cupos, o `empty` si ese día no hay ninguno.
  - Confirmar: `submitting` a `booked`, o a `slotTaken` si el servidor rechaza el cupo, que **vuelve
    a pedir la disponibilidad automáticamente** y deja a la clienta escogiendo otra hora.

> `slotTaken` es un estado propio y no un error genérico. Es el caso que ocurre de verdad cuando dos
> clientas miran el mismo servicio a la misma hora, y merece un mensaje que explique qué pasó, no un
> "algo salió mal".

---

## Datos

- **Casos de uso:** `getAvailability`, `bookAppointment`
- **Repositorios:** `BookingRepository`
- **Endpoints:** [`GET /v1/servicios/{id}/disponibilidad`](../../03-api-and-data/endpoints/agendamiento-disponibilidad.md),
  [`POST /v1/citas`](../../03-api-and-data/endpoints/agendamiento-crear-cita.md)
- **Persistencia local:** ninguna. Los cupos **no se cachean**: un cupo guardado es un cupo mentiroso.
- **Estrategia offline:** **online-only**, y es la decisión de negocio más importante de la sección 03:
  un cupo no se puede confirmar sin servidor, porque otra clienta puede estar tomándolo en ese mismo
  segundo. Sin conexión, la pantalla lo dice y no deja continuar.

---

## La regla que sostiene la feature

Los cupos **se calculan, no se almacenan**:

```
cupos del día = horario de atención de la profesional / duración del servicio
                menos los bloques ya ocupados por citas Pendientes o Confirmadas
```

Esto vive en el caso de uso `getAvailability`, en la capa de dominio, y se prueba sin red ni UI.
La consecuencia práctica: la manicurista configura su horario una vez y no vuelve a tocarlo. Si
tuviera que crear los cupos a mano cada día, dejaría de usar la app en una semana.

**El cupo se valida dos veces:** al mostrarlo y al confirmarlo. La primera validación es para la
experiencia; la segunda es la que de verdad evita el doble agendamiento, y ocurre en el servidor.

---

## Casos borde y estados

- [x] Loading — consultando los cupos de la fecha elegida
- [x] Empty — ese día no tiene cupos libres: se sugiere la siguiente fecha con disponibilidad
- [x] Error / reintento — falla la consulta de disponibilidad
- [x] Error de negocio — el cupo fue tomado mientras la clienta decidía: aviso y recarga automática
- [x] Offline — no se puede agendar sin conexión; el mensaje lo explica en vez de fallar en silencio
- [x] Permiso denegado — sin sesión, la guarda manda a login y devuelve a esta misma ruta

---

## Decisiones

- [ADR-006](../decisions/records/ADR-006-state-management-pattern.md) — patrón de estado
- [ADR-007](../decisions/records/ADR-007-local-storage-capacitor.md) — la decisión de **no** cachear cupos se
  apoya en el alcance del almacén local definido ahí

---

## Pruebas

- **Unitarias:** `getAvailability` es el caso de uso más probado del proyecto: horario partido en
  bloques exactos, horario que no divide exacto la duración, día sin horario definido, cupos ya
  ocupados, servicio pausado. `bookAppointment` con cupo libre y con cupo tomado.
- **De componente:** `BookAppointmentScreen` en loading, loaded, empty, error, `slotTaken` y offline.
- **Integración:** el ciclo completo del MVP — el negocio publica, la clienta agenda, la cita aparece
  en "Mis citas" y en la agenda del negocio.
