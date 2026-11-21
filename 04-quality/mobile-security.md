# Seguridad móvil (checklist antes de cada release)

Complementa [`00-governance/security-rules.md`](../00-governance/security-rules.md): allá están las
reglas y el inventario de datos sensibles; aquí, **cómo se verifica cada una antes de sacar un
build**, en Ionic + Capacitor sobre Android y en la API Express.

Cada release copia esta lista en su checklist ([`05-release/releases/`](../05-release/releases/))
y la marca. La columna **Estado al 2026-11-16** dice cómo está hoy (revisada después de la sustentación), para que el primer release no
descubra los pendientes el día de la entrega.

> Recordatorio del inventario: el riesgo de ManiCita **no es financiero, es de privacidad**. El
> historial de citas dice a qué hora y en qué dirección estará una mujer determinada. Los puntos que
> protegen eso (almacenamiento, cierre de sesión, roles) son los que no se negocian.

---

## Almacenamiento en el dispositivo

| Check | Cómo se verifica | Estado al 2026-11-16 |
|-------|------------------|----------------------|
| Los tokens se guardan solo en el Keystore de Android vía `capacitor-secure-storage-plugin` | Revisar que el único acceso a tokens sea `src/core/storage/secureStorage.ts`; buscar `localStorage`, `Preferences` y `sessionStorage` en `src/` (no debe haber tokens ahí) | ✅ es el único punto. **En el navegador** (respaldo web, solo desarrollo y demo) el plugin guardaba los tokens en `localStorage` en base64; desde el 2026-11-12 en web viven **solo en memoria** y al arrancar se borran los que quedaron de versiones anteriores (app PR #40, `secureStorage.test.ts`). Recargar la pestaña cierra la sesión en web; en Android no cambia nada |
| SQLite guarda solo la caché del catálogo y las citas **propias** de la clienta | Las tablas locales son las cuatro de [`03-api-and-data/README.md`](../03-api-and-data/README.md); ninguna guarda la agenda del negocio | ✅ esquema local v2 con `service`, `business` y `professional`; `appointment` llega en la v3 con la feature de citas |
| Cerrar sesión borra tokens, la base local y el caché de imágenes | Prueba manual de [TC-009](./test-cases/TC-009-cerrar-sesion-revoca.md) más inspección de la base con `chrome://inspect` | ✅ existe desde HU-12 (`endSession`). Desde el 2026-11-13 en el navegador también se borra la copia de la base en IndexedDB: `jeep-sqlite` no la guardaba ni la vaciaba sin `saveToStore` (app PR #41) |
| El respaldo automático de Android no copia la base local | `android:allowBackup="false"` en `AndroidManifest.xml` | ✅ en `false` desde el PR app #21 (2026-11-08) |
| Ningún dato personal que la app no necesite queda en caché | El celular de la clienta no viaja en el catálogo; la agenda no se cachea | ✅ por contrato. Además, la caché borra los servicios pausados o eliminados y los negocios y profesionales que se quedan sin servicios: la dirección de un negocio, que puede ser una casa, no se guarda más de lo necesario (app PR #41) |

## Transporte

| Check | Cómo se verifica | Estado al 2026-11-16 |
|-------|------------------|----------------------|
| El build de release habla con la API solo por HTTPS | `VITE_API_BASE_URL` del build de release empieza por `https://` | ⏳ no hay URL de producción ni despliegue de la API (hueco H-01 de [`api-contract.md`](../03-api-and-data/api-contract.md)) |
| HTTP en claro solo en builds de desarrollo | `cleartextTrafficPermitted` permitido únicamente en el `network_security_config` de la variante `debug` | ✅ solo en `src/debug/res/xml/network_security_config.xml`, hacia `10.0.2.2`, `localhost` y `127.0.0.1` (app PR #26). Para probar en un celular físico se agrega la IP del equipo solo al compilar y no se versiona |
| Certificate pinning en los endpoints de autenticación | Plugin de pinning de Capacitor configurado con el certificado del dominio de la API | ⏳ depende de H-01: no se puede fijar el certificado de un dominio que no existe |
| CORS de la API limitado al origen de la app en producción | Revisar la configuración de `cors` en `beauty-salon-api` | 🟡 la API ya limita los orígenes con `CORS_ORIGINS` (2026-11-08); falta fijar el dominio de producción, que no existe todavía (H-01) |

## Permisos

| Check | Cómo se verifica | Estado al 2026-11-16 |
|-------|------------------|----------------------|
| Solo los permisos mínimos | `AndroidManifest.xml`: hoy solo `INTERNET`. Notificaciones y cámara se agregan cuando exista la feature que los usa, y se piden en el momento de usarlos | ✅ |
| Ningún permiso "por si acaso" | No hay permisos declarados sin una feature que los use | ✅ |

## Build

| Check | Cómo se verifica | Estado al 2026-11-16 |
|-------|------------------|----------------------|
| R8/ProGuard activo en `release` | `minifyEnabled true` en `android/app/build.gradle`, tipo `release` | 🟡 activo desde el PR app #21; falta compilar el APK de release y probarlo instalado (no hubo Android SDK al hacer el cambio) |
| Sin `console.*` en el JavaScript de release | `build.rolldownOptions.output.minify.compress.dropConsole` en `vite.config.ts`. **`esbuild.drop` no sirve:** Vite 8 minifica con Rolldown y esa opción no tiene efecto (se comprobó en el build). Se verifica buscando los mensajes de `console` del propio código en `dist/assets` | 🟡 desde el PR app #21. Queda una llamada indirecta de Ionic (Stencil) en el bundle moderno, y los archivos `-legacy`, que el WebView de Capacitor 8 no carga |
| Identificador propio de la app | `appId` en `capacitor.config.ts` distinto de `io.ionic.starter`, y `appName` = ManiCita | 🟡 `co.edu.corhuila.manicita` y `ManiCita` desde el PR app #21. **No se vuelve a cambiar**: después de publicado, cambiar el `appId` es publicar otra app |
| Ninguna credencial en el repo ni en el bundle | `git ls-files` sin `.env`, `.jks` ni `.keystore`; el bundle no contiene secretos (Vite solo expone variables `VITE_*`, y ninguna es secreta) | ✅ en los tres repos de código solo se versiona `.env.example` |
| El APK se firma con la llave de release, no la de debug | `apksigner verify --print-certs` sobre el APK del release | ⏳ sin llave de release todavía (ver [`05-release/signing-and-stores.md`](../05-release/signing-and-stores.md)) |

## Dependencias

| Check | Cómo se verifica | Estado al 2026-11-16 |
|-------|------------------|----------------------|
| Sin vulnerabilidades altas o críticas en dependencias de producción | `npm audit --omit=dev --audit-level=high` en `beauty-salon-app` y en `beauty-salon-api` | ✅ app: 0 altas desde el 2026-11-12 (`follow-redirects` 1.16.0 → 1.16.3, app PR #40). API: 0. **Riesgo aceptado:** 8 moderadas en la app, de `react-router` 6 (la v7 que las corrige no funciona con `@ionic/react-router` 9; las fallas son un redirect con `\` en `<Link>`/`useNavigate` y la hidratación SSR, y la app solo navega a rutas fijas y no usa SSR) y de herramientas de compilación de Ionic (`ts-morph`, `minimatch`), que no llegan al APK |
| Ningún SDK de terceros recolecta datos sin que se sepa | Revisar `dependencies` de la app: hoy no hay SDK de analítica ni de publicidad | ✅ |

## API (lo que protege a la app desde el servidor)

| Check | Cómo se verifica | Estado al 2026-11-16 |
|-------|------------------|----------------------|
| Cada ruta exige el rol correcto y cada recurso se valida contra su dueño | Sondas `FORBIDDEN_ROLE` y `FORBIDDEN_RESOURCE` del smoke test; [TC-008](./test-cases/TC-008-cada-rol-ve-lo-suyo.md) | ✅ |
| Contraseñas con bcrypt; nunca en respuestas ni en logs | Revisar `src/modules/auth` | ✅ |
| El refresh token rota y se revoca al cerrar sesión | Sondas de refresh y logout; [TC-009](./test-cases/TC-009-cerrar-sesion-revoca.md) | ✅ |
| Recuperar la contraseña no sirve para averiguar qué correos tienen cuenta | E-23 responde el mismo 202 y el mismo texto exista o no la cuenta, y también si falla el envío; E-24 da el mismo 400 `INVALID_RESET_CODE` para correo sin cuenta y para código errado. Sondas "correo sin cuenta" y [TC-011](./test-cases/TC-011-recuperar-contrasena.md) | ✅ desde el 2026-11-16 |
| El código de recuperación no se puede adivinar ni reusar | 6 números aleatorios (`crypto.randomInt`), guardado solo como HMAC-SHA256 y comparado en tiempo constante; vence a los 15 minutos, se agota a los 5 intentos errados, sirve una vez y pedir uno nuevo anula el anterior. A lo sumo un correo por minuto por cuenta. `passwordReset.service.test.js` (12) | ✅ desde el 2026-11-16. Con 5 intentos sobre un millón de códigos, adivinar es 1 en 200 000 por código pedido |
| Cambiar la contraseña cierra las sesiones abiertas | E-24 pone `password_changed_at` y E-03 rechaza los `refreshToken` emitidos antes (401). El `accessToken` que ya tenga otro dispositivo vive hasta 60 minutos más, igual que tras cerrar sesión | ✅ desde el 2026-11-16 ([TC-011](./test-cases/TC-011-recuperar-contrasena.md) paso 7) |
| Los correos de prueba no salen a internet | En local la API envía por SMTP a **Mailpit** (`beauty-salon-infra`), publicado solo en `127.0.0.1:8025`. En producción se ponen los datos SMTP del proveedor real en `SMTP_*`; sin `SMTP_HOST` no se envía nada | 🟡 en local sí. Falta elegir el proveedor de correo de producción (depende de H-01) |
| Los errores no filtran detalles internos | Todo error sale como `problem+json` con `code` estable; nunca un 500 con traza | ✅ |
| El correo es único sin importar mayúsculas también en la base | Índice único sobre `lower(email)` | ✅ índice `uq_user_account_email_lower` desde la migración `0002_db_constraints.sql` (API PR #20, 2026-11-12). La misma migración cierra D-02, D-03 y D-05 en el motor |
| El motor rechaza datos que el código ya no deja pasar | Migración `0002`: duración 15–240, profesional del mismo negocio que el servicio, copias de la cita positivas y motivo solo en rechazadas. Se comprobó con una inserción manual inválida por regla | ✅ desde el 2026-11-12 (API PR #20) |
| Dos altas simultáneas no pasan el máximo de 20 profesionales | `createProfessional` bloquea la fila del negocio (`SELECT … FOR UPDATE`); prueba de carrera en `business.service.test.js` que falla sin el bloqueo | ✅ desde el 2026-11-12 (D-04, API PR #20) |
| Encabezados de seguridad, CORS por entorno y límite de intentos de login | `helmet`, `CORS_ORIGINS` y 5 intentos fallidos por 15 minutos (429 con `Retry-After`); pruebas en `app.test.js` y `loginLimiter.test.js` | ✅ desde el 2026-11-08 |
| La base de datos no queda expuesta a la red local | `docker-compose.yml` de infra publica PostgreSQL solo en `127.0.0.1`; la API sí escucha en todas las interfaces para el celular físico | ✅ desde el 2026-11-12 (infra PR #8). Comprobado: desde la IP de red del equipo la API responde y la base no |

---

## Pendientes que bloquean el primer APK firmado

Los cuatro tienen su cambio en el PR app #21 (2026-11-08). Quedan resueltos cuando ese PR llegue a
`main` y se compruebe un APK de release instalado:

1. ~~`appId` y `appName` propios.~~ `co.edu.corhuila.manicita` / `ManiCita`.
2. ~~`android:allowBackup="false"`.~~
3. ~~`minifyEnabled true` en `release`.~~ Falta probar el APK con R8.
4. ~~`console` eliminado del build de producción.~~ Con la opción de Rolldown, no la de esbuild.

El mismo PR registra en el proyecto Android los plugins nativos de SQLite y secure storage, que
faltaban: sin ellos, un APK compilado sin `npx cap sync` no tenía caché ni almacenamiento seguro.
