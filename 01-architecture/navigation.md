# Navegación

## Modelo

- Todas las rutas se centralizan en **una sola tabla declarativa** en `core/routing/`, construida
  con **React Router** a través de `IonReactRouter` / `IonRouterOutlet` (el router de Ionic React) —
  ver [ADR-005](./decisions/records/ADR-005-mobile-stack-ionic-capacitor.md).
- Se navega por **ruta tipada**: un objeto de rutas centralizado en TypeScript declara los parámetros
  de cada pantalla, así que construir la URL de `ServiceDetail` sin `serviceId` no compila.
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

> **Las rutas van en inglés**, igual que las de la API y el código (desde el 2026-09-25,
> [ADR-012](./decisions/records/ADR-012-nombres-en-ingles.md)). Hasta esa fecha iban en español con
> el criterio "lo que ve la usuaria, en español"; se cambió para que haya **un solo idioma** en todo
> identificador del sistema, y la frontera entre idiomas quede en un único lugar: los textos que la
> persona lee (i18n, mensajes de error), que siguen en español. Por eso la ruta es
> `/service/:serviceId` y la pantalla se llama `ServiceDetailScreen`.

## Registro de rutas

| Ruta (deep link) | Nombre en el navegador | Pantalla | Argumentos requeridos | Sesión | Rol |
|------------------|------------------------|----------|-----------------------|--------|-----|
| `/login` | `Login` | `LoginScreen` | — | No | — |
| `/register` | `SignUp` | `SignUpScreen` | — | No | — |
| `/services` | `Catalog` | `CatalogScreen` | — | No | — |
| `/service/:serviceId` | `ServiceDetail` | `ServiceDetailScreen` | `serviceId: string` | No | — |
| `/book/:serviceId` | `BookAppointment` | `BookAppointmentScreen` | `serviceId: string` | Sí | `client` |
| `/my-appointments` | `MyAppointments` | `MyAppointmentsScreen` | — | Sí | `client` |
| `/appointment/:appointmentId` | `AppointmentDetail` | `AppointmentDetailScreen` | `appointmentId: string` | Sí | `client` |
| `/business/services` | `BusinessServices` | `BusinessServicesScreen` | — | Sí | `business` |
| `/business/service/new` | `ServiceForm` | `ServiceFormScreen` | `serviceId?: string` (si viene, edita) | Sí | `business` |
| `/business/agenda` | `BusinessAgenda` | `BusinessAgendaScreen` | — | Sí | `business` |

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
> `manicita.app/book/128` que le compartió una amiga. La guarda la manda a `Login`, se registra, y
> **vuelve a `/book/128`**, no al home. Si vuelve al home, el flujo de invitación se rompe y se
> pierde justo a la usuaria que llegó recomendada.
