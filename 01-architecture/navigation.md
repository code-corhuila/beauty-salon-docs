# Navegación

## Modelo

- Todas las rutas se centralizan en **una sola tabla declarativa** en `core/routing/`, construida
  con **React Router** a través de `IonReactRouter` / `IonRouterOutlet` (el router de Ionic React) —
  ver [ADR-005](./decisions/records/ADR-005-mobile-stack-ionic-capacitor.md).
- Se navega por **ruta tipada**: un objeto de rutas centralizado en TypeScript declara los parámetros
  de cada pantalla, así que construir la URL de `ServiceDetail` sin `servicioId` no compila.
- Nunca se construye una pantalla a mano dentro del árbol de componentes.

## Reglas

- Entre rutas se pasan **identificadores, no objetos de dominio**. La pantalla destino vuelve a
  consultar el dato. Así el deep link funciona igual que la navegación interna.
- Los deep links usan **esta misma tabla**: se configuran como Android App Links (`intent-filter` con
  `autoVerify`) y se reciben en la app a través del plugin `App` de Capacitor
  (`App.addListener('appUrlOpen', ...)`), que resuelve contra el mismo objeto de rutas — no con un
  parser aparte por pantalla.
- Las rutas protegidas se **guardan de forma centralizada**: el navegador raíz decide qué stack
  monta según la sesión y el rol. Ninguna pantalla revisa la sesión por su cuenta.
- El botón atrás respeta la plataforma: en Android (única plataforma del MVP) se captura con el
  listener `backButton` del plugin `App` de Capacitor, que decide si navega atrás dentro de la app o
  cierra la app en la raíz de cada stack.

> **Las rutas van en español** aunque el código esté en inglés. Son la parte visible del deep link
> que una clienta comparte por WhatsApp (`manicita.app/servicio/128`), y ahí el español se lee mejor.
> Es una decisión consciente, no una inconsistencia: el criterio es "lo que ve la usuaria, en español;
> lo que ve el compilador, en inglés". Por eso la ruta es `/servicio/:servicioId` y la pantalla se
> llama `ServiceDetailScreen`.

## Registro de rutas

| Ruta (deep link) | Nombre en el navegador | Pantalla | Argumentos requeridos | Sesión | Rol |
|------------------|------------------------|----------|-----------------------|--------|-----|
| `/login` | `Login` | `LoginScreen` | — | No | — |
| `/registro` | `SignUp` | `SignUpScreen` | — | No | — |
| `/servicios` | `Catalog` | `CatalogScreen` | — | No | — |
| `/servicio/:servicioId` | `ServiceDetail` | `ServiceDetailScreen` | `servicioId: string` | No | — |
| `/agendar/:servicioId` | `BookAppointment` | `BookAppointmentScreen` | `servicioId: string` | Sí | clienta |
| `/mis-citas` | `MyAppointments` | `MyAppointmentsScreen` | — | Sí | clienta |
| `/cita/:citaId` | `AppointmentDetail` | `AppointmentDetailScreen` | `citaId: string` | Sí | clienta |
| `/negocio/servicios` | `BusinessServices` | `BusinessServicesScreen` | — | Sí | negocio |
| `/negocio/servicio/nuevo` | `ServiceForm` | `ServiceFormScreen` | `servicioId?: string` (si viene, edita) | Sí | negocio |
| `/negocio/agenda` | `BusinessAgenda` | `BusinessAgendaScreen` | — | Sí | negocio |

Esta tabla está dibujada en [`flows/manicita-flujos.html`](./flows/manicita-flujos.html), diagrama 2.

Esta tabla es la fuente única de verdad de qué pantallas existen. Cada una está especificada en
[`screens/`](./screens/) y agrupada en su feature en [`features/`](./features/).

## Estructura de navegadores

```
RootNavigator                      decide según la sesión
├── PublicStack                    sin sesión
│   ├── Catalog · ServiceDetail    el catálogo se explora sin cuenta
│   └── Login · SignUp
├── ClientTabs                     sesión con rol clienta
│   ├── Catalog · ServiceDetail · BookAppointment
│   └── MyAppointments · AppointmentDetail
└── BusinessTabs                   sesión con rol negocio
    ├── BusinessServices · ServiceForm
    └── BusinessAgenda
```

## Comportamiento de las guardas

| Situación | Qué hace el `RootNavigator` |
|-----------|-----------------------------|
| Ruta pública sin sesión | Deja pasar. El catálogo se explora sin cuenta: es el gancho del producto |
| Ruta con sesión requerida y sin sesión | Manda a `Login` guardando la ruta pretendida, y vuelve a ella al autenticarse |
| Ruta de negocio con sesión de clienta | Manda a `Catalog`. No se muestra un error de permiso: la clienta nunca debería haber visto ese enlace |
| Ruta de clienta con sesión de negocio | Manda a `BusinessAgenda` |
| Sesión expirada durante la navegación | El interceptor intenta refrescar; si falla, cierra sesión y el navegador raíz monta el `PublicStack` |

> El caso que hay que probar sí o sí: una clienta sin cuenta abre el deep link
> `manicita.app/agendar/128` que le compartió una amiga. La guarda la manda a `Login`, se registra, y
> **vuelve a `/agendar/128`**, no al home. Si vuelve al home, el flujo de invitación se rompe y se
> pierde justo a la usuaria que llegó recomendada.
