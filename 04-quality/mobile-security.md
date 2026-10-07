# Seguridad móvil (checklist antes de cada release)

Complementa [`00-governance/security-rules.md`](../00-governance/security-rules.md): allá están las
reglas y el inventario de datos sensibles; aquí, **cómo se verifica cada una antes de sacar un
build**, en Ionic + Capacitor sobre Android y en la API Express.

Cada release copia esta lista en su checklist ([`05-release/releases/`](../05-release/releases/))
y la marca. La columna **Estado al 2026-10-07** dice cómo está hoy, para que el primer release no
descubra los pendientes el día de la entrega.

> Recordatorio del inventario: el riesgo de ManiCita **no es financiero, es de privacidad**. El
> historial de citas dice a qué hora y en qué dirección estará una mujer determinada. Los puntos que
> protegen eso (almacenamiento, cierre de sesión, roles) son los que no se negocian.

---

## Almacenamiento en el dispositivo

| Check | Cómo se verifica | Estado al 2026-10-07 |
|-------|------------------|----------------------|
| Los tokens se guardan solo en el Keystore de Android vía `capacitor-secure-storage-plugin` | Revisar que el único acceso a tokens sea `src/core/storage/secureStorage.ts`; buscar `localStorage`, `Preferences` y `sessionStorage` en `src/` (no debe haber tokens ahí) | ✅ el módulo existe y es el único punto. Se verifica de nuevo cuando se construya auth (HU-08 a HU-13) |
| SQLite guarda solo la caché del catálogo y las citas **propias** de la clienta | Las tablas locales son las cuatro de [`03-api-and-data/README.md`](../03-api-and-data/README.md); ninguna guarda la agenda del negocio | ✅ esquema local v2 con `service`, `business` y `professional`; `appointment` llega en la v3 con la feature de citas |
| Cerrar sesión borra tokens, la base local y el caché de imágenes | Prueba manual de [TC-009](./test-cases/TC-009-cerrar-sesion-revoca.md) más inspección de la base con `chrome://inspect` | ⏳ el cierre de sesión todavía no existe en la app (HU-12) |
| El respaldo automático de Android no copia la base local | `android:allowBackup="false"` en `AndroidManifest.xml` | ❌ hoy está en `true`: Google Drive podría respaldar la caché con las citas de la clienta |
| Ningún dato personal que la app no necesite queda en caché | El celular de la clienta no viaja en el catálogo; la agenda no se cachea | ✅ por contrato |

## Transporte

| Check | Cómo se verifica | Estado al 2026-10-07 |
|-------|------------------|----------------------|
| El build de release habla con la API solo por HTTPS | `VITE_API_BASE_URL` del build de release empieza por `https://` | ⏳ no hay URL de producción ni despliegue de la API (hueco H-01 de [`api-contract.md`](../03-api-and-data/api-contract.md)) |
| HTTP en claro solo en builds de desarrollo | `cleartextTrafficPermitted` permitido únicamente en el `network_security_config` de la variante `debug` | ⏳ sin configurar; hoy se desarrolla contra `http://localhost:3000/v1` |
| Certificate pinning en los endpoints de autenticación | Plugin de pinning de Capacitor configurado con el certificado del dominio de la API | ⏳ depende de H-01: no se puede fijar el certificado de un dominio que no existe |
| CORS de la API limitado al origen de la app en producción | Revisar la configuración de `cors` en `beauty-salon-api` | ⏳ abierto a todo origen (hueco H-02) |

## Permisos

| Check | Cómo se verifica | Estado al 2026-10-07 |
|-------|------------------|----------------------|
| Solo los permisos mínimos | `AndroidManifest.xml`: hoy solo `INTERNET`. Notificaciones y cámara se agregan cuando exista la feature que los usa, y se piden en el momento de usarlos | ✅ |
| Ningún permiso "por si acaso" | No hay permisos declarados sin una feature que los use | ✅ |

## Build

| Check | Cómo se verifica | Estado al 2026-10-07 |
|-------|------------------|----------------------|
| R8/ProGuard activo en `release` | `minifyEnabled true` en `android/app/build.gradle`, tipo `release` | ❌ hoy en `false` |
| Sin `console.*` en el JavaScript de release | `esbuild: { drop: ['console', 'debugger'] }` en `vite.config.ts` para el modo producción | ❌ sin configurar |
| Identificador propio de la app | `appId` en `capacitor.config.ts` distinto de `io.ionic.starter`, y `appName` = ManiCita | ❌ sigue el del andamiaje (`io.ionic.starter`, `frontend`). **Se cambia antes del primer APK firmado**: después de publicado, cambiar el `appId` es publicar otra app |
| Ninguna credencial en el repo ni en el bundle | `git ls-files` sin `.env`, `.jks` ni `.keystore`; el bundle no contiene secretos (Vite solo expone variables `VITE_*`, y ninguna es secreta) | ✅ en los tres repos de código solo se versiona `.env.example` |
| El APK se firma con la llave de release, no la de debug | `apksigner verify --print-certs` sobre el APK del release | ⏳ sin llave de release todavía (ver [`05-release/signing-and-stores.md`](../05-release/signing-and-stores.md)) |

## Dependencias

| Check | Cómo se verifica | Estado al 2026-10-07 |
|-------|------------------|----------------------|
| Sin vulnerabilidades altas o críticas en dependencias de producción | `npm audit --omit=dev --audit-level=high` en `beauty-salon-app` y en `beauty-salon-api` | ⏳ no se ha corrido como parte de un release |
| Ningún SDK de terceros recolecta datos sin que se sepa | Revisar `dependencies` de la app: hoy no hay SDK de analítica ni de publicidad | ✅ |

## API (lo que protege a la app desde el servidor)

| Check | Cómo se verifica | Estado al 2026-10-07 |
|-------|------------------|----------------------|
| Cada ruta exige el rol correcto y cada recurso se valida contra su dueño | Sondas `FORBIDDEN_ROLE` y `FORBIDDEN_RESOURCE` del smoke test; [TC-008](./test-cases/TC-008-cada-rol-ve-lo-suyo.md) | ✅ |
| Contraseñas con bcrypt; nunca en respuestas ni en logs | Revisar `src/modules/auth` | ✅ |
| El refresh token rota y se revoca al cerrar sesión | Sondas de refresh y logout; [TC-009](./test-cases/TC-009-cerrar-sesion-revoca.md) | ✅ |
| Los errores no filtran detalles internos | Todo error sale como `problem+json` con `code` estable; nunca un 500 con traza | ✅ |
| El correo es único sin importar mayúsculas también en la base | Índice único sobre `lower(email)` | ⏳ hoy solo lo garantiza el código (deuda D-01 de [`data-model.md`](../03-api-and-data/data-model.md)) |

---

## Pendientes que bloquean el primer APK firmado

Estos cuatro se resuelven antes de `v0.2.0`; los demás ⏳ dependen de features o del despliegue:

1. `appId` y `appName` propios.
2. `android:allowBackup="false"`.
3. `minifyEnabled true` en `release`.
4. `console` eliminado del build de producción.
