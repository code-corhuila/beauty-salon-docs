# Pantalla — LoginScreen

- **Ruta:** `/login`
- **Feature:** [Autenticación](../features/auth.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  No hay Figma: los mockups se derivan de este documento, y el boceto a mano del cuaderno de trabajo
  del Sprint 1 queda como apoyo.

---

## Propósito

Entrar a la cuenta con correo y contraseña. Aparece solo cuando la acción lo exige (agendar o
publicar), nunca al abrir la app.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Logo y título | Explica por qué se pide la sesión: "Inicia sesión para agendar" |
| Cuerpo | [CampoFormulario](../../02-code-and-ui/components/campo-formulario.md) x2 | Correo y contraseña, con mostrar/ocultar contraseña |
| Pie | [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) | Entrar. Debajo, enlace a `/register` |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Verificando credenciales | Botón en estado `loading`, campos deshabilitados |
| Loaded | Formulario listo | Campos editables, botón activo cuando ambos tienen valor |
| Empty | No aplica | Es un formulario: nunca está vacío de contenido |
| Error | Credenciales inválidas o fallo de red | Credenciales: mensaje bajo el campo. Red: banner arriba con reintentar |
| Offline | Sin conexión | Botón deshabilitado y aviso de que se necesita conexión para entrar |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Escribir correo y contraseña | Se habilita el botón | — (validación local) |
| Tocar Entrar | Autentica y vuelve a la ruta pretendida, o al inicio de su rol | `signIn` |
| Tocar Crear cuenta | Navega a `/register` conservando la ruta pretendida | — |

---

## Accesibilidad

- [ ] Los dos campos tienen etiqueta visible y `aria-label`.
- [ ] El botón de mostrar contraseña anuncia su estado, no solo cambia de ícono.
- [ ] Área táctil mínima de 48x48 dp en el botón de mostrar contraseña.
- [ ] El texto escala con el tamaño de fuente del sistema sin romper el formulario.
- [ ] El error de credenciales se anuncia al lector de pantalla, no solo se pinta de rojo.
- [ ] Contraste AA en el mensaje de error sobre el fondo del campo.
