# Reglas de seguridad

Reglas no negociables para todos los builds de ManiCita.

## Qué datos sensibles maneja esta app

Antes de las reglas, el inventario: sin saber qué se protege, la regla es un adorno.

| Dato | De quién | Sensibilidad | Dónde vive |
|------|----------|--------------|------------|
| Nombre y celular de la clienta | Clienta | Alta: identifica a una persona y permite contactarla | Servidor; en el dispositivo solo el perfil de la sesión activa |
| Historial de citas | Clienta | Alta: revela ubicación, rutina y horarios habituales de una mujer | Servidor; caché local solo de las citas propias |
| Dirección y celular del negocio | Negocio | Media: es información pública del comercio, pero el celular no se expone en el catálogo hasta que hay cita confirmada | Servidor |
| Tokens de sesión | Ambos | Crítica: dan acceso a la cuenta | Solo Keystore de Android |
| Contraseña | Ambos | Crítica | Nunca se almacena en el dispositivo, ni siquiera cifrada |

> **El riesgo real de ManiCita no es financiero, es de privacidad.** No hay pagos en la app, pero el
> historial de citas dice a qué hora y en qué dirección estará una mujer determinada. Esa es la razón
> por la que el celular de la clienta no viaja en el catálogo público y por la que la sesión se limpia
> completa al cerrar sesión.

## Secretos y credenciales

- Nunca se commitean API keys, tokens ni credenciales, ni se empaquetan en texto plano en la app.
- Los secretos de build se inyectan desde CI como variables de entorno de build de **Vite** (archivos
  `.env` no versionados, leídos en tiempo de compilación con `import.meta.env`); las credenciales de
  firma del `.keystore` de Android viven en el almacén de secretos de CI, nunca en el repositorio.
  Nada de secretos en `capacitor.config.ts` versionado ni en un `.env` commiteado.
- Los tokens de usuario se guardan **solo** en el almacenamiento seguro de la plataforma (Keystore de
  Android) a través de un plugin de secure storage de Capacitor, nunca en `localStorage`,
  `@capacitor/preferences` sin cifrar, archivos ni en la base de datos local SQLite.

## Transporte

- Todo el tráfico va sobre TLS. En release no se permite HTTP en claro
  (`cleartextTrafficPermitted=false` en el `AndroidManifest.xml` generado por Capacitor).
- Certificate pinning en los endpoints de autenticación.

## Datos en reposo

- La base de datos local guarda solo lo que la app necesita sin conexión, y no guarda datos de
  clientas ajenas: la agenda del negocio se consulta en línea.
- Al cerrar sesión se borran los tokens, la base de datos local y el caché de imágenes.

## Permisos

- Se piden los permisos mínimos, en el momento en que se usan y con una explicación clara.
- ManiCita pide solo **notificaciones** (avisos de cita) y **cámara o galería** cuando el negocio
  sube la foto de un servicio. No se pide ubicación: el MVP muestra la dirección como texto.
- Ningún permiso se pide "por si acaso más adelante".

## Endurecimiento del build

- El build de release corre con minificación activa en Vite (esbuild/Terser) y, en el proyecto Android
  generado por Capacitor, con R8/ProGuard habilitado en `release`.
- Los `console.log` se eliminan del release configurando `esbuild.drop: ['console']` (o el equivalente
  en Terser) en `vite.config.ts`; nunca se registran tokens ni datos de la clienta.

## Manejo de vulnerabilidades

- Una vulnerabilidad sospechada se reporta en privado al docente, nunca en un issue público del repo.
- Las dependencias con vulnerabilidad conocida se actualizan dentro del sprint siguiente a la publicación.
