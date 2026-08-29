# Navigation

## Model

- Centralize all routes in **one declarative routing table** (in `app.<ext>` or `core/`).
- Navigate by **named route or typed destination** — never construct a screen ad hoc deep
  in the widget tree.
- Each route declares the arguments it requires with types.

## Rules

- Pass **identifiers**, not full domain objects, across routes; re-fetch in the destination.
- Deep links map to the same route table — no separate parsing logic per screen.
- Guard protected routes centrally (auth check), not inside individual screens.
- Back behavior respects the platform (hardware back on Android, edge-swipe on iOS).

## Route registry (fill in)

| Route name | Screen | Required args | Auth |
|------------|--------|---------------|------|
| `/login` | LoginScreen | — | No |
| `/home` | HomeScreen | — | Yes |
| `/order/:id` | OrderDetailScreen | `orderId` | Yes |

> Keep this table in sync with the routing table in code. It is the single source of truth
> for what screens exist and how they are reached.
