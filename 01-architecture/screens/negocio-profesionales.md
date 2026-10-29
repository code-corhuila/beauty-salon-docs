# Pantalla — BusinessProfessionalsScreen

- **Ruta:** `/business/professionals`
- **Feature:** [Gestión del negocio](../features/business.md)
- **Historia:** HU-15 CRUD de profesionales (c3-project)
- **Referencia de diseño:** sigue el patrón de lista de
  [BusinessServicesScreen](./negocio-servicios.md) con los tokens de
  [`design-system.md`](../../02-code-and-ui/design-system.md). No tiene boceto propio en
  [`mockups/manicita-mockups.html`](../mockups/manicita-mockups.html): se agregó el 2026-10-28.

---

## Propósito

Que la manicurista administre quiénes atienden en su salón: ver la lista, agregar a una profesional
nueva, corregir cómo se escribe su nombre y eliminar a la que se agregó por error. Antes de esta
pantalla, la única forma de agregar una profesional era desde el selector del formulario de
servicio, y no había forma de corregirla ni de quitarla.

---

## Regiones de UI

| Región | Componente | Notas |
|--------|------------|-------|
| Encabezado | Título "Profesionales" y botón atrás | Se entra desde la pestaña del negocio |
| Cuerpo | Lista de profesionales | Una fila por profesional con su nombre y dos acciones: editar y eliminar |
| Hoja inferior | [CampoFormulario](../../02-code-and-ui/components/campo-formulario.md) + [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) | Se abre para crear o para renombrar; el mismo formulario sirve para los dos |
| Pie | [BotonPrimario](../../02-code-and-ui/components/boton-primario.md) fijo | Agregar profesional. Se deshabilita al llegar a 20 |

---

## Estados

| Estado | Disparador | UI |
|--------|------------|-----|
| Loading | Cargando la lista | Esqueleto de dos filas |
| Loaded | Tiene profesionales | Lista ordenada por nombre |
| Empty | No debería ocurrir: el registro del negocio crea la primera y no se puede borrar la última | Si la API devolviera la lista vacía, [EstadoVacio](../../02-code-and-ui/components/estado-vacio.md) con la acción de agregar la primera |
| Error | Falló la carga | Mensaje comprensible con botón de reintentar |
| Offline | Sin conexión | Aviso de que la gestión necesita conexión; la lista no se cachea |

---

## Acciones

| Acción de la usuaria | Resultado | Caso de uso |
|----------------------|-----------|-------------|
| Tocar Agregar profesional | Abre la hoja con el campo de nombre; al guardar, la crea y recarga la lista | `createProfessional` |
| Tocar editar en una fila | Abre la hoja con el nombre actual; al guardar, lo reemplaza | `renameProfessional` |
| Tocar eliminar en una fila | Diálogo de confirmación con el nombre. Si la API responde 409, se muestra su mensaje (es la única, o tiene servicios o citas) y la fila se queda | `deleteProfessional` |

---

## Reglas de validación

| Campo | Regla | Por qué |
|-------|-------|---------|
| Nombre | Obligatorio, hasta 60 caracteres, sin espacios al borde | Es lo único que ve la clienta de la profesional en el catálogo |

---

## Datos que la alimentan

Recorrido completo de la pantalla hasta los datos (regla R2 del curso). Las entidades del servidor
están en [`data-model.md`](../../03-api-and-data/data-model.md); la caché local, en
[`entities/`](../../03-api-and-data/entities/).

| Caso de uso | Endpoint | Entidad del servidor | Caché local |
|-------------|----------|----------------------|-------------|
| Carga de la lista | [`GET /v1/business/professionals`](../../03-api-and-data/endpoints/business-list-professionals.md) | `Professional` (§2.3) | Ninguna |
| `createProfessional` | [`POST /v1/business/professionals`](../../03-api-and-data/endpoints/business-create-professional.md) | `Professional` (§2.3) | Ninguna |
| `renameProfessional` | [`PUT /v1/business/professionals/{id}`](../../03-api-and-data/endpoints/business-update-professional.md) | `Professional` (§2.3) | Ninguna |
| `deleteProfessional` | [`DELETE /v1/business/professionals/{id}`](../../03-api-and-data/endpoints/business-delete-professional.md) | `Professional` (§2.3) | Ninguna |

---

## Accesibilidad

- [ ] Los botones de editar y eliminar de cada fila anuncian a quién afectan: "Editar a Laura Díaz",
      "Eliminar a Laura Díaz".
- [ ] Área táctil mínima de 48x48 dp en cada acción.
- [ ] El diálogo de eliminar mueve el foco al botón de cancelar, no al de confirmar.
- [ ] El mensaje de un 409 se anuncia al lector de pantalla.
- [ ] La hoja de crear o renombrar devuelve el foco a la fila (o al botón de agregar) al cerrarse.
