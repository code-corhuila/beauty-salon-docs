# Componente — BarraInferior

- **Ubicación:** `src/shared/components/BarraInferior.tsx`
- **Estado:** Draft

---

## Propósito

Las pestañas de cada rol ([`navigation.md`](../../01-architecture/navigation.md), `ClientTabs` y
`BusinessTabs`) en una barra fija abajo. Deja Mis citas y la agenda siempre a un toque, que son la
mitad del ciclo del MVP. Se usa **solo en las pantallas de pestaña**; las pantallas que se abren desde
ellas (detalle, agendar, formulario) no la llevan y tienen botón atrás.

No es `IonTabs`: la app tiene un solo `IonRouterOutlet` (HU-13) y cada pantalla de pestaña pone la
barra en su pie.

---

## Props

No recibe props. Lee el rol de `useSessionStore` y la ruta actual de `useLocation`.

| Rol | Pestañas |
|-----|----------|
| `client` | Servicios (`/services`) · Mis citas (`/my-appointments`) · Mi cuenta (`/account`) |
| `business` | Mis servicios (`/business/services`) · Mis profesionales (`/business/professionals`) · Agenda (`/business/agenda`) · Mi cuenta (`/account`) |
| Sin sesión | No se muestra |

---

## Estados visuales

| Estado | Apariencia |
|--------|------------|
| Default | Ícono y texto en `color.textSecondary` |
| Actual | Ícono y texto en `color.brand`, texto en negrita |
| Pressed | El navegador del sistema; tocar la pestaña actual no hace nada |
| Disabled | No aplica |
| Loading / Error | No aplica: no consulta la red |

---

## Tokens que usa

- Color: `color.surface` de fondo, `color.border` arriba, `color.textSecondary` y `color.brand`
- Tipografía: 12 px, 500 (600 en la actual)
- Respeta el área segura inferior (`env(safe-area-inset-bottom)`)

---

## Accesibilidad

- Es un `<nav>` con la etiqueta "Navegación principal".
- Cada pestaña es un botón con **texto visible**, no solo ícono; el ícono es decorativo.
- La pestaña actual lleva `aria-current="page"`.
- Área táctil de al menos 56 px de alto.

---

## Ejemplo de uso

```tsx
<IonPage>
  <IonHeader>…</IonHeader>
  <IonContent>…</IonContent>
  <BarraInferior />
</IonPage>
```
