# Firma y distribución

ManiCita sale **solo para Android** ([ADR-005](../01-architecture/decisions/records/ADR-005-mobile-stack-ionic-capacitor.md))
y **no se publica en Google Play** durante el semestre: el APK firmado se distribuye adjunto a un
GitHub Release ([ADR-014](../01-architecture/decisions/records/ADR-014-distribucion-github-releases.md)).
Por eso este documento no tiene sección de iOS ni de metadatos de tienda.

---

## Firma

- **Una sola llave de release** (`manicita-release.jks`), generada con `keytool`, con validez de
  25 años o más. Se genera una vez, antes del primer APK firmado.
- La llave **nunca entra a un repositorio**. Vive en dos lugares:
  1. En los **secretos de GitHub Actions** de `beauty-salon-app`, en base64:
     `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` y
     `ANDROID_KEY_PASSWORD`.
  2. En una **copia de respaldo** que guardan las dos integrantes del equipo (Lilly y Lizeth), fuera
     del computador de desarrollo.
- **Perder la llave significa no poder actualizar más la app**: Android rechaza una actualización
  firmada con otra llave, y la única salida sería desinstalar y reinstalar en cada celular. Por eso
  la copia de respaldo no es opcional.
- Si alguien sale del equipo, se cambian las contraseñas de los secretos de CI. La llave en sí no se
  puede cambiar sin romper las actualizaciones, así que se protege su acceso desde el principio.
- Los builds de depuración se firman con la llave de debug de Android Studio y **nunca** se entregan.

## Identidad de la app

Antes del primer APK firmado, `capacitor.config.ts` deja de tener los valores del andamiaje:

| Campo | Hoy | Debe ser |
|-------|-----|----------|
| `appId` | `io.ionic.starter` | Un identificador propio, por ejemplo `co.edu.corhuila.manicita` |
| `appName` | `frontend` | `ManiCita` |

> El `appId` es la identidad de la app en Android. Cambiarlo después de instalada es, para el
> celular, instalar **otra** app. Se decide una vez y no se toca.

---

## Versionado

- `versionName` = la versión SemVer de `package.json` (`0.1.0`, `0.2.0`, `1.0.0`), la misma del tag
  `vX.Y.Z` ([`git-conventions.md`](../00-governance/git-conventions.md)).
- `versionCode` = `MAJOR × 10000 + MINOR × 100 + PATCH`: `0.1.0` → `100`, `0.2.0` → `200`,
  `1.0.0` → `10000`. Así siempre crece, nunca se repite, y se calcula desde la versión sin llevar un
  contador aparte. CI lo inyecta en `android/app/build.gradle` al construir el release.
- Hoy los tres números están desalineados: `package.json` dice `0.0.1`, y `build.gradle` dice
  `versionName "1.0"` con `versionCode 1`. Se alinean en el primer release.

---

## Distribución escalonada

Sin tienda no hay porcentajes de despliegue, pero el principio se mantiene: **nadie recibe un build
que no haya pasado por alguien antes**.

| Paso | Quién instala | Cuándo se avanza |
|------|---------------|------------------|
| 1 | Las dos integrantes, en el emulador y en un celular propio | Pasan los [casos de prueba](../04-quality/test-cases/) que aplican al release |
| 2 | La **manicurista aliada**, en su celular | Usa la app un día de trabajo sin un fallo que le impida agendar |
| 3 | Las clientas de la manicurista, con el enlace al GitHub Release | — |

**Se detiene** el avance si aparece un cierre inesperado, un cupo agendado dos veces o una cita que
no llega a la agenda del negocio.

## Actualización forzada

- La app no tiene todavía una bandera remota de versión mínima. La protección contra cambios
  rompientes la da el **versionado de la API**: un cambio rompiente sube a `/v2`, y `/v1` sigue
  viva mientras haya APK publicados que la usen ([`api-contract.md`](../03-api-and-data/api-contract.md) §9).
- Si algún día hiciera falta forzar una actualización (una corrección de seguridad), la app
  enviaría su versión en cada petición, y la API respondería a las versiones viejas con un código
  propio (por ejemplo `APP_VERSION_UNSUPPORTED`) que la app mostraría como "actualiza la app".
  Nada de eso existe todavía: queda como deuda S-02.

## Volver atrás

- El APK del release anterior **sigue adjunto** a su GitHub Release; los releases no se borran.
- Android no deja instalar un `versionCode` menor encima de uno mayor. Volver atrás es desinstalar e
  instalar el APK anterior; se pierde la caché local, que es solo caché (las citas viven en el
  servidor). La salida preferida es sacar un `PATCH` con la corrección.
- **Quién decide:** quien figure como responsable del release en su checklist, con aviso a la otra
  integrante. **Cuándo:** con cualquiera de las tres señales de "se detiene" de arriba.

---

## Deuda

| ID | Qué falta | Responsable | Fecha |
|----|-----------|-------------|-------|
| S-01 | Generar la llave de release, cargarla en los secretos de CI y guardar la copia de respaldo | _por asignar_ | _por asignar_ |
| S-02 | Señal de versión mínima para forzar actualizaciones | _por asignar_ | _por asignar_ |
| S-03 | Cambiar `appId` y `appName` y alinear `versionName` y `versionCode` | _por asignar_ | _por asignar_ |
