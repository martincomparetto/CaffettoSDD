# Contrato de la API HTTP

**Funcionalidad**: Fase 1 — Fuente de verdad única y captura de pedidos
**Base**: todos los endpoints cuelgan de `/api`. El front pega al mismo origen (Vite en
desarrollo, nginx en producción), así que no hay CORS.

## Convenciones

**Autorización**: todo endpoint declara `RequireAuthorization(Politicas.X)`. `/api/health` es el
único abierto *(constitución, FR-053)*.

**Códigos comunes**:

| Código | Cuándo |
|---|---|
| `400` | Validación de la petición. Cuerpo `ProblemDetails` con `errors` por campo |
| `401` | Sin sesión — el front redirige al ingreso *(FR-053)* |
| `403` | Con sesión y sin permiso — el front muestra el mensaje de permisos *(FR-053)* |
| `409` | Conflicto de concurrencia, o estado que no admite la transición *(FR-041a, FR-055a)* |
| `422` | Regla de negocio violada (anular un pedido entregado, dar de baja al último administrador) |

**Formato de error**: `application/problem+json` con `type`, `title`, `status`, `detail` y, en el
400, `errors`.

**Concurrencia**: las respuestas de detalle incluyen `version` (el `xmin`). Las peticiones de
modificación lo devuelven en `If-Match`; una versión desactualizada responde 409 *(R-05)*.

## Políticas

Derivadas de la matriz de FR-052 y de la regla de FR-052a: resolver una sugerencia exige
escritura sobre el área del registro que crea.

| Política | Encargado de Pedidos | Encargado de Facturación | Responsable de Finanzas | Administrador |
|---|---|---|---|---|
| `VerCatalogo` | sí | sí | sí | sí |
| `GestionarCatalogo` | no | no | no | sí |
| `VerClientes` | sí | sí | sí | sí |
| `GestionarClientes` | sí | no | no | sí |
| `VerPedidos` | sí | sí | sí | sí |
| `GestionarPedidos` | sí | no | no | sí |
| `Conversar` | sí | sí | sólo lectura | sí |
| `ResolverSugerencias` | sí | no | no | sí |
| `VerAuditoria` | sí | sí | sí | sí |
| `Administrar` | no | no | no | sí |

---

## Salud

| Método | Ruta | Política | Respuesta |
|---|---|---|---|
| `GET` | `/api/health` | **abierta** | `200 { "estado": "ok" }` |

## Sesión

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `POST` | `/api/sesion` | abierta | Ingreso. `{ email, contraseña }` → `200` + cookie, o `401` *(FR-051)* |
| `DELETE` | `/api/sesion` | autenticado | Cierre de sesión |
| `GET` | `/api/sesion` | autenticado | Usuario y rol actuales, para que el front arme el menú |

## Artículos y costos

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `GET` | `/api/articulos` | `VerCatalogo` | Listado; filtro `?activos=true` |
| `POST` | `/api/articulos` | `GestionarCatalogo` | Alta con costo y utilidad por defecto; **inserta la fila en todas las listas activas** *(FR-011, FR-015a)* |
| `PUT` | `/api/articulos/{id}` | `GestionarCatalogo` | Modificación *(FR-012)* |
| `POST` | `/api/articulos/{id}/baja` | `GestionarCatalogo` | Baja lógica *(FR-013)* |
| `GET` | `/api/articulos/{id}/historial-de-costos` | `VerCatalogo` | *(FR-022)* |
| `POST` | `/api/costos/actualizacion-masiva` | `GestionarCatalogo` | `{ porcentaje }`; un asiento de historial por artículo *(FR-018)* |
| `PUT` | `/api/costos/{articuloId}` | `GestionarCatalogo` | Carga individual *(FR-019)* |

## Listas de precios

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `GET` | `/api/listas-de-precios` | `VerCatalogo` | |
| `POST` | `/api/listas-de-precios` | `GestionarCatalogo` | Se crea con **todos** los artículos activos y su utilidad por defecto *(FR-015)* |
| `GET` | `/api/listas-de-precios/{id}` | `VerCatalogo` | Artículos con utilidad y **precio calculado** *(FR-016)* |
| `PUT` | `/api/listas-de-precios/{id}/articulos/{articuloId}` | `GestionarCatalogo` | `{ porcentajeDeUtilidad }` o `{ precioDeVenta }`; si viene el precio, devuelve la utilidad derivada *(FR-017)* |

## Clientes y abonos

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `GET` | `/api/clientes` | `VerClientes` | Listado con búsqueda |
| `POST` | `/api/clientes` | `GestionarClientes` | Alta. Exige los tres e-mails y documento único entre activos *(FR-001, FR-004)* |
| `PUT` | `/api/clientes/{id}` | `GestionarClientes` | *(FR-002)* |
| `POST` | `/api/clientes/{id}/baja` | `GestionarClientes` | Baja lógica; nunca borra *(FR-003, FR-009)* |
| `PUT` | `/api/clientes/{id}/abono` | `GestionarClientes` | Alta o modificación del abono *(FR-007)* |
| `POST` | `/api/clientes/{id}/abono/baja` | `GestionarClientes` | El abono deja de estar vigente *(FR-008)* |

> No hay endpoint de alta de cliente desde la bandeja: FR-044 lo prohíbe. Al crear un cliente
> aquí, los mensajes previos de ese teléfono se vinculan automáticamente en la misma transacción.

## Pedidos

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `GET` | `/api/pedidos` | `VerPedidos` | Tablero del período: `?periodo=2026-07&estado=` *(FR-026)* |
| `GET` | `/api/pedidos/nuevo?clienteId=` | `GestionarPedidos` | **Borrador precargado** con las cantidades del abono; no persiste nada *(FR-024)* |
| `POST` | `/api/pedidos` | `GestionarPedidos` | Confirma y crea el pedido *(FR-023, FR-025)* |
| `GET` | `/api/pedidos/{id}` | `VerPedidos` | Detalle, con el mensaje de origen si lo hubo *(FR-043)* |
| `PUT` | `/api/pedidos/{id}` | `GestionarPedidos` | Modificación; exige `If-Match` *(FR-055a)* |
| `POST` | `/api/pedidos/{id}/anulacion` | `GestionarPedidos` | `{ motivo }`. `422` si ya está entregado *(FR-029)* |

## Entregas y ventas

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `POST` | `/api/pedidos/{id}/entrega` | `GestionarPedidos` | Confirma la entrega con las cantidades reales; **cierra el pedido, registra el faltante y genera la venta** en una sola transacción *(FR-027, FR-028, FR-031)* |
| `POST` | `/api/entregas` | `GestionarPedidos` | Entrega directa de mostrador, sin pedido previo *(FR-030)* |
| `GET` | `/api/ventas` | `VerPedidos` | Ventas del período con sus importes congelados |
| `GET` | `/api/ventas/{id}` | `VerPedidos` | Detalle con precio y costo congelados por línea *(FR-020, FR-021)* |

> No se expone la modificación de una entrega ya confirmada: el hueco de requerimiento sigue
> abierto (ver el cierre de `data-model.md`).

## Bandeja

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `GET` | `/api/bandeja` | `Conversar` | Conversaciones con contadores. Los pendientes salen de una sola condición —clasificación en pedido, pago o pendiente de clasificar, y sin resolver— más los envíos en error *(FR-041, FR-046a)* |
| `GET` | `/api/bandeja/{conversacionId}` | `Conversar` | Hilo completo *(FR-036)* |
| `POST` | `/api/bandeja/{conversacionId}/respuesta` | `Conversar` | Encola la respuesta en el outbox *(FR-037)* |
| `POST` | `/api/bandeja/{conversacionId}/vincular` | `GestionarClientes` | Elige el cliente cuando varios comparten el teléfono *(FR-035)* |
| `POST` | `/api/sugerencias/{id}/confirmacion` | `ResolverSugerencias` | Un toque: crea el pedido y marca la sugerencia. `409` si ya fue resuelta *(FR-040, FR-041a, FR-042)* |
| `POST` | `/api/sugerencias/{id}/descarte` | `ResolverSugerencias` | *(FR-041)* |
| `POST` | `/api/bandeja/mensajes/{id}/clasificacion` | `Conversar` | Reclasificación manual. `{ clasificacion }`. Reclasificar como `pedido` **genera la sugerencia** conservando la trazabilidad; el intérprete ya no vuelve a tocar ese mensaje *(FR-041b)* |
| `POST` | `/api/bandeja/mensajes/{id}/resolucion` | `Conversar` | Marca como resuelto un pendiente sin sugerencia —pago o pendiente de clasificar—, registrando usuario y fecha. `409` si ya estaba resuelto *(FR-041c)* |
| `POST` | `/api/envios/{id}/reintento` | `Conversar` | Reintento manual de un envío en error definitivo *(FR-046a)* |

## Recordatorios

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `GET` | `/api/recordatorios?periodo=2026-07` | `VerPedidos` | Enviados y quiénes no respondieron *(FR-050)* |

> El envío es automático *(FR-047)*: lo dispara el programador de R-09, no un endpoint.

## Usuarios, configuración y auditoría

| Método | Ruta | Política | Descripción |
|---|---|---|---|
| `GET` | `/api/usuarios` | `Administrar` | |
| `POST` | `/api/usuarios` | `Administrar` | Alta con rol *(FR-054)* |
| `PUT` | `/api/usuarios/{id}` | `Administrar` | Cambio de rol o datos; invalida sus sesiones *(R-01)* |
| `POST` | `/api/usuarios/{id}/baja` | `Administrar` | `422` si es el último administrador activo |
| `GET` | `/api/configuracion` | `Administrar` | Datos del emisor. **Nunca devuelve credenciales** *(FR-058)* |
| `GET` | `/api/auditoria?entidad=&clave=` | `VerAuditoria` | Asientos de un registro *(FR-056)* |

---

## Trazabilidad contra los requerimientos

Los 66 requerimientos funcionales del spec quedan cubiertos por: este contrato (endpoints),
`contracts/webhook-whatsapp.md` (FR-033 a FR-035, FR-039), `contracts/interpretacion.md` (FR-038),
el programador de R-09 (FR-047, FR-048) y el interceptor de R-06 (FR-032, FR-055). Los
requerimientos transversales —FR-016a, FR-052a, FR-059, FR-060— son reglas que aplican a todos
los endpoints de arriba, no endpoints propios.
