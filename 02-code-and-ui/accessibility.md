# Accesibilidad

La accesibilidad es un **requisito**, no un extra. Se revisa antes de dar una historia por terminada
(ver [Definition of Done](../00-governance/definition-of-done.md)).

## Reglas

- Todo elemento interactivo tiene etiqueta accesible (`aria-label`) y rol semántico correcto (`role`,
  o el elemento HTML nativo que ya lo implica: `<button>`, no un `<div>` con `onClick`).
- Área táctil mínima: **48x48 dp** en Android (única plataforma del MVP), equivalente a `48px` de
  altura/ancho mínimos en CSS dentro del WebView. Si el elemento se ve más chico, se agranda el área
  con `padding`, no se agranda el dibujo.
- El texto escala con el ajuste de fuente del sistema. Tamaños en `rem`, nunca en `px` fijos para
  texto, y nunca una altura fija en un contenedor con texto.
- Contraste **WCAG AA**: 4.5:1 en texto normal, 3:1 en texto grande e íconos. Los pares aprobados
  están en [`design-system.md`](./design-system.md).
- **Nunca comunicar solo con color.** Cada estado lleva además texto o ícono.
- Las pantallas son navegables y legibles con **TalkBack** (único lector de pantalla que aplica: la
  primera entrega es solo Android).
- Se respeta "reducir movimiento" (`prefers-reduced-motion` en CSS): con la preferencia activa, las
  transiciones se vuelven cambios instantáneos.
- El orden de foco sigue el orden del DOM. Los diálogos (`IonModal` o equivalente) atrapan el foco y
  lo devuelven al cerrarse.
- Los cambios que la usuaria no provocó se anuncian con una región `aria-live="polite"` (o `"assertive"`
  para el aviso de cupo tomado).

## Los tres puntos donde ManiCita se rompe si no se cuida

Estas son las reglas generales aterrizadas a las pantallas reales del producto:

| Punto | Riesgo | Regla concreta |
|-------|--------|----------------|
| Cuadrícula de horas del agendamiento | Celdas pequeñas, disponibilidad comunicada solo con color | Cada celda anuncia "10:30 de la mañana, disponible" u "ocupada" vía `aria-label`; área táctil de 48dp con padding; la hora ocupada además va tachada |
| Distintivos de estado de la cita | Verde, amarillo y rojo distinguen Confirmada, Pendiente y Rechazada | El distintivo siempre lleva el texto del estado, no solo el color |
| Aviso de cupo tomado | Aparece sin que la usuaria haga nada, y una persona con lector de pantalla no lo ve | Se anuncia por región activa apenas aparece |

## Checklist de verificación

Se aplica **pantalla por pantalla** antes de cerrar la historia:

- [ ] Recorrido con TalkBack en el flujo principal.
- [ ] La app funciona con el tamaño de fuente más grande del sistema sin recortar texto.
- [ ] Contraste verificado en tema claro y oscuro.
- [ ] Todos los elementos accionables cumplen el área táctil mínima.
- [ ] La preferencia de reducir movimiento se respeta.
- [ ] Ningún estado se comunica únicamente con color.
- [ ] Los botones deshabilitados explican por qué lo están.
