# Offline y sincronización

## Estrategia por feature

Cada feature declara una sola estrategia, y la justificación es **de negocio**, no técnica.

| Feature | Estrategia | Por qué |
|---------|------------|---------|
| [Catálogo](../01-architecture/features/catalog.md) | **Read-through cache** | Un precio de manicure que cambió ayer sigue siendo útil hoy. Una clienta con la app en blanco en el bus, no |
| [Mis citas](../01-architecture/features/appointments.md) | **Read-through cache** para leer, **online-only** para cancelar | Se consulta camino al salón, donde puede no haber datos. Pero una cancelación que se queda en el celular es peor que no cancelar: la manicurista igual reserva el cupo y pierde la hora |
| [Agendamiento](../01-architecture/features/booking.md) | **Online-only** | Un cupo no se puede confirmar sin servidor, porque otra clienta puede estar tomándolo en ese mismo segundo. Esta es la decisión offline más importante del proyecto |
| [Gestión del negocio](../01-architecture/features/business.md) | **Online-only** | Publicar y responder citas cambia lo que ven otras personas; y la agenda no se cachea por contener datos de las clientas |
| [Autenticación](../01-architecture/features/auth.md) | **Online-only** para entrar; la sesión ya abierta sobrevive sin red | El token guardado se lee del dispositivo, así que una usuaria autenticada no vuelve a ver el login por quedarse sin señal |

> **Ninguna feature de ManiCita es offline-first.** No es una limitación: es la conclusión de que el
> producto existe para coordinar un recurso compartido —la hora de una profesional— y eso no se puede
> coordinar sin servidor. Declararlo así evita construir una cola de sincronización que nunca se
> usaría.

## Reglas de offline-first

No aplican en este MVP porque ninguna feature la usa. Se dejan escritas porque son las reglas que
habría que cumplir si más adelante se permitiera, por ejemplo, que el negocio prepare sus servicios
sin conexión:

- Las mutaciones locales se encolan con un id generado en el cliente.
- Al reconectar se reconcilia con una **política de conflicto explícita por entidad**:
  `last-write-wins`, `server-wins` o una mezcla propia.
- La sincronización es **idempotente**: reenviar una mutación encolada no la aplica dos veces.
- La UI muestra cuándo el dato puede estar desactualizado.

## Conectividad

- La conectividad se trata como un **flujo**, no como una consulta puntual: se escucha
  `NetInfo.addEventListener` y el estado `isOffline` vive en el store.
- Se avisa **antes** de que la usuaria invierta esfuerzo, no después. En el formulario de crear
  servicio el aviso aparece al entrar, no al tocar guardar con todo lleno.
- Un botón deshabilitado por falta de conexión siempre explica el motivo, y el motivo se anuncia al
  lector de pantalla.
- Al recuperar la conexión, las lecturas se refrescan solas. Las escrituras **no** se reenvían solas:
  las relanza la usuaria.

## Frescura del caché

| Dato | TTL | Al vencerse |
|------|-----|-------------|
| Catálogo de servicios | 30 minutos | Se muestra lo cacheado y se refresca en segundo plano |
| Detalle de servicio | 30 minutos | Igual |
| Mis citas | 5 minutos | Igual, porque el estado de la cita lo cambia el negocio |

Al mostrar datos vencidos o sin conexión, el banner indica **cuándo** se actualizaron por última vez.
Un dato viejo sin fecha es un dato en el que no se puede confiar.

## Checklist

- [x] Estrategia documentada por feature.
- [x] Política de conflicto por entidad sincronizada: no aplica, ninguna entidad se sincroniza en dos
      direcciones.
- [x] La sincronización es idempotente: no aplica, no hay cola de mutaciones.
- [x] La UI muestra los estados offline, actualizando y desactualizado.
