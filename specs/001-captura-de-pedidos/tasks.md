---

description: "Tareas de implementación — Fase 1: Fuente de verdad única y captura de pedidos"
---

# Tareas: Fase 1 — Fuente de verdad única y captura de pedidos

**Entrada**: documentos de diseño en `specs/001-captura-de-pedidos/`

**Prerrequisitos**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: OBLIGATORIOS. El Principio I de la constitución (Test-First, NO NEGOCIABLE) rige toda
tarea de comportamiento: el test se escribe primero, se lo ve fallar por el motivo esperado, y
recién entonces se implementa. Ninguna tarea de test se salta ni se difiere.

**Organización**: por historia de usuario, en el orden de prioridad del spec. Cada fase es un
incremento entregable y verificable por separado.

## Formato: `[ID] [P?] [Historia] Descripción`

- **[P]**: puede ejecutarse en paralelo (archivos distintos, sin dependencias pendientes)
- **[US1]…[US5]**: a qué historia pertenece
- Toda tarea indica su ruta de archivo

---

## Fase 1: Preparación (infraestructura compartida)

**Propósito**: dejar el repositorio compilando y con las dos suites corriendo en vacío.

- [ ] T001 Crear la solución y los proyectos en `src/Caffetto.sln`, `src/Api/Api.csproj` y `src/Api.Tests/Api.Tests.csproj` según la estructura de `plan.md`
- [ ] T002 [P] Centralizar versiones NuGet en `src/Directory.Packages.props` (EF Core 10, Npgsql, Identity, Anthropic, xUnit, Testcontainers) sin `Version` en los `.csproj`
- [ ] T003 [P] Inicializar React + Vite + TypeScript en `src/Web/` con el proxy `/api` → `localhost:8080` en `src/Web/vite.config.ts`
- [ ] T004 [P] Definir servicios `api`, `web` y `postgres:17` en `docker-compose.yml`
- [ ] T005 [P] Listar todas las variables requeridas, con valores de ejemplo y ninguno real, en `.env.example`
- [ ] T006 [P] Excluir `.env` y el volumen de media en `.gitignore`
- [ ] T007 [P] Configurar xUnit y el fixture de Testcontainers PostgreSQL en `src/Api.Tests/Integracion/FixtureDeBaseDeDatos.cs`
- [ ] T008 [P] Configurar Vitest, Testing Library y MSW en `src/Web/vitest.config.ts` y `src/Web/src/comun/pruebas/servidor.ts`
- [ ] T009 [P] Configurar formato y linting en `.editorconfig`, `src/Web/eslint.config.js`
- [ ] T010 Escribir el test del endpoint abierto de salud en `src/Api.Tests/Integracion/SaludTests.cs` — **debe fallar**
- [ ] T011 Implementar `GET /api/health` en `src/Api/Funcionalidades/Salud/EndpointDeSalud.cs` hasta poner T010 en verde

**Punto de control**: `docker compose up --build` levanta, `curl localhost:8080/api/health` responde, ambas suites corren.

---

## Fase 2: Fundacional (prerrequisitos bloqueantes)

**Propósito**: lo que toda historia necesita. **⚠️ Ninguna historia puede empezar antes de terminar esta fase.**

Incluye la autenticación y la escritura de auditoría, que los Supuestos del spec identifican como
prerrequisitos técnicos de las historias 1 a 4 aunque la Historia 5 entregue su superficie de uso.

### Tipos y convenciones de datos

- [ ] T012 [P] Test de la regla de redondeo de FR-016a (incluido `8.350 × 1,37 → 11.439,50` y el empate hacia arriba) en `src/Api.Tests/Dominio/DineroTests.cs`
- [ ] T013 [P] Test de `Cantidad`: 3 decimales en kilogramo, rechazo de fraccionarios por unidad, en `src/Api.Tests/Dominio/CantidadTests.cs`
- [ ] T014 Implementar `Dinero` en `src/Api/Dominio/Dinero.cs` y `Cantidad` en `src/Api/Dominio/Cantidad.cs`
- [ ] T015 Crear `CaffettoDbContext` con `numeric(18,2)`/`numeric(18,3)`, `timestamptz` y `UseXminAsConcurrencyToken` en `src/Api/Datos/CaffettoDbContext.cs`
- [ ] T016 [P] Definir `IAuditable`, `[NoAuditar]` y la entidad `AsientoDeAuditoria` en `src/Api/Datos/Auditoria/`

### Auditoría automática

- [ ] T017 Test del interceptor: alta, modificación y baja de una entidad `IAuditable` dejan asiento con usuario, fecha, acción y valor anterior, en `src/Api.Tests/Integracion/InterceptorDeAuditoriaTests.cs` — **debe fallar**
- [ ] T018 Test de que un guardado rechazado por conflicto de concurrencia **no** deja asiento, en `src/Api.Tests/Integracion/InterceptorDeAuditoriaTests.cs`
- [ ] T019 Implementar `InterceptorDeAuditoria` en `src/Api/Datos/Auditoria/InterceptorDeAuditoria.cs` y registrarlo en el contexto

### Reloj y zona horaria

- [ ] T020 [P] Test del calendario de negocio: día de aviso inexistente resuelve al último día del mes, y el período del tablero corta en la zona configurada, en `src/Api.Tests/Dominio/CalendarioDeNegocioTests.cs`
- [ ] T021 Implementar `CalendarioDeNegocio` sobre `TimeProvider` y la zona de R-03 en `src/Api/Dominio/CalendarioDeNegocio.cs`

### Configuración por instancia

- [ ] T022 Test de que la aplicación **no arranca** con una variable requerida ausente o inválida, en `src/Api.Tests/Integracion/ConfiguracionDeInstanciaTests.cs` — **debe fallar**
- [ ] T023 [P] Test de que los tipos de credenciales redactan su `ToString()`, en `src/Api.Tests/Integracion/ConfiguracionDeInstanciaTests.cs`
- [ ] T024 Implementar las opciones por instancia con `ValidateOnStart()` en `src/Api/Arranque/OpcionesDeInstancia.cs` y `src/Api/Arranque/RegistroDeConfiguracion.cs`

### Autenticación y autorización

- [ ] T025 Test de ingreso con credenciales válidas e inválidas en `src/Api.Tests/Integracion/SesionTests.cs` — **debe fallar**
- [ ] T026 Test de la distinción 401 sin sesión / 403 sin permiso sobre un endpoint protegido, en `src/Api.Tests/Integracion/AutorizacionTests.cs`
- [ ] T027 Crear la entidad `Usuario` con rol y `SecurityStamp` en `src/Api/Funcionalidades/Usuarios/Usuario.cs`
- [ ] T028 Implementar la cookie de sesión, el hashing con `PasswordHasher` y la revalidación del `SecurityStamp` en `src/Api/Autenticacion/`
- [ ] T029 Declarar las diez políticas de `contracts/api.md` en `src/Api/Autenticacion/Politicas.cs` y registrarlas en `src/Api/Arranque/`
- [ ] T030 Implementar `POST`/`DELETE`/`GET /api/sesion` en `src/Api/Funcionalidades/Sesion/`

### Base y puesta en marcha

- [ ] T031 Generar la migración inicial (usuarios y auditoría) en `src/Api/Datos/Migraciones/`
- [ ] T032 Test de que una instancia nueva trae el cliente genérico de mostrador y un administrador inicial, en `src/Api.Tests/Integracion/PuestaEnMarchaTests.cs`
- [ ] T033 Implementar la siembra inicial en `src/Api/Arranque/SiembraInicial.cs`

### Base del frontend

- [ ] T034 [P] Test del cliente HTTP: 401 redirige al ingreso, 403 muestra el mensaje de permisos, en `src/Web/src/comun/clienteHttp.test.ts`
- [ ] T035 [P] Implementar el cliente HTTP y el proveedor de TanStack Query en `src/Web/src/comun/clienteHttp.ts` y `src/Web/src/comun/proveedores.tsx`
- [ ] T036 [P] Implementar el layout móvil de 360 px, el ingreso y el ruteo base en `src/Web/src/comun/Layout.tsx` y `src/Web/src/main.tsx`
- [ ] T037 [P] Implementar el formato de moneda y cantidad en es-AR / ARS en `src/Web/src/comun/formato.ts` con su test en `src/Web/src/comun/formato.test.ts`

**Punto de control**: fundación lista. Las historias pueden empezar.

---

## Fase 3: Historia 1 — Catálogo, costos y listas de precios (P1) 🎯 MVP

**Objetivo**: reemplazar la hoja del Excel donde viven artículos, costos y precios, con los
precios calculados por el sistema.

**Prueba independiente**: cargar los tres tipos de artículo, armar una lista, aplicar un aumento
masivo y verificar que los precios se recalculan solos y que el historial registra el cambio
*(quickstart.md, Historia 1)*.

### Tests de la Historia 1 (OBLIGATORIOS — escribir primero, verlos fallar) ⚠️

> **Rojo-verde-refactor.** Correr cada test, confirmar que falla por el motivo esperado, y sólo entonces implementar.

- [ ] T038 [P] [US1] Test de alta de artículo con nombre, tipo, presentación, unidad, costo y utilidad por defecto (AC-12) en `src/Api.Tests/Integracion/ArticulosTests.cs`
- [ ] T039 [P] [US1] Test de las tres formas de venta: cápsulas por unidad, molido por kilogramo, cuarto por unidad (AC-15) en `src/Api.Tests/Integracion/ArticulosTests.cs`
- [ ] T040 [P] [US1] Test de baja lógica de artículo: sale de nuevos pedidos y listas, y su historial sigue consultable (AC-14) en `src/Api.Tests/Integracion/ArticulosTests.cs`
- [ ] T041 [P] [US1] Test de precio calculado: costo $10.000 y 40% → $14.000 (AC-16) en `src/Api.Tests/Integracion/ListasDePreciosTests.cs`
- [ ] T042 [P] [US1] Test de precio ingresado a mano: $14.000 sobre costo $10.000 → utilidad 40% (AC-17) en `src/Api.Tests/Integracion/ListasDePreciosTests.cs`
- [ ] T043 [P] [US1] Test de FR-015a: el artículo nuevo entra en todas las listas existentes con su utilidad por defecto en `src/Api.Tests/Integracion/ListasDePreciosTests.cs`
- [ ] T044 [P] [US1] Test de la invariante de FR-015: ninguna lista activa queda sin precio para un artículo activo en `src/Api.Tests/Integracion/ListasDePreciosTests.cs`
- [ ] T045 [P] [US1] Test de actualización masiva del 20% con un asiento de historial por artículo (AC-18, AC-22) en `src/Api.Tests/Integracion/CostosTests.cs`
- [ ] T046 [P] [US1] Test de carga individual de costo sin afectar a los demás (AC-19) en `src/Api.Tests/Integracion/CostosTests.cs`
- [ ] T047 [P] [US1] Test de actualización masiva concurrente: la segunda recibe 409 y no pisa a la primera (CHK031, FR-055a) en `src/Api.Tests/Integracion/CostosTests.cs`

### Implementación de la Historia 1

- [ ] T048 [P] [US1] Crear la entidad `Articulo` en `src/Api/Funcionalidades/Articulos/Articulo.cs`
- [ ] T049 [P] [US1] Crear la entidad `CambioDeCosto` en `src/Api/Funcionalidades/Costos/CambioDeCosto.cs`
- [ ] T050 [P] [US1] Crear `ListaDePrecios` y `ArticuloEnListaDePrecios` con su índice único en `src/Api/Funcionalidades/ListasDePrecios/`
- [ ] T051 [US1] Generar la migración del catálogo en `src/Api/Datos/Migraciones/`
- [ ] T052 [US1] Implementar los endpoints de artículos (`GET`, `POST`, `PUT`, baja, historial) en `src/Api/Funcionalidades/Articulos/`
- [ ] T053 [US1] Implementar el alta de artículo que inserta su fila en todas las listas activas, en la misma transacción, en `src/Api/Funcionalidades/Articulos/AltaDeArticulo.cs`
- [ ] T054 [US1] Implementar la actualización masiva y la carga individual de costos en `src/Api/Funcionalidades/Costos/`
- [ ] T055 [US1] Implementar los endpoints de listas de precios, con el precio calculado al leer, en `src/Api/Funcionalidades/ListasDePrecios/`
- [ ] T056 [P] [US1] Test de la pantalla de catálogo en `src/Web/src/funcionalidades/articulos/Articulos.test.tsx`
- [ ] T057 [P] [US1] Implementar la pantalla de catálogo en `src/Web/src/funcionalidades/articulos/`
- [ ] T058 [P] [US1] Implementar la pantalla dedicada de costos, con masiva e individual, en `src/Web/src/funcionalidades/costos/`
- [ ] T059 [P] [US1] Implementar la pantalla de listas de precios en `src/Web/src/funcionalidades/listasDePrecios/`

**Punto de control**: Historia 1 completa y verificable por sí sola.

---

## Fase 4: Historia 2 — El pedido del mes, cerrado con su entrega (P2)

**Objetivo**: reemplazar el Excel de la operación diaria y hacer que exista la venta.

**Prueba independiente**: con el catálogo de la Historia 1, dar de alta un cliente con abono,
registrar su pedido en menos de 30 s desde 360 px, confirmar la entrega por menos de lo pedido y
verificar la venta congelada y el faltante *(quickstart.md, Historia 2)*.

### Tests de la Historia 2 (OBLIGATORIOS — escribir primero, verlos fallar) ⚠️

- [ ] T060 [P] [US2] Test de alta de cliente con los tres e-mails (AC-01) y rechazo si falta el de cobranzas, con aceptación del mismo valor en los tres (AC-04, AC-05) en `src/Api.Tests/Integracion/ClientesTests.cs`
- [ ] T061 [P] [US2] Test de documento único entre activos, y de teléfono repetible en `src/Api.Tests/Integracion/ClientesTests.cs`
- [ ] T062 [P] [US2] Test de baja lógica e imposibilidad de borrado físico con historial (AC-03, AC-09) en `src/Api.Tests/Integracion/ClientesTests.cs`
- [ ] T063 [P] [US2] Test de abono con dos artículos y de sus valores por defecto de fecha y día de aviso (AC-07, AC-08) en `src/Api.Tests/Integracion/AbonosTests.cs`
- [ ] T064 [P] [US2] Test de tablero vacío al comenzar el mes: el sistema no crea pedidos (AC-23) en `src/Api.Tests/Integracion/PedidosTests.cs`
- [ ] T065 [P] [US2] Test de precarga desde el abono y de que modificar el pedido no altera el abono (AC-24) en `src/Api.Tests/Integracion/PedidosTests.cs`
- [ ] T066 [P] [US2] Test de pedido con artículos y cantidades libres (AC-25) en `src/Api.Tests/Integracion/PedidosTests.cs`
- [ ] T067 [P] [US2] Test de anulación con motivo y de rechazo al anular un pedido ya entregado (AC-29) en `src/Api.Tests/Integracion/PedidosTests.cs`
- [ ] T068 [P] [US2] Test de edición concurrente del mismo pedido: la segunda recibe 409 (FR-055a) en `src/Api.Tests/Integracion/PedidosTests.cs`
- [ ] T069 [P] [US2] Test de entrega parcial: pedido cerrado, faltante registrado sin backorder, venta generada (AC-27, AC-28) en `src/Api.Tests/Integracion/EntregasTests.cs`
- [ ] T070 [P] [US2] Test de entrega directa de mostrador sin pedido previo (AC-30) en `src/Api.Tests/Integracion/EntregasTests.cs`
- [ ] T071 [P] [US2] Test de congelamiento: cambiar el costo después no altera importe ni costo de la venta (AC-20, AC-21, SC-007) en `src/Api.Tests/Integracion/VentasTests.cs`
- [ ] T072 [P] [US2] Test de SC-016: el importe de línea es exactamente el precio congelado por la cantidad en `src/Api.Tests/Integracion/VentasTests.cs`
- [ ] T073 [P] [US2] Test de progresión del tablero: pendiente de entrega → entregado (AC-26) en `src/Api.Tests/Integracion/PedidosTests.cs`

### Implementación de la Historia 2

- [ ] T074 [P] [US2] Crear `Cliente` con sus índices únicos parciales en `src/Api/Funcionalidades/Clientes/Cliente.cs`
- [ ] T075 [P] [US2] Crear `Abono` y `ArticuloDeAbono` en `src/Api/Funcionalidades/Abonos/`
- [ ] T076 [P] [US2] Crear `Pedido` y `LineaDePedido` en `src/Api/Funcionalidades/Pedidos/`
- [ ] T077 [P] [US2] Crear `Entrega` y `LineaDeEntrega` en `src/Api/Funcionalidades/Entregas/`
- [ ] T078 [P] [US2] Crear `Venta` y `LineaDeVenta` con el único por entrega en `src/Api/Funcionalidades/Ventas/`
- [ ] T079 [US2] Generar la migración de clientes, abonos y operación en `src/Api/Datos/Migraciones/` — **sin** la columna `mensaje_de_origen_id`, que llega con la mensajería en la Historia 3
- [ ] T080 [US2] Implementar los endpoints de clientes en `src/Api/Funcionalidades/Clientes/`
- [ ] T081 [US2] Implementar los endpoints de abono, alta, modificación y baja, en `src/Api/Funcionalidades/Abonos/`
- [ ] T082 [US2] Implementar el borrador precargado `GET /api/pedidos/nuevo` en `src/Api/Funcionalidades/Pedidos/BorradorDePedido.cs`
- [ ] T083 [US2] Implementar la confirmación, el tablero, el detalle, la modificación con `If-Match` y la anulación en `src/Api/Funcionalidades/Pedidos/`
- [ ] T084 [US2] Implementar la confirmación de entrega que cierra el pedido, registra el faltante y genera la venta congelada en una transacción, en `src/Api/Funcionalidades/Entregas/ConfirmacionDeEntrega.cs`
- [ ] T085 [US2] Implementar la entrega directa de mostrador en `src/Api/Funcionalidades/Entregas/EntregaDirecta.cs`
- [ ] T086 [US2] Implementar los endpoints de consulta de ventas en `src/Api/Funcionalidades/Ventas/`
- [ ] T087 [P] [US2] Test de la pantalla de pedido a 360 px, con la precarga y la confirmación, en `src/Web/src/funcionalidades/pedidos/Pedido.test.tsx`
- [ ] T088 [P] [US2] Implementar las pantallas de clientes y abono en `src/Web/src/funcionalidades/clientes/`
- [ ] T089 [P] [US2] Implementar el tablero del mes y la pantalla de pedido en `src/Web/src/funcionalidades/pedidos/`
- [ ] T090 [P] [US2] Implementar la confirmación de entrega y la venta de mostrador en `src/Web/src/funcionalidades/entregas/`

**Punto de control**: Historias 1 y 2 funcionan por separado. El Excel de la operación diaria ya es reemplazable.

---

## Fase 5: Historia 3 — Ningún mensaje del cliente se pierde (P3)

**Objetivo**: el objetivo O1 del PRD. Nada que llegue por el canal se pierde, y nada se registra
sin que una persona lo confirme.

**Prueba independiente**: enviar un mensaje de texto pidiendo café y verificar la sugerencia
pendiente; después, con el intérprete caído, verificar que el mensaje igual queda en la bandeja
*(quickstart.md, Historia 3)*.

### Tests de la Historia 3 (OBLIGATORIOS — escribir primero, verlos fallar) ⚠️

- [ ] T091 [P] [US3] Test del webhook: firma inválida → 401; firma válida → mensaje persistido y 200 en `src/Api.Tests/Integracion/WebhookTests.cs`
- [ ] T092 [P] [US3] Test de que el mensaje se persiste **antes** de invocar la interpretación (FR-034, RNF-04) en `src/Api.Tests/Integracion/WebhookTests.cs`
- [ ] T093 [P] [US3] Test de deduplicación: la reentrega del mismo identificador externo no duplica (R-07) en `src/Api.Tests/Integracion/WebhookTests.cs`
- [ ] T094 [P] [US3] Test de vinculación por teléfono con cero, uno y varios clientes candidatos (FR-035) en `src/Api.Tests/Integracion/WebhookTests.cs`
- [ ] T095 [P] [US3] Test de que audio, imagen y documento quedan persistidos como pendientes de clasificar (FR-039) en `src/Api.Tests/Integracion/WebhookTests.cs`
- [ ] T096 [P] [US3] Test de contrato del intérprete: mapeo de respuesta válida, y de respuesta malformada a `NoSePudoInterpretar`, en `src/Api.Tests/Ia/InterpretadorClaudeTests.cs`
- [ ] T097 [P] [US3] Test de que el mensaje pidiendo café genera sugerencia pendiente hasta que un usuario la resuelve (AC-34) en `src/Api.Tests/Integracion/BandejaTests.cs`
- [ ] T098 [P] [US3] Test de que la consulta se clasifica sin sugerencia y fuera de la cola (AC-35, FR-045) en `src/Api.Tests/Integracion/BandejaTests.cs`
- [ ] T099 [P] [US3] Test del intérprete caído: el mensaje queda visible como pendiente de clasificar (AC-79) en `src/Api.Tests/Integracion/BandejaTests.cs`
- [ ] T100 [P] [US3] Test de confirmación de sugerencia que crea el pedido y conserva la trazabilidad (AC-37, FR-043) en `src/Api.Tests/Integracion/BandejaTests.cs`
- [ ] T101 [P] [US3] Test de doble confirmación: la segunda recibe 409 y no crea un pedido duplicado (FR-041a) en `src/Api.Tests/Integracion/BandejaTests.cs`
- [ ] T102 [P] [US3] Test de vinculación retroactiva: los mensajes previos se vinculan al crear el cliente en la aplicación (FR-044) en `src/Api.Tests/Integracion/BandejaTests.cs`
- [ ] T103 [P] [US3] Test de la cola de salida: reintento con retroceso, `error_definitivo` al superar 24 h, contador visible y reintento manual (FR-046, FR-046a, SC-017) en `src/Api.Tests/Integracion/ColaDeSalidaTests.cs`
- [ ] T104 [P] [US3] Test de reclasificación manual: un pedido clasificado por error como consulta vuelve a la cola con su sugerencia y su trazabilidad, y el intérprete no lo vuelve a tocar (FR-041b) en `src/Api.Tests/Integracion/BandejaTests.cs`
- [ ] T105 [P] [US3] Test de resolución de pendientes sin sugerencia: un comprobante de pago marcado como resuelto sale del contador y registra usuario y fecha; el segundo intento recibe 409 (FR-041c) en `src/Api.Tests/Integracion/BandejaTests.cs`

### Implementación de la Historia 3

- [ ] T106 [P] [US3] Crear `Conversacion` y `Mensaje` con el índice único del identificador externo en `src/Api/Comunicaciones/Entrante/`
- [ ] T107 [P] [US3] Crear `Sugerencia` en `src/Api/Funcionalidades/Bandeja/Sugerencia.cs`
- [ ] T108 [P] [US3] Crear `MensajeSaliente` (outbox) en `src/Api/Comunicaciones/Saliente/MensajeSaliente.cs`
- [ ] T109 [US3] Generar la migración de mensajería y agregar `pedido.mensaje_de_origen_id` con su FK en `src/Api/Datos/Migraciones/`
- [ ] T110 [P] [US3] Definir `IInterpretadorDeMensajes` y los tipos de `InterpretacionDeMensaje` en `src/Api/Ia/`
- [ ] T111 [P] [US3] Implementar el doble `InterpretadorFalso` en `src/Api.Tests/Dobles/InterpretadorFalso.cs`
- [ ] T112 [US3] Implementar `InterpretadorClaude` con salida estructurada validada contra esquema y absorción de fallas en el borde, en `src/Api/Ia/InterpretadorClaude.cs` y `src/Api/Ia/Prompts/`
- [ ] T113 [P] [US3] Definir `ICanalDeMensajeria` y `ResultadoDeEnvio` en `src/Api/Comunicaciones/ICanalDeMensajeria.cs`
- [ ] T114 [P] [US3] Implementar el doble `CanalDeMensajeriaFalso` en `src/Api.Tests/Dobles/CanalDeMensajeriaFalso.cs`
- [ ] T115 [US3] Implementar el webhook con verificación de firma, persistencia previa, deduplicación y vinculación, en `src/Api/Comunicaciones/Entrante/EndpointDeWebhook.cs`
- [ ] T116 [US3] Implementar la descarga y el guardado de media en el volumen en `src/Api/Comunicaciones/Entrante/DescargaDeMedia.cs`
- [ ] T117 [US3] Implementar `CanalWhatsApp` y el worker de la cola de salida con reintentos de 24 h en `src/Api/Comunicaciones/Saliente/`
- [ ] T118 [US3] Implementar el worker de interpretación que consume la cola y clasifica, en `src/Api/Funcionalidades/Bandeja/WorkerDeInterpretacion.cs`
- [ ] T119 [US3] Implementar los endpoints de bandeja: listado con contadores, hilo, respuesta y vinculación manual, en `src/Api/Funcionalidades/Bandeja/`
- [ ] T120 [US3] Implementar la confirmación y el descarte de sugerencias, con la actualización condicional por estado, en `src/Api/Funcionalidades/Bandeja/ResolucionDeSugerencia.cs`
- [ ] T121 [US3] Implementar el reintento manual de envíos en `src/Api/Funcionalidades/Bandeja/ReintentoDeEnvio.cs`
- [ ] T122 [US3] Implementar la reclasificación manual, que genera la sugerencia al reclasificar como pedido y marca el mensaje para que el worker de interpretación lo saltee, en `src/Api/Funcionalidades/Bandeja/ReclasificacionManual.cs`
- [ ] T123 [US3] Implementar el marcado de resueltos para los pendientes sin sugerencia, con la actualización condicional que devuelve 409 si ya estaba resuelto, en `src/Api/Funcionalidades/Bandeja/ResolucionDePendiente.cs`
- [ ] T124 [US3] Implementar la vinculación retroactiva de mensajes al dar de alta un cliente con un teléfono ya visto, en `src/Api/Funcionalidades/Clientes/VinculacionRetroactiva.cs` — movida desde US2 porque depende de las tablas de mensajería
- [ ] T125 [P] [US3] Test de la bandeja a 360 px: confirmar una sugerencia con un solo toque (FR-042) en `src/Web/src/funcionalidades/bandeja/Bandeja.test.tsx`
- [ ] T126 [P] [US3] Implementar la bandeja unificada con hilo, respuesta, contadores de trabajo pendiente, reclasificación manual y marcado de resueltos en `src/Web/src/funcionalidades/bandeja/`

**Punto de control**: O1 cubierto. Ningún mensaje se pierde y ningún pedido nace sin confirmación humana.

---

## Fase 6: Historia 4 — El sistema abre la conversación del mes (P4)

**Objetivo**: invertir la iniciativa sin romper la regla de que toda escritura la confirma una persona.

**Prueba independiente**: con un abono vigente y día de aviso 5, adelantar el reloj y verificar el
envío, la respuesta como sugerencia pendiente y la lista de recordados sin respuesta
*(quickstart.md, Historia 4)*.

### Tests de la Historia 4 (OBLIGATORIOS — escribir primero, verlos fallar) ⚠️

- [ ] T127 [P] [US4] Test del envío en el día de aviso con el detalle del abono (AC-39) en `src/Api.Tests/Integracion/RecordatoriosTests.cs`
- [ ] T128 [P] [US4] Test de idempotencia: dos corridas el mismo día envían un solo recordatorio (R-09) en `src/Api.Tests/Integracion/RecordatoriosTests.cs`
- [ ] T129 [P] [US4] Test de día de aviso 31 en mes de 30, y de 29 en febrero (AC-40, FR-048) en `src/Api.Tests/Integracion/RecordatoriosTests.cs`
- [ ] T130 [P] [US4] Test de que la respuesta entra como sugerencia pendiente sin crear pedido (AC-41, FR-049) en `src/Api.Tests/Integracion/RecordatoriosTests.cs`
- [ ] T131 [P] [US4] Test de la lista de recordados sin respuesta (AC-42, FR-050) en `src/Api.Tests/Integracion/RecordatoriosTests.cs`
- [ ] T132 [P] [US4] Test de que un abono dado de baja no genera recordatorio (FR-008) en `src/Api.Tests/Integracion/RecordatoriosTests.cs`
- [ ] T133 [P] [US4] Test de abono con fecha de inicio futura: no se envía hasta alcanzarla en `src/Api.Tests/Integracion/RecordatoriosTests.cs`

### Implementación de la Historia 4

- [ ] T134 [P] [US4] Crear `RecordatorioDeAbono` con el único por abono, año y mes en `src/Api/Funcionalidades/Recordatorios/RecordatorioDeAbono.cs`
- [ ] T135 [US4] Generar la migración de recordatorios en `src/Api/Datos/Migraciones/`
- [ ] T136 [US4] Implementar el programador horario sobre `TimeProvider` y el calendario de negocio en `src/Api/Funcionalidades/Recordatorios/ProgramadorDeRecordatorios.cs`
- [ ] T137 [US4] Implementar el armado del recordatorio contra la plantilla aprobada y su encolado en el outbox, en `src/Api/Funcionalidades/Recordatorios/ArmadoDeRecordatorio.cs`
- [ ] T138 [US4] Implementar la marca de respuesta al llegar un mensaje del cliente recordado, en `src/Api/Funcionalidades/Recordatorios/RegistroDeRespuesta.cs`
- [ ] T139 [US4] Implementar `GET /api/recordatorios` en `src/Api/Funcionalidades/Recordatorios/EndpointDeRecordatorios.cs`
- [ ] T140 [P] [US4] Implementar la pantalla de recordados sin respuesta en `src/Web/src/funcionalidades/recordatorios/`

**Punto de control**: el sistema abre la conversación con todos los clientes con abono vigente.

---

## Fase 7: Historia 5 — Acceso por rol, auditoría e instancia por configuración (P5)

**Objetivo**: cerrar O4 — que todo el equipo pueda usar el sistema sin miedo a romperlo.

**Prueba independiente**: crear un usuario de cada rol, verificar las denegaciones de la matriz y
consultar la auditoría de una modificación *(quickstart.md, Historia 5)*.

### Tests de la Historia 5 (OBLIGATORIOS — escribir primero, verlos fallar) ⚠️

- [ ] T141 [P] [US5] Test de la matriz completa de FR-052: una denegación por rol y por área en `src/Api.Tests/Integracion/MatrizDePermisosTests.cs`
- [ ] T142 [P] [US5] Test de FR-052a: el Encargado de Facturación conversa pero no resuelve sugerencias de pedido en `src/Api.Tests/Integracion/MatrizDePermisosTests.cs`
- [ ] T143 [P] [US5] Test de consulta de auditoría desde el registro afectado (AC-77, AC-32, FR-056) en `src/Api.Tests/Integracion/AuditoriaTests.cs`
- [ ] T144 [P] [US5] Test de alta, cambio de rol y baja de usuarios (FR-054) en `src/Api.Tests/Integracion/UsuariosTests.cs`
- [ ] T145 [P] [US5] Test de que la baja o el cambio de rol invalida la sesión abierta (R-01) en `src/Api.Tests/Integracion/UsuariosTests.cs`
- [ ] T146 [P] [US5] Test de rechazo al dar de baja al último administrador activo en `src/Api.Tests/Integracion/UsuariosTests.cs`
- [ ] T147 [P] [US5] Test de que `GET /api/configuracion` nunca devuelve credenciales (FR-058) en `src/Api.Tests/Integracion/ConfiguracionTests.cs`

### Implementación de la Historia 5

- [ ] T148 [US5] Implementar los endpoints de gestión de usuarios en `src/Api/Funcionalidades/Usuarios/`
- [ ] T149 [US5] Implementar la invalidación de sesión por `SecurityStamp` al cambiar rol o dar de baja, en `src/Api/Funcionalidades/Usuarios/CambioDeAcceso.cs`
- [ ] T150 [US5] Implementar `GET /api/configuracion` con los datos del emisor y sin credenciales, en `src/Api/Funcionalidades/Configuracion/`
- [ ] T151 [US5] Implementar `GET /api/auditoria` por entidad y clave en `src/Api/Funcionalidades/Auditoria/EndpointDeAuditoria.cs`
- [ ] T152 [P] [US5] Implementar la pantalla de usuarios en `src/Web/src/funcionalidades/usuarios/`
- [ ] T153 [P] [US5] Implementar la pantalla de configuración de la instancia en `src/Web/src/funcionalidades/configuracion/`
- [ ] T154 [P] [US5] Implementar el panel de auditoría accesible desde cada registro en `src/Web/src/funcionalidades/auditoria/`

**Punto de control**: las cinco historias funcionan de forma independiente.

---

## Fase 8: Pulido y aspectos transversales

- [ ] T155 [P] Sembrar 150 clientes, 150 pedidos mensuales y 3 años de historia, y medir el p95 de las pantallas diarias (SC-005) en `src/Api.Tests/Rendimiento/`
- [ ] T156 [P] Prueba de 4 usuarios concurrentes sin bloqueos ni sobrescrituras silenciosas (SC-006) en `src/Api.Tests/Rendimiento/ConcurrenciaTests.cs`
- [ ] T157 [P] Auditar las pantallas de pedidos, entregas y bandeja a 360 px sin scroll horizontal (SC-011) en `src/Web/src/comun/pruebas/`
- [ ] T158 [P] Verificar que toda la interfaz está en es-AR y la única moneda es ARS (SC-014, FR-060) en `src/Web/src/comun/formato.test.ts`
- [ ] T159 Endurecimiento: verificar 0 credenciales en archivos versionados (SC-015, Principio IV) y documentar el chequeo en `quickstart.md`
- [ ] T160 [P] Verificar que existen todos los índices de `data-model.md` en la migración final, en `src/Api.Tests/Integracion/IndicesTests.cs`
- [ ] T161 [P] Documentar el procedimiento de respaldo y restauración, incluido el volumen de media, y ensayarlo (SC-013) en `docs/respaldo.md`
- [ ] T162 Recorrer `quickstart.md` de punta a punta contra la instancia levantada
- [ ] T163 Limpieza y refactor de `src/Api/Funcionalidades/` y `src/Web/src/funcionalidades/` con ambas suites en verde

---

## Dependencias y orden de ejecución

### Entre fases

- **Preparación (Fase 1)**: sin dependencias, arranca de inmediato
- **Fundacional (Fase 2)**: depende de la Preparación — **bloquea todas las historias**
- **Historias (Fases 3-7)**: todas dependen de la Fundacional
- **Pulido (Fase 8)**: depende de las historias que se quieran cubrir

### Entre historias

- **US1 (P1)**: sólo depende de la Fundacional. Es el MVP
- **US2 (P2)**: necesita una lista de precios de US1 para generar la venta congelada
- **US3 (P3)**: necesita el pedido de US2 — la sugerencia que la bandeja confirma **es** un pedido. La FK `pedido.mensaje_de_origen_id` y la vinculación retroactiva de mensajes viven acá, no en US2, para que US2 no dependa de tablas que todavía no existen
- **US4 (P4)**: necesita la bandeja de US3 para que la respuesta al recordatorio no se pierda
- **US5 (P5)**: independiente en su superficie; su base ya está en la Fundacional

Esta cadena es real, no accidental: cada historia construye sobre la anterior, y por eso el orden
de prioridades coincide con el orden de dependencia.

### Dentro de cada historia

- Los tests se escriben y **se ven fallar** antes de cualquier tarea de implementación (Principio I)
- Entidades → migración → manejadores → endpoints → frontend
- La historia se termina antes de pasar a la siguiente prioridad

---

## Oportunidades de paralelismo

- Fase 1: T002 a T009 en paralelo
- Fase 2: T012, T013, T016, T020, T023 y todo el bloque de frontend (T034-T037) en paralelo
- Todos los tests de una misma historia van en paralelo entre sí — son archivos distintos
- Las entidades de una historia van en paralelo; la migración las espera a todas
- Las pantallas de frontend de una historia van en paralelo entre sí

### Ejemplo — arranque de la Historia 1

```bash
# Los diez tests primero, en paralelo, y verlos fallar:
T038 T039 T040 T041 T042 T043 T044 T045 T046 T047

# Después las tres entidades en paralelo:
T048 T049 T050

# La migración las espera:
T051
```

---

## Estrategia de implementación

### MVP primero (sólo Historia 1)

1. Fase 1: Preparación
2. Fase 2: Fundacional — **crítica, bloquea todo**
3. Fase 3: Historia 1
4. **Parar y validar** el bloque de la Historia 1 de `quickstart.md`

### Entrega incremental

1. Preparación + Fundacional → base lista
2. Historia 1 → catálogo y precios calculados (**MVP**)
3. Historia 2 → el Excel de la operación diaria queda reemplazado
4. Historia 3 → O1 cubierto: ningún pedido se pierde
5. Historia 4 → el sistema abre la conversación del mes
6. Historia 5 → O4 cerrado: el equipo entero puede usarlo

El criterio de salida de la Fase 1 completa es SC-010: un mes de operación real sin tocar el Excel.

---

## Notas

- **Toda tarea de comportamiento empieza en rojo.** Un test que pasa en su primera corrida no es
  un paso rojo válido: revisar que esté probando lo que se cree.
- La modificación de una entrega ya confirmada **no tiene tarea** a propósito: el requerimiento
  sigue abierto (`integridad-economica.md` CHK002/CHK003) y `contracts/api.md` no expone el
  endpoint. Cuando se decida, entra como tarea nueva.
- Los tests usan dobles de `IInterpretadorDeMensajes` e `ICanalDeMensajeria`: ninguno toca la red
  ni necesita credenciales (Principios II, III y IV).
- La bandeja tiene **una sola definición de pendiente** —clasificado como pedido, pago o
  pendiente de clasificar, y sin resolver— y tres vías de salida: confirmar la sugerencia,
  reclasificar a mano, o marcar como resuelto. El contador sale de una única consulta.
- Commitear por tarea o por grupo lógico; el commit del test precede al de la implementación.
