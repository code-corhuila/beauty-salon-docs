# ADR-015 — Cliente HTTP: una sola instancia de axios con interceptores

- **ID:** ADR-015
- **Fecha:** 2026-10-07
- **Estado:** Accepted
- **Autoría:** Lilly Signey Puentes Rincon y Lizeth Caicedo

---

## Contexto

El framework deja abierta la elección del cliente HTTP. ManiCita la tomó en la práctica:
[`api-networking.md`](../../../03-api-and-data/api-networking.md) dice "un solo cliente `axios`"
y `beauty-salon-app/src/core/network/httpClient.ts` lo implementa. Pero la decisión nunca se
registró como ADR, así que no constaba por qué axios ni qué se descartó. El checklist de cierre del
corte pide una ADR por cada decisión técnica abierta, y el cliente HTTP es una de las cuatro que
nombra.

Lo que el cliente tiene que resolver, según `api-networking.md` y
[`authentication.md`](../../../03-api-and-data/authentication.md):

- Reintentar **solo** las lecturas (`GET`) ante fallas transitorias, con 300 ms y 900 ms de espera;
  nunca un `POST` o un `PATCH`, porque reintentar `POST /v1/appointments` podría crear dos citas.
- Poner un `X-Request-Id` en cada petición.
- Traducir cada error `problem+json` a un error tipado que conserve `code` y `detail`.
- Timeouts distintos por tipo de petición (lecturas, disponibilidad, escrituras).
- Ante un 401, refrescar el token **una sola vez** aunque haya varias peticiones fallando al mismo
  tiempo, y reintentar todas con el token nuevo.

**Restricciones conocidas:**
- Todo eso tiene que pasar en un solo lugar (`core/network/`), no repartido en cada feature.
- Los casos de uso no conocen el cliente: reciben repositorios inyectados
  ([ADR-008](./ADR-008-dependency-injection.md)).

---

## Decisión

**Decidimos:** una **única instancia de axios**, creada en `src/core/network/httpClient.ts`, con
interceptores de petición (`X-Request-Id`) y de respuesta (reintento de lecturas y traducción de
errores). Ninguna feature crea su propio cliente ni llama a `fetch` directamente.

**Justificación:**
- Los interceptores de axios son exactamente el punto donde viven el reintento, el `X-Request-Id`,
  la traducción de errores y, cuando se construya auth, el refresco del token. Con `fetch` habría
  que escribir y probar ese envoltorio a mano.
- Para el refresco con varias peticiones en vuelo, el patrón con interceptores de axios (cola de
  peticiones que esperan el token nuevo) está muy documentado; es la parte más delicada del cliente
  y la que menos conviene inventar.
- Ya estaba instalado y funcionando en la feature `catalog`.

---

## Alternativas evaluadas

| Alternativa | Pros | Contras | Motivo de descarte |
|-------------|------|---------|--------------------|
| axios, una instancia con interceptores (elegida) | Interceptores de petición y respuesta; timeout por petición; errores con la respuesta adjunta | Una dependencia de ~14 KB gzip; solo tiene timeout total, no separa conexión y respuesta | — (elegida) |
| `fetch` nativo con un envoltorio propio | Cero dependencias | Hay que escribir los interceptores, el timeout (`AbortController`) y la cola de refresco; `fetch` no falla en 4xx/5xx y hay que revisar `ok` en cada llamada | Mucho código propio para lo que axios ya trae probado |
| `ky` (envoltorio de `fetch`) | Liviano; reintentos y hooks incluidos | Su reintento automático se configura por método y es fácil dejar uno activo en `POST`; menos ejemplos del refresco con cola | Ahorra poco frente a axios y agrega riesgo justo en la regla más importante (no reintentar escrituras) |
| `CapacitorHttp` (HTTP nativo de Capacitor) | Las peticiones salen desde Android, sin CORS del WebView | No tiene interceptores; no funciona igual en `npm run dev` en el navegador, que es donde se desarrolla | Obligaría a dos caminos de red, uno para el navegador y otro para el dispositivo |

---

## Consecuencias

**Positivas:**
- Todo el comportamiento de red está en un archivo, y se prueba en un solo lugar.
- Las features reciben errores de dominio (`ConflictError`, `ValidationFailedError`…) con `code`, no
  errores de axios.

**Negativas / costos:**
- axios solo tiene **timeout total**. La tabla de `api-networking.md` distingue timeout de conexión y
  de respuesta; el código usa el de respuesta por perfil (`requestProfiles.ts`: 10 s lecturas, 8 s
  disponibilidad, 15 s escrituras). La diferencia queda declarada en ese archivo y en
  `api-networking.md`.
- El refresco del token ante un 401 **todavía no está implementado**: el interceptor lo anota como
  pendiente hasta que exista la feature `auth` (HU-11 del tablero).

**Impacto en el sistema:**
- Features afectadas: todas las que hablan con la API.
- Documento que la aplica: [`03-api-and-data/api-networking.md`](../../../03-api-and-data/api-networking.md).

---

## Referencias

- [axios: interceptores](https://axios-http.com/docs/interceptors)
- Relacionada con: [ADR-008](./ADR-008-dependency-injection.md) (los repositorios reciben el cliente), [ADR-013](./ADR-013-herramientas-de-prueba.md) (el cliente se reemplaza por un falso en las pruebas de los repositorios)
