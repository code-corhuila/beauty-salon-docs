# Design System

## Tokens

Centralize all visual values as **design tokens** in `core/theme/`. Screens reference tokens,
never raw values.

| Token group | Examples |
|-------------|----------|
| Color | `color.primary`, `color.surface`, `color.error` |
| Spacing | `space.xs … space.xl` (a fixed scale, e.g. 4/8/12/16/24) |
| Radius | `radius.sm`, `radius.md`, `radius.pill` |
| Typography | `text.title`, `text.body`, `text.caption` |
| Elevation | `elevation.card`, `elevation.modal` |

## Rules

- No hardcoded colors, sizes, or font sizes in screens — use tokens.
- Build screens from a **shared component library** (`shared/`) — no one-off styled widgets.
- Light and dark themes come from the **same** token set (swap values, not components).
- Respect platform conventions: safe areas, native gestures, platform-appropriate controls.

## Components

- Each shared component has: defined props, visual states (default / pressed / disabled /
  loading), and an accessibility contract.
- Document each shared component with [`_template-component.md`](./_template-component.md).
- A component owns styling and layout only — no business logic, no data fetching.
