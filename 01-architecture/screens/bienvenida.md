# Pantalla — WelcomeScreen

- **Ruta:** `/welcome`
- **Feature:** [Catálogo de servicios](../features/catalog.md) (la entrada pública de la app)
- **Referencia de diseño:** los tokens de [`design-system.md`](../../02-code-and-ui/design-system.md) y las
  tarjetas de [TarjetaServicio](../../02-code-and-ui/components/tarjeta-servicio.md).
- **Agregada:** 2026-11-16, después de revisar la app con personas que la abrían por primera vez.

---

## Propósito

Explicar en una pantalla qué es ManiCita y **para quién es**, y dejar que cada persona elija su camino
antes de ver nada más. Hasta ahora quien entraba sin sesión caía directo en el catálogo: una clienta
no sabía cómo crear su cuenta, y un salón que quería ofrecer servicios no tenía por dónde empezar
(el registro como negocio solo aparecía después de intentar agendar).

---

## Cuándo se muestra

| Situación | Qué pasa |
|-----------|----------|
| Primera vez que se abre la app en ese celular o navegador, sin sesión | La ruta `/` lleva aquí |
| Las veces siguientes, sin sesión | La ruta `/` lleva al catálogo, como antes |
| Con sesión | Nunca se muestra sola: la ruta `/` lleva al inicio del rol (catálogo o Mis servicios) |
| Cualquier momento, sin sesión | Se puede volver con la pestaña **Inicio** de la barra de visitante |

La marca "ya vio la bienvenida" se guarda en `localStorage` con la clave `manicita.welcomeSeen`. Es un
dato de interfaz, no sensible: la regla de [`security-rules.md`](../../00-governance/security-rules.md)
que prohíbe `localStorage` es para los tokens, que siguen solo en el almacenamiento seguro. Se marca al
elegir cualquiera de los caminos, no solo al abrir la pantalla, para que quien cierra la app sin elegir
la vuelva a ver. Si el almacenamiento está bloqueado, la pantalla se muestra y la app sigue funcionando.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Marca | Logo y una frase: "Tu manicure, sin esperar respuesta por WhatsApp" | Sin barra superior ni botón atrás |
| Caminos | Dos tarjetas grandes, una debajo de la otra | **Quiero agendar** ("Mira servicios, precios y horas libres") y **Quiero ofrecer mis servicios** ("Publica tu salón y recibe citas") |
| Cuenta | Enlace "¿Ya tienes cuenta? Entrar" | Va a `/login` |
| Lo más pedido | Carrusel horizontal de tarjetas compactas | Hasta 8 servicios de [E-22](../../03-api-and-data/endpoints/catalog-popular-services.md). Se desliza con el dedo; cada tarjeta muestra nombre, precio, duración y salón |
| Pie | [BarraInferior](../../02-code-and-ui/components/barra-inferior.md) de visitante | Inicio · Servicios · Entrar |

---

## Estados del carrusel

Las tarjetas de caminos no dependen de la red: se ven siempre. Solo el carrusel tiene estados.

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Mientras llega E-22 | Tres tarjetas esqueleto del mismo tamaño |
| Loaded | Hay al menos un servicio | Carrusel con título "Lo más pedido" |
| Empty | No hay servicios publicados | El carrusel no se muestra. No se pone un mensaje: los caminos ya dicen qué hacer |
| Error u offline | Falló la petición | El carrusel no se muestra. La pantalla sigue siendo útil sin él |

---

## Acciones

| Acción de la persona | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Tocar **Quiero agendar** | Marca la bienvenida como vista y navega a `/services` | — |
| Tocar **Quiero ofrecer mis servicios** | Marca la bienvenida como vista y navega a `/register?role=business`, con **Negocio** ya elegido | — |
| Tocar **Entrar** | Marca la bienvenida como vista y navega a `/login` | — |
| Tocar una tarjeta del carrusel | Marca la bienvenida como vista y navega a `/service/:serviceId` | — |
| Abrir la pantalla | Pide lo más pedido | `getPopularServices` |

---

## Datos que la alimentan

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| `getPopularServices` | [`GET /v1/services/popular`](../../03-api-and-data/endpoints/catalog-popular-services.md) | `Service` (§2.4), `Business` (§2.2), `Professional` (§2.3), `Appointment` (§2.6, solo para contar) | No. Es un adorno de la entrada: si no hay red, no se muestra |

---

## Accesibilidad

- [ ] Cada tarjeta de camino es un botón con su título y su descripción en el nombre accesible.
- [ ] El carrusel tiene título visible ("Lo más pedido") y cada tarjeta se anuncia completa: nombre,
      precio, duración y salón.
- [ ] El carrusel se puede recorrer con teclado y lector de pantalla, no solo deslizando.
- [ ] Área táctil mínima de 48x48 dp en las tarjetas y el enlace "Entrar".
- [ ] Contraste AA del texto de las tarjetas sobre el fondo, en tema claro y oscuro.
