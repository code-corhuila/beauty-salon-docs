# Presupuestos de rendimiento

Se fija un presupuesto, se mide, y pasarse es un defecto que bloquea el release.

## Para quién se presupuesta

ManiCita la usan una manicurista independiente y sus clientas, en **celulares Android de gama
media o baja** y casi siempre con **datos móviles**. La app es Ionic + Capacitor: la interfaz corre
dentro del WebView de Android ([ADR-005](../01-architecture/decisions/records/ADR-005-mobile-stack-ionic-capacitor.md)),
así que el arranque incluye levantar el WebView y cargar el JavaScript. Por eso algunos números son
más holgados que los del framework, que piensa en apps nativas.

**Dispositivos de referencia:** el emulador Android API 34 de Android Studio para medir en cada
sprint, y una vez por sprint el celular físico de la manicurista aliada (la DoD ya lo pide).

---

## Presupuestos

| Métrica | Presupuesto | Línea base medida | Cómo se mide |
|---------|-------------|-------------------|--------------|
| Arranque en frío hasta el catálogo con datos | **≤ 3 s** | _pendiente: se mide en el primer build release_ | `adb shell am start -W -n <appId>/.MainActivity` (campo `TotalTime`) más el tiempo hasta que la lista se pinta, en el panel Performance de `chrome://inspect` |
| Catálogo visible **sin conexión** (desde la caché SQLite) | **≤ 1 s** después del arranque | _pendiente_ | Mismo procedimiento, con el modo avión activo |
| JavaScript inicial de la app (gzip) | **≤ 400 KB** | **362 KB** (`index-*.js`, build del 2026-09-25) | `npm run build` y `gzip -c dist/assets/index-*.js \| wc -c` |
| Hojas de estilo (gzip) | **≤ 20 KB** | **8,5 KB** | Igual que el anterior |
| Tamaño del APK de release | **≤ 20 MB** | _pendiente: aún no hay build release_ | Tamaño del `.apk` firmado que adjunta el GitHub Release |
| Desplazamiento del catálogo | **60 fps** sin saltos con 50 servicios cargados | _pendiente_ | Panel Performance de `chrome://inspect` sobre el WebView del dispositivo |
| Página del catálogo | **20 servicios** por página (valor por omisión del contrato) | ✅ cumple | [`api-contract.md`](../03-api-and-data/api-contract.md) §1.4 |
| Disponibilidad de un servicio | **un solo día** por consulta | ✅ cumple: `date` es obligatorio | [`booking-availability.md`](../03-api-and-data/endpoints/booking-availability.md) |
| Respuesta de la API, p95, en local | **≤ 300 ms** por endpoint | _pendiente_ | Tiempos que reporta el smoke test sobre `beauty-salon-infra` |
| Memoria | Estable al navegar catálogo → detalle → catálogo 20 veces; sin fugas | _pendiente_ | Profiler de memoria de Android Studio |

> **Por qué 3 s y no 2 s.** Una app nativa pinta su primer cuadro sin cargar un motor de
> JavaScript; una de Capacitor no. Prometer 2 s en un celular de gama baja sería un presupuesto que
> se incumple desde el día uno, y un presupuesto que nunca se cumple se deja de mirar. Si la línea
> base del primer build release sale muy por debajo, el presupuesto se baja.

---

## Reglas

- **Medir antes de optimizar**, con las herramientas de arriba. No se optimiza por intuición.
- Las pantallas se cargan por ruta (`React.lazy`) a medida que se agreguen features: el catálogo no
  tiene por qué cargar el código del formulario del negocio.
- Listas largas paginadas: el catálogo pide de a 20 y la agenda del negocio es de un día.
- Los cupos y la agenda **no se cachean** (por regla de negocio, no por rendimiento): cada consulta
  trae solo un día, así que se mantiene pequeña.
- Las pantallas se pintan desde el estado inmutable del store de Zustand; nada de recalcular la
  lista completa en cada pulsación.
- El tamaño del JavaScript y del APK se anota en cada release. Un salto de más del **10%** frente al
  release anterior se justifica en la checklist o no sale.

---

## Hallazgos de la línea base

- **El build genera cada archivo dos veces.** `@vitejs/plugin-legacy` produce una copia "legacy"
  de cada paquete (`index-legacy-*.js`, 1,6 MB sin comprimir) para navegadores viejos. Dentro de un
  APK con `minSdkVersion 24` y el WebView actualizado por Google Play, esa copia casi nunca se usa,
  pero viaja en el APK. Deuda P-01.
- **`jeep-sqlite` (78 KB gzip) solo hace falta en el navegador.** En Android, SQLite es nativo vía
  `@capacitor-community/sqlite`; `jeep-sqlite` es el respaldo web para desarrollar con `npm run dev`.
  Ya se carga en un archivo aparte, así que no pesa en el arranque de Android.

| ID | Qué falta | Responsable | Fecha |
|----|-----------|-------------|-------|
| P-01 | Evaluar quitar `@vitejs/plugin-legacy` y medir cuánto baja el APK | _por asignar_ | _por asignar_ |
| P-02 | Medir la línea base de arranque, APK, fps y memoria en el primer build release | _por asignar_ | _por asignar_ |

---

## En CI y en el release

- El job de build de la app imprime el tamaño gzip del JavaScript inicial y falla si pasa de 400 KB
  (ver [`05-release/ci-cd.md`](../05-release/ci-cd.md)).
- El arranque en frío y el tamaño del APK se anotan a mano en la checklist del release
  ([`05-release/releases/`](../05-release/releases/)) y se comparan con el release anterior.
