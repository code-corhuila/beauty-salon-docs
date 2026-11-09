# Test Case — TC-010 · El catálogo se ve sin conexión

> Copia de [`_template-test-case.md`](../_template-test-case.md). Es el único caso que hoy se puede
> ejecutar completo en la app, porque `catalog` es la feature construida. La prueba de componente
> automatizada está pendiente (Q-02 en [`testing-strategy.md`](../testing-strategy.md)).

- **ID:** TC-010
- **Related story:** HU-003 explorar y elegir el servicio ([catalog](../../01-architecture/features/catalog.md))
- **Feature / screen:** catalog · [Catálogo](../../01-architecture/screens/catalogo.md)
- **Platform(s):** Android (emulador API 34)
- **Type:** Functional

**Regla que protege:** la clienta muchas veces abre la app ya en el salón, con mala señal. Ver los
servicios no puede depender de la red; agendar sí (ver TC-002).

---

## Preconditions

- La API levantada con al menos un servicio publicado.
- La app instalada en el emulador y apuntando a esa API.

---

## Steps

| # | Action | Expected result |
|---|--------|-----------------|
| 1 | Abrir la app con conexión | El catálogo muestra los servicios publicados |
| 2 | Cerrar la app por completo y activar el modo avión | — |
| 3 | Abrir la app de nuevo | El catálogo muestra los mismos servicios **desde la caché**, con un aviso de que no hay conexión |
| 4 | Abrir el detalle de un servicio | El detalle se ve desde la caché, y el botón de agendar está deshabilitado con la explicación de que no hay conexión |
| 5 | Desactivar el modo avión y deslizar para recargar | El catálogo se actualiza desde la API |
| 6 | Desinstalar y reinstalar la app, y abrirla en modo avión | Estado de error con opción de reintentar, no una pantalla en blanco: sin caché no hay nada que mostrar |

---

## Result

- **Status:** ✅ Pasó tras corregir un defecto
- **Build:** app `debug` de `fix/app-cache-catalogo` (PR app #27), contra la API local
- **Device / OS:** Windows 11 con Docker Desktop 28.3.2; emulador Android 16 (API 36, x86_64, WebView 133)
- **Notes / defects:** Pasos de API: [`ejecutar-pasos-api.ps1`](./ejecutar-pasos-api.ps1) el 2026-11-08. Pasos de app: en el emulador, manejando el WebView por DevTools Protocol (lo mismo que `chrome://inspect`) y `adb`. **Defecto D-B (corregido en el PR app #27):** en la primera ejecución, los pasos 3 y 4 fallaron: sin conexión el catálogo mostraba tarjetas vacías ("$ NaN", sin nombre), porque el plugin de SQLite devuelve objetos y drizzle esperaba arreglos. Con el arreglo: paso 3, 20 servicios desde la caché con nombre, precio y salón, y aviso de sin conexión; paso 4, detalle desde la caché con Agendar deshabilitado ("Necesitas conexión para agendar"); paso 5, al reconectar y deslizar, el catálogo se recargó y el aviso desapareció (el deslizamiento se hizo con eventos táctiles en el WebView: `adb input swipe` no activa el refresher); paso 6, reinstalada y en modo avión, "No se pudo cargar el catálogo" con Reintentar. **Defecto D-C (sin corregir):** el aviso dice "Mostrando la última actualización del ." con la fecha vacía: `CatalogScreen` pasa `fecha: ''` porque la caché no expone cuándo se actualizó.
