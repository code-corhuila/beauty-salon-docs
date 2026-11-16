# Pantalla — SignUpScreen

- **Ruta:** `/register`
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
| Llegar desde "Quiero ofrecer mis servicios" de la [bienvenida](./bienvenida.md) (`/register?role=business`) | El rol **Negocio** ya viene elegido y se ven los campos del salón. Se puede cambiar a Clienta. Otro valor de `role` se ignora (2026-11-16) | — |
| Tocar Crear cuenta | Registra, abre sesión y va a la ruta pretendida o al inicio de su rol | `signUp` |
| Tocar Ya tengo cuenta | Navega a `/login` conservando la ruta pretendida | — |

---

## Validación de los campos (2026-11-16)

Lo que nunca puede ser válido **no se deja escribir**; lo demás se avisa debajo del campo al salir de
él y se vuelve a revisar con cada cambio. La API revisa lo mismo (E-01): esto es experiencia, no
seguridad.

| Campo | Mientras se escribe | Regla y mensaje |
|-------|---------------------|-----------------|
| Nombre | Hasta 60 caracteres | Solo letras (con tildes y ñ), espacios, guion o apóstrofo: "Escribe solo letras, sin números ni símbolos" |
| Celular | Solo números: se quitan puntos, espacios, guiones y paréntesis, también al pegar; hasta 10 | 10 dígitos que empiezan por 3: "Escribe tu celular: 10 números que empiezan por 3" |
| Correo | Sin espacios; hasta 254 caracteres | `nombre@dominio.ext`, sin puntos dobles ni al inicio o final, con terminación de al menos 2 letras: "Correo incorrecto: escríbelo como nombre@correo.com" |
| Contraseña | Sin espacios; hasta 64 caracteres | Al menos 8 caracteres, con una letra y un número: "Usa al menos 8 caracteres, con una letra y un número" |
| Nombre del salón | Hasta 60 caracteres | Obligatorio para negocio |
| Dirección | Hasta 120 caracteres | Obligatoria para negocio |

---

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| `signUp` | [`POST /v1/auth/register`](../../03-api-and-data/endpoints/auth-register.md) | `UserAccount` (§2.1); si el rol es negocio, también `Business` (§2.2) y su primera `Professional` (§2.3) | Ninguna en SQLite: los tokens van al almacenamiento seguro |

---

## Accesibilidad

- [ ] El selector de rol se anuncia como grupo de opciones, con la seleccionada marcada.
- [ ] El rol no se distingue solo por color: cada opción tiene texto e ícono.
- [ ] Todos los campos tienen etiqueta visible y `aria-label`.
- [ ] Área táctil mínima de 48x48 dp en las dos opciones de rol.
- [ ] El teclado no tapa el campo enfocado: `android:windowSoftInputMode="adjustResize"` (config por
      defecto de Capacitor) deja que el WebView redimensione el contenido.
- [ ] Los errores por campo se anuncian al lector de pantalla.
