# Pantalla — SignUpScreen

- **Ruta:** `/registro`
- **Feature:** [Autenticación](../features/auth.md)
- **Referencia de diseño:** [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html),
  dibujado con los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md).
  El boceto a mano del Sprint 1 queda como apoyo, no como referencia principal.

---

## Propósito

Crear una cuenta eligiendo de qué lado del producto se está: **clienta** o **negocio**. Esa elección
define el resto de la app, así que es la primera decisión del formulario, no la última.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Título y selector de rol | Dos opciones grandes: "Quiero agendar" y "Ofrezco servicios" |
| Cuerpo | [CampoFormulario](../../02-code-and-ui/components/campo-formulario.md) | Clienta: nombre, celular, correo, contraseña. Negocio: agrega nombre del salón y dirección |
| Pie | [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) | Crear cuenta. Debajo, enlace a `/login` |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Enviando el registro | Botón en `loading`, campos deshabilitados |
| Loaded | Formulario listo | Campos editables, validación por campo al salir del foco |
| Empty | No aplica | Es un formulario |
| Error | Correo ya registrado, datos inválidos o fallo de red | Mensaje bajo el campo culpable; el resto de lo escrito se conserva |
| Offline | Sin conexión | Botón deshabilitado con aviso, antes de que la usuaria llene todo |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Elegir el rol | Cambia los campos del formulario | — |
| Tocar Crear cuenta | Registra, abre sesión y va a la ruta pretendida o al inicio de su rol | `signUp` |
| Tocar Ya tengo cuenta | Navega a `/login` conservando la ruta pretendida | — |

---

## Accesibilidad

- [ ] El selector de rol se anuncia como grupo de opciones, con la seleccionada marcada.
- [ ] El rol no se distingue solo por color: cada opción tiene texto e ícono.
- [ ] Todos los campos tienen etiqueta visible y `aria-label`.
- [ ] Área táctil mínima de 48x48 dp en las dos opciones de rol.
- [ ] El teclado no tapa el campo enfocado: `android:windowSoftInputMode="adjustResize"` (config por
      defecto de Capacitor) deja que el WebView redimensione el contenido.
- [ ] Los errores por campo se anuncian al lector de pantalla.
