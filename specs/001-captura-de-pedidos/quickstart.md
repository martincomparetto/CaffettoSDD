# Guía de Validación — Fase 1

**Funcionalidad**: Fase 1 — Fuente de verdad única y captura de pedidos
**Para qué sirve**: levantar el sistema y comprobar, historia por historia, que hace lo que el
spec promete. No contiene código de implementación: eso vive en `tasks.md` y en el código.

---

## Prerrequisitos

| Requisito | Por qué |
|---|---|
| .NET 10 SDK | Backend |
| Node 22 | Frontend |
| Docker en ejecución | Docker Compose y **Testcontainers** — sin el demonio, los tests de backend no corren |
| `.env` completo | Sin él la instancia no arranca *(R-12)* |

Credenciales reales de WhatsApp y del modelo **no hacen falta para los tests**: todos usan dobles
*(Principio IV)*. Sí hacen falta para la validación manual de la Historia 3 en adelante.

## Puesta en marcha

```bash
cp .env.example .env          # completar los valores
npm install --prefix src/Web  # dependencias del frontend
docker compose up --build     # API en :8080, app en :5173
```

**Verificación de que arrancó**:

```bash
curl -s localhost:8080/api/health     # → {"estado":"ok"}
```

Si falta una variable de entorno, el contenedor de la API **falla al arrancar** con el nombre de
la que falta. Eso es deliberado *(R-12)*: es preferible a descubrirlo al intentar el primer envío.

## Ciclo de trabajo

La constitución exige rojo-verde-refactor *(Principio I)*. Por cada criterio de aceptación:

```bash
cd src
dotnet test --filter "NombreDelTest"   # ROJO — debe fallar por el motivo esperado
# implementar lo mínimo
dotnet test --filter "NombreDelTest"   # VERDE
dotnet test                            # la suite completa sigue verde antes de refactorizar
```

Frontend:

```bash
cd src/Web
npm run test        # una pasada
npm run test -- --watch
```

**Puerta de merge**: `dotnet test` desde `src/` y `npm run test` desde `src/Web`, ambos en verde.

---

## Validación por historia

Cada bloque es independiente: se puede ejecutar sin haber terminado los siguientes.

### Historia 1 (P1) — Catálogo, costos y listas de precios

**Prepara**: ingresar como administrador.

1. Dar de alta tres artículos que cubran las tres formas de venta *(FR-014)*: cápsulas por
   unidad, café molido por kilogramo, y presentación de un cuarto por unidad.
2. Crear una lista de precios. **Esperado**: contiene los tres artículos con su utilidad por
   defecto y su precio calculado *(FR-015)*.
3. Dar de alta un cuarto artículo con 35% de utilidad por defecto. **Esperado**: aparece solo en
   la lista ya creada, con 35% *(FR-015a)*.
4. Con un artículo de costo $10.000 y 40% de utilidad, verificar precio **$14.000** *(AC-16)*.
5. Ingresar a mano un precio de $14.000 sobre costo $10.000. **Esperado**: utilidad **40%**
   *(AC-17)*.
6. Aplicar una actualización masiva del 20%. **Esperado**: todos los costos suben 20% y **cada
   artículo** tiene su asiento en el historial con valor anterior, fecha y usuario *(AC-18, AC-22)*.
7. Con costo $8.350 y 37% de utilidad, verificar precio **$11.439,50** — este caso distingue la
   regla de redondeo, los números redondos no *(FR-016a)*.

### Historia 2 (P2) — Pedido del mes y entrega

**Prepara**: catálogo y lista de la Historia 1.

1. Intentar guardar un cliente sin e-mail de cobranzas. **Esperado**: rechazo indicando que los
   tres son obligatorios *(AC-04)*. Repetir con la misma dirección en los tres: se guarda *(AC-05)*.
2. Intentar dar de alta un segundo cliente con el mismo CUIT que uno activo. **Esperado**:
   rechazo *(aclaración 2026-07-29)*.
3. Definir un abono de 5 kg de café en grano y 100 cápsulas con día de aviso. **Esperado**:
   guardado con ambos artículos; la fecha de inicio y el día de aviso toman sus valores por
   defecto si no se los toca *(AC-07, AC-08)*.
4. Abrir el tablero del mes sin haber confirmado nada. **Esperado**: **vacío** — el sistema no
   crea pedidos por su cuenta *(AC-23)*.
5. Iniciar el pedido del mes de ese cliente. **Esperado**: precargado con 5 kg y 100 cápsulas.
   Cambiar a 3 kg y confirmar: el pedido queda por 3 kg y 100 cápsulas y **el abono no cambia**
   *(AC-24)*.
6. Cronometrar el paso 5 desde un viewport de 360 px. **Esperado**: menos de 30 s, sin scroll
   horizontal *(SC-003, SC-011)*.
7. Confirmar la entrega por 4 kg de un pedido de 5 kg. **Esperado**: entrega por 4 kg, pedido
   **cerrado como entregado**, faltante de 1 kg registrado sin generar nada pendiente, y **venta
   generada** con el precio de la lista congelado *(AC-27, AC-28)*.
8. Actualizar el costo del artículo un 20% y volver a consultar la venta. **Esperado**: importe y
   costo congelado **sin cambios** *(AC-20, AC-21, SC-007)*.
9. Verificar que el importe de línea es exactamente precio congelado × cantidad *(SC-016)*.
10. Anular un pedido sin entrega: queda anulado. Intentar anular uno ya entregado: **rechazado**
    *(AC-29)*.
11. Abrir el mismo pedido en dos pestañas, guardar en ambas. **Esperado**: la segunda recibe el
    aviso de que el registro cambió y **no pisa** el cambio de la primera *(FR-055a)*.

### Historia 3 (P3) — Bandeja

**Prepara**: cliente registrado con teléfono; credenciales del canal cargadas.

1. Enviar un mensaje de texto pidiendo café desde el número del cliente. **Esperado**: persistido,
   vinculado al cliente, visible en la bandeja con su sugerencia de pedido, y **pendiente** hasta
   que alguien la resuelva *(AC-34)*.
2. Confirmar la sugerencia desde el celular. **Esperado**: el pedido queda registrado con **un
   solo toque** *(FR-042)*.
3. Intentar confirmar la misma sugerencia desde otra sesión. **Esperado**: aviso de que ya fue
   resuelta y **ningún pedido duplicado** *(FR-041a)*.
4. Preguntar un horario de atención. **Esperado**: clasificado como consulta, sin sugerencia y
   **fuera** de la cola de pendientes *(AC-35)*.
5. Con el intérprete caído (doble configurado en `NoSePudoInterpretar`), enviar un mensaje.
   **Esperado**: persistido y visible como **pendiente de clasificar**; no se pierde *(AC-79)*.
6. Enviar una nota de voz. **Esperado**: persistida y pendiente de clasificar *(FR-039)*.
7. Reentregar el mismo mensaje del canal dos veces. **Esperado**: aparece **una sola vez** en la
   bandeja *(R-07)*.
8. Enviar un mensaje desde un número desconocido, y después dar de alta en la aplicación un
   cliente con ese teléfono. **Esperado**: los mensajes previos quedan vinculados solos, y la
   bandeja nunca ofreció crear el cliente *(FR-044)*.
9. Con dos clientes activos que comparten teléfono, enviar un mensaje. **Esperado**: sin vincular,
   con los dos candidatos a elegir *(FR-035)*.
10. Forzar el fallo de un envío hasta agotar la ventana. **Esperado**: contado entre los envíos en
    error definitivo en la bandeja, y reintentable a mano *(FR-046a, SC-017)*.

### Historia 4 (P4) — Recordatorio mensual

**Prepara**: cliente con abono vigente y día de aviso 5; plantilla aprobada por Meta.

1. Adelantar el reloj de prueba al día 5. **Esperado**: recordatorio enviado con el detalle del
   abono *(AC-39)*.
2. Ejecutar el programador dos veces el mismo día. **Esperado**: **un solo** recordatorio — la
   idempotencia la garantiza el índice único *(R-09)*.
3. Con día de aviso 31 en un mes de 30 días. **Esperado**: se envía el día 30 *(AC-40)*.
   Repetir con día 29 en febrero.
4. Responder al recordatorio. **Esperado**: la respuesta aparece como sugerencia **pendiente**;
   ningún pedido se crea solo *(AC-41)*.
5. No responder. **Esperado**: el cliente figura en la lista de recordados sin respuesta *(AC-42)*.
6. Dar de baja el abono y volver al día de aviso. **Esperado**: **no** se envía nada *(FR-008)*.

### Historia 5 (P5) — Acceso, auditoría y configuración

1. Ingresar con credenciales inválidas: acceso denegado. Con válidas: ingresa *(AC-75)*.
2. Como Encargado de Pedidos, intentar modificar costos o la configuración. **Esperado**: acceso
   denegado *(AC-76)*.
3. Como Encargado de Facturación, leer y responder una conversación: permitido. Intentar
   confirmar una sugerencia de pedido: **denegado** *(FR-052a)*.
4. Invocar cualquier función sin sesión. **Esperado**: respuesta de **no autenticado**,
   distinguible de la de permisos insuficientes *(FR-053)*.
5. Modificar un pedido y consultar su auditoría. **Esperado**: usuario, fecha y **valor anterior**
   *(AC-77, AC-32)*.
6. Dar de baja a un usuario con sesión abierta. **Esperado**: su siguiente petición cae *(R-01)*.
7. Intentar dar de baja al último administrador activo. **Esperado**: rechazado.
8. Levantar la instancia sin una variable de entorno requerida. **Esperado**: **no arranca**, y
   dice cuál falta *(R-12, AC-78)*.
9. Abrir el listado de clientes en una instancia recién creada. **Esperado**: existe el cliente
   genérico de mostrador con la dirección genérica en sus tres e-mails *(AC-10)*.
10. Buscar cualquier credencial en el repositorio. **Esperado**: cero resultados *(SC-015)*.

---

## Criterios de éxito que no se validan aquí

| Criterio | Cómo se verifica |
|---|---|
| SC-005 — 3 s en p95 con 3 años de historia | Prueba de carga sobre datos sembrados, antes del despliegue |
| SC-006 — 4 usuarios simultáneos | Prueba de concurrencia; los pasos 11 de H2 y 3 de H3 cubren la parte funcional |
| SC-010 — un mes sin tocar el Excel | Sólo verificable en operación real; es el criterio de salida de la Fase 1 |
| SC-013 — RPO y RTO de 1 hora | Ensayo de restauración del respaldo, incluido el volumen de media *(R-11)* |
