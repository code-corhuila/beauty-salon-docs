# Pantalla — AccountScreen

- **Ruta:** `/account`
- **Feature:** [Autenticación y sesión](../features/auth.md)
- **Historia:** HU-12 Cierre de sesión
- **Referencia de diseño:** no tiene boceto propio en
  [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html): se agregó el 2026-10-29 con
  los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md) y los componentes ya
  existentes.

---

## Propósito

Que la persona con sesión vea con qué cuenta está dentro y pueda cerrar la sesión. Es la misma
pantalla para clienta y para negocio: cerrar sesión no depende del rol.

Cerrar sesión importa más de lo que parece: el celular se presta, y las citas cacheadas dicen a qué
hora y en qué dirección va a estar una mujer ([`authentication.md`](../../03-api-and-data/authentication.md)).

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Título "Mi cuenta" y botón atrás | — |
| Cuerpo | Nombre y tipo de cuenta | "Clienta" o "Negocio", en texto. Salen del perfil de la sesión, sin ir a la red |
| Pie | [BotonSecundario](../../02-code-and-ui/components/boton-secundario.md) | Cerrar sesión. Abre un diálogo de confirmación |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cerrando la sesión | El botón muestra que está trabajando y no se puede tocar dos veces |
| Loaded | Sesión abierta | Nombre, tipo de cuenta y botón |
| Empty | No aplica | Sin sesión la ruta no se muestra: la guarda manda a `/login` |
| Error | No aplica | **Cerrar sesión nunca falla para la persona** ([`auth-logout.md`](../../03-api-and-data/endpoints/auth-logout.md)): si la API no responde, la sesión se cierra en el dispositivo igual |
| Offline | Sin conexión | El botón funciona igual; no se muestra ningún aviso |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Tocar Cerrar sesión | Diálogo "¿Cerrar sesión?" con Cancelar y Cerrar sesión | — |
| Confirmar | Cierra la sesión y lleva al catálogo, ya sin sesión | `signOut` |
| Cancelar | Cierra el diálogo y no cambia nada | — |

---

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| Nombre y tipo de cuenta | Ninguno: salen de `SessionState` | — | Ninguna |
| `signOut` | [`POST /v1/auth/logout`](../../03-api-and-data/endpoints/auth-logout.md) | `RevokedRefreshToken` (§2.7) | **Borra** los tokens del almacenamiento seguro y vacía las tablas locales |

---

## Accesibilidad

- [ ] El tipo de cuenta se lee como texto, no solo con un ícono.
- [ ] El diálogo de confirmación atrapa el foco y deja el foco inicial en Cancelar.
- [ ] Área táctil mínima de 48x48 dp en el botón.
- [ ] Al cerrar la sesión, el lector de pantalla anuncia la pantalla a la que se llegó.
