# Observabilidad

Cómo se sabe si ManiCita funciona en el celular de la manicurista y de sus clientas, y no solo en el
emulador.

> **Restricción que manda sobre todo este documento:** ningún dato personal sale hacia una
> herramienta de terceros. Ni nombre, ni celular, ni correo, ni el `id` de la cita junto con su hora
> ([`security-rules.md`](../00-governance/security-rules.md)). Un reporte de error que dice "la
> clienta Ana tiene cita el martes a las 9 en la Calle 8" es una fuga de privacidad, aunque sirva
> para depurar.

---

## Reporte de errores (crashes)

- **Meta:** sesiones sin cierre inesperado ≥ 99,5% desde que haya clientas reales usando la app.
- **Herramienta: sin decidir todavía.** Las dos candidatas son Sentry (`@sentry/capacitor`) y
  Firebase Crashlytics. La decisión se registra en una ADR **antes de `v1.0.0`**, y la tabla de
  alternativas tiene que comparar, sobre todo, qué datos envía cada una por defecto y cómo se
  desactivan. Deuda O-01.
- Sea cual sea, se configura sin datos personales (`sendDefaultPii: false` en Sentry, o su
  equivalente) y con los mapas de código fuente subidos desde CI, para que la traza del error apunte
  al TypeScript y no al JavaScript minificado.
- Una caída de la tasa de sesiones sin fallo por debajo de la meta es motivo para detener la
  distribución (ver [`signing-and-stores.md`](./signing-and-stores.md)).

**Mientras tanto (v0.x), lo que existe:**

| Dónde | Cómo se mira |
|-------|--------------|
| App en el emulador o el celular conectado por USB | `chrome://inspect` → consola del WebView, y `adb logcat` para errores nativos de Capacitor |
| API | `docker compose logs api` en `beauty-salon-infra`: el manejador de errores registra todo error no previsto antes de responder `problem+json` |

## Analítica

Se definen los eventos **antes** de instrumentarlos, y solo los del embudo principal del producto.
Ninguno lleva datos personales: el `serviceId` sí (es público en el catálogo), el nombre de la
clienta no.

| Evento | Cuándo | Propiedades |
|--------|--------|-------------|
| `catalog_viewed` | Se pinta el catálogo | `fromCache` (sí/no), `typeFilter` |
| `service_viewed` | Se abre el detalle de un servicio | `serviceId` |
| `slot_selected` | La clienta toca un cupo | `serviceId` |
| `appointment_created` | El servidor responde 201 | `serviceId` |
| `appointment_slot_taken` | El servidor responde `SLOT_TAKEN` | `serviceId` |
| `appointment_cancelled` | La clienta cancela | — |
| `service_published` | El negocio publica un servicio | `type`, `durationMinutes` |
| `appointment_responded` | El negocio confirma o rechaza | `status` |

> **El embudo que importa:** `catalog_viewed → service_viewed → slot_selected → appointment_created`.
> Si muchas clientas llegan a `slot_selected` y pocas a `appointment_created`, el problema está en la
> pantalla de agendar. Y si `appointment_slot_taken` crece, el negocio necesita más horario.

La herramienta de analítica sale de la misma ADR que el reporte de errores (O-01). Hasta entonces
los eventos no se envían a ningún lado: quedan definidos aquí para que los nombres no se inventen
pantalla por pantalla.

## Feature flags

- **v0.x no tiene flags remotas.** Con distribución por APK y un equipo de dos, una función
  arriesgada simplemente no entra al release hasta estar lista.
- Si una función necesita estar en el código sin estar visible, se apaga con una variable de build
  `VITE_FEATURE_<NOMBRE>=false`. **Es una desviación declarada del framework:** apagarla exige
  sacar otro APK, que es justo lo que una flag remota evita. Se acepta mientras no haya clientas
  reales; se revisa junto con O-01.
- Cada flag tiene responsable y fecha de retiro, y arranca apagada en `production`.

---

## Señales de salud por release

| Señal | Meta | Cómo se obtiene hoy |
|-------|------|---------------------|
| Sesiones sin cierre inesperado | ≥ 99,5% | ⏳ requiere la herramienta de O-01 |
| ANR (la app no responde) | Por debajo del umbral de Android | ⏳ igual que la anterior |
| Embudo `catalog_viewed → appointment_created` | Sin caída frente al release anterior | ⏳ requiere la analítica de O-01 |
| Errores `5xx` de la API | Cero en el día de prueba de la manicurista aliada | ✅ logs de la API |
| Contrato de la API | Las 49 sondas en verde | ✅ smoke test |

---

## Deuda

| ID | Qué falta | Responsable | Fecha |
|----|-----------|-------------|-------|
| O-01 | ADR que elija la herramienta de reporte de errores y analítica, con la comparación de privacidad | _por asignar_ | antes de `v1.0.0` |
| O-02 | Integrar la herramienta elegida y subir los mapas de código fuente desde CI | _por asignar_ | _por asignar_ |
