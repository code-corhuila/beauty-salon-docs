# Pantalla — ForgotPasswordScreen

- **Ruta:** `/forgot-password`
- **Feature:** [Autenticación](../features/auth.md)
- **Referencia de diseño:** los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md) y el
  mismo esqueleto de formulario de [Login](./login.md).
- **Agregada:** 2026-11-16, porque quien olvidaba la contraseña no tenía otra salida que crear una
  cuenta nueva con otro correo.

---

## Propósito

Que la persona que olvidó su contraseña la cambie sola, sin escribirle a nadie: pide un código al
correo de su cuenta, lo escribe junto con la contraseña nueva y vuelve a
[Login](./login.md) para entrar.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Botón atrás y título "Recupera tu contraseña" | Atrás vuelve a `/login` |
| Paso 1 · Correo | [CampoFormulario](../../02-code-and-ui/components/campo-formulario.md) | Llega lleno con el correo que se había escrito en Login. Texto: "Escribe el correo de tu cuenta y te enviamos un código de 6 números." |
| Paso 2 · Código | [CampoFormulario](../../02-code-and-ui/components/campo-formulario.md) x3 | **Código** (6 números, teclado numérico, ayuda "Los 6 números del correo. Vence en 15 minutos."), **Contraseña nueva** y **Repite la contraseña nueva** |
| Paso 2 · Enlaces | Dos enlaces de texto | **Reenviar código**, que espera 60 s con cuenta regresiva ("Puedes pedir otro código en N s"), y **Cambiar correo**, que vuelve al paso 1 y limpia el paso 2 |
| Pie | [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) | Paso 1: **Enviar código**. Paso 2: **Cambiar contraseña** |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Enviando el correo o cambiando la contraseña | Botón en estado `loading`, campos deshabilitados |
| Loaded | Paso 1 o paso 2 listo | Paso 1: **Enviar código** se activa cuando el correo tiene formato válido. Paso 2: banner informativo "Si {correo} tiene una cuenta, ya te llegó el código. Revisa también el correo no deseado." |
| Empty | No aplica | Es un formulario |
| Error | Código errado, vencido o usado; campos inválidos; fallo de red | Código: mensaje bajo el campo **Código** ("El código no es correcto o ya venció. Revisa el correo o pide uno nuevo."). Campos: mensaje bajo cada uno. Red: banner arriba. Lo escrito se conserva |
| Offline | Sin conexión | Banner "Necesitas conexión para recuperar tu contraseña." y botón deshabilitado |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Escribir el correo y tocar **Enviar código** | Pasa al paso 2. La respuesta es la misma exista o no la cuenta | `requestResetCode` |
| Escribir código y contraseña nueva, y tocar **Cambiar contraseña** | Valida en el teléfono; si cumple, cambia la contraseña y vuelve a `/login` con el correo lleno y el aviso "Listo, cambiaste tu contraseña. Entra con la nueva." | `resetPassword` |
| Tocar **Reenviar código** (después de 60 s) | Pide otro código; el anterior deja de servir | `requestResetCode` |
| Tocar **Cambiar correo** | Vuelve al paso 1 | — |

---

## Validación de los campos

| Campo | Mientras se escribe | Regla |
|-------|---------------------|-------|
| Correo | Sin espacios | Mismo formato que Login y Registro |
| Código | Solo números, hasta 6 | Exactamente 6 números: "Escribe los 6 números del código" |
| Contraseña nueva | Sin espacios | La misma regla del registro: de 8 a 64 caracteres, con al menos una letra y un número |
| Repite la contraseña nueva | Sin espacios | Igual a la anterior: "Las dos contraseñas no son iguales" |

Los errores del paso 2 aparecen después del primer intento de **Cambiar contraseña** y se actualizan
mientras se corrige. La regla local se escribe en `domain/passwordReset.ts`; la API vuelve a validar
todo y su mensaje es el que manda si no coinciden.

---

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| `requestResetCode` | [`POST /v1/auth/password/forgot`](../../03-api-and-data/endpoints/auth-password-forgot.md) | `UserAccount` (§2.1), `PasswordReset` (§2.8) | Ninguna |
| `resetPassword` | [`POST /v1/auth/password/reset`](../../03-api-and-data/endpoints/auth-password-reset.md) | `UserAccount` (§2.1), `PasswordReset` (§2.8) | Ninguna. No inicia sesión: la persona entra después en Login con la contraseña nueva |

---

## Accesibilidad

- [ ] Los campos tienen etiqueta visible; el código usa `autocomplete="one-time-code"` para que el
      teclado ofrezca el código del correo.
- [ ] El error del código se anuncia al lector de pantalla, no solo se pinta de rojo.
- [ ] La cuenta regresiva de **Reenviar código** se lee como texto, no solo como un botón apagado.
- [ ] Área táctil mínima de 48x48 dp en **Reenviar código** y **Cambiar correo**.
- [ ] El texto escala con el tamaño de fuente del sistema sin romper el formulario.
