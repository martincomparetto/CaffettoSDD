# PRD-001: Caffetto — Sistema de gestión de pedidos, facturación y cobranzas para una empresa de café de especialidad.

## Contexto y Problema

Una empresa de café de especialidad con más de 100 clientes gestiona todo su ciclo comercial en una hoja de papel que luego se transcribe a una planilla de Excel. En esa planilla registran el abono de cada cliente, la cantidad de café que debe entregarse por mes, si se entregó o no, si se facturó o no, y si se cobró o no cada factura.

Los pedidos, las entregas y las cobranzas se comunican por WhatsApp. El usuario transcribe esa información al Excel más tarde, en un rato libre o después del horario laboral. Las facturas se emiten a mano: a fin de mes se suma manualmente el café enviado a cada cliente, se cargan los comprobantes uno por uno en el facturador de ARCA y se registra la factura emitida en el Excel. Los comprobantes de transferencia llegan por WhatsApp, otros clientes pagan en efectivo, y los que no pagan son reclamados de forma continua y manual.

**Dolores concretos:**

- **Se pierden pedidos.** El mensaje de WhatsApp llega cuando el encargado está fuera del local, se pospone y se olvida. El pedido nunca se anota y el café no se entrega.
- **Se pierden cobranzas.** El comprobante de pago llega por mensaje y no se registra. La empresa no sabe con certeza quién le debe cuánto.
- **Facturar es lento e improductivo.** Sumar consumos, calcular importes y cargar comprobante por comprobante en ARCA consume horas al cierre de cada mes.
- **El Excel es frágil y no es concurrente.** Un dato mal cargado o una celda borrada rompen las fórmulas y toda la planilla muestra información incorrecta. Por eso sólo dos personas pueden tocarlo, y no pueden hacerlo al mismo tiempo.
- **Doble carga.** Todo se escribe dos veces (papel y luego Excel) y con horas o días de retraso respecto del hecho real.

**Personas:**

| Persona | Qué hace | Qué necesita |
|---|---|---|
| **Encargada de Pedidos** | A inicio de mes contacta a cada cliente por WhatsApp para coordinar la entrega del café. Registra pedidos y confirma entregas. Trabaja mayormente desde el celular, fuera del local. | Registrar un pedido en segundos desde el teléfono y que ningún mensaje de WhatsApp quede sin convertirse en un registro por olvido. |
| **Encargado de Facturación** | A principios de mes factura el consumo del mes anterior de cada cliente. Recibe comprobantes de transferencia por WhatsApp y cobros en efectivo. Reclama las deudas. | Que el sistema agrupe solo las entregas de cada cliente, calcule el importe y emita las facturas contra ARCA sin carga manual. Que ningún pago informado quede sin registrar. |
| **Responsable de Finanzas** | No opera el día a día. Consume información. | Reportes de ventas, resumen de cuenta corriente, estado de cobranzas y visibilidad del estado económico y financiero de la empresa. |
| **Administrador** | Configura el sistema. | Parametrizar datos fiscales del emisor, credenciales de ARCA y de WhatsApp, artículos, costos, listas de precios y usuarios. |

## Objetivos

- **O1 — Que ningún pedido comunicado por WhatsApp quede sin registrar.** Es el dolor más caro: un pedido perdido es un ingreso perdido.
- **O2 — Que ningún pago informado quede sin registrar** y que la deuda de cada cliente sea consultable en tiempo real.
- **O3 — Reducir el cierre de facturación mensual de horas a minutos**, eliminando el cálculo manual y la carga comprobante por comprobante en ARCA.
- **O4 — Reemplazar el Excel por una fuente de verdad única**, concurrente, auditable y con permisos por rol, que pueda usar todo el equipo sin miedo a romperla.
- **O5 — Dar visibilidad económica y financiera** al responsable de finanzas sin trabajo manual adicional.
- **O6 — Eliminar la doble carga**: que el dato se registre una sola vez, en el momento en que ocurre el hecho.

## Requerimientos Funcionales

El ciclo del sistema es: **pedido → entrega → venta → factura → cobranza**. El pedido nace cuando un usuario lo confirma. La entrega registra lo realmente entregado y, al confirmarse, genera automáticamente su venta con los precios y costos congelados en ese momento. La factura se genera a demanda, dentro del proceso de facturación, agrupando las ventas no facturadas del cliente.

Cada requerimiento indica su fase de entrega. **Fase 1:** fuente de verdad única, captura de pedidos y recordatorio mensual del abono. **Fase 2:** facturación automática. **Fase 3:** cobranzas y visibilidad.

### Clientes y abonos

- **RF-01** (F1): El sistema debe permitir dar de alta clientes con razón social, CUIT o DNI, condición frente al IVA (Responsable Inscripto, Monotributista o Consumidor Final), teléfono de WhatsApp, dirección de entrega, e-mail general, e-mail de facturación y e-mail de cobranzas.
- **RF-02** (F1): El sistema debe permitir modificar los datos de un cliente.
- **RF-03** (F1): El sistema debe permitir dar de baja lógica un cliente.
- **RF-04** (F1): El sistema debe exigir los tres e-mails (general, facturación y cobranzas) al guardar un cliente, admitiéndose la misma dirección en los tres campos.
- **RF-05** (F1): El sistema debe permitir asignar a cada cliente una lista de precios.
- **RF-06** (F1): El sistema debe permitir asignar a cada cliente una forma de pago por defecto (transferencia, cheque o efectivo), entendiendo que la forma de pago efectiva puede diferir en cada cobranza.
- **RF-07** (F1): El sistema debe permitir definir, **de forma opcional**, un abono para un cliente, compuesto por **varios artículos**, cada uno con su cantidad de referencia mensual, junto con una **fecha de inicio del abono** (por defecto, el día actual) y un **día del mes para el envío del aviso** que detalla el abono vigente (por defecto, el día de la fecha de inicio). Un cliente sin abono opera igual que uno con abono.
- **RF-08** (F1): El sistema debe impedir el borrado físico de un cliente con historial asociado.
- **RF-09** (F1): El sistema debe incluir en cada instancia un **cliente genérico de mostrador** («Consumidor Final»), precargado con una dirección de e-mail genérica de la empresa en sus tres campos de e-mail, para registrar las ventas de mostrador sin alta previa de cliente.
- **RF-10** (F3): El sistema debe mostrar en la ficha del cliente su historial de consumo de los últimos 12 meses.

### Artículos, costos y listas de precios

- **RF-11** (F1): El sistema debe permitir dar de alta artículos con su nombre, tipo (cápsulas, café molido, café en grano), presentación, unidad de medida (kilogramo o unidad) y costo.
- **RF-12** (F1): El sistema debe permitir modificar los datos de un artículo.
- **RF-13** (F1): El sistema debe permitir dar de baja artículos.
- **RF-14** (F1): El sistema debe soportar las tres formas de venta del negocio: cápsulas por cantidad, café molido o en grano por kilogramo, y café molido o en grano en presentación de un cuarto por cantidad.
- **RF-15** (F1): El sistema debe permitir crear listas de precios que contengan **todos los artículos**, con un **porcentaje de utilidad propio para cada artículo** dentro de la lista.
- **RF-16** (F1): El sistema debe calcular el precio de venta de cada artículo como `costo × (1 + porcentaje de utilidad del artículo en la lista)` cuando se ingresa el porcentaje de utilidad.
- **RF-17** (F1): El sistema debe permitir ingresar a mano el precio de venta de un artículo en la lista, calculando el porcentaje de utilidad resultante a partir de su costo.
- **RF-18** (F1): El sistema debe permitir, en una pantalla dedicada de costos, actualizar de forma masiva el costo de los artículos aplicando un porcentaje.
- **RF-19** (F1): El sistema debe permitir, en esa misma pantalla, la carga individual del costo de un artículo.
- **RF-20** (F1): El sistema debe **congelar el precio de venta en la línea de venta** al momento de generar la venta, es decir, al confirmar la entrega. Una actualización posterior de costos o de porcentajes de utilidad no debe modificar ninguna venta ya generada.
- **RF-21** (F1): El sistema debe **congelar el costo vigente del artículo en la línea de venta** al momento de generar la venta, para el cálculo de rentabilidad (RF-82). Una actualización posterior de costos no debe modificar el costo registrado en ninguna venta ya generada.
- **RF-22** (F1): El sistema debe registrar el historial de cambios de costo con fecha y usuario.

### Pedidos y entregas

- **RF-23** (F1): El sistema debe crear un pedido **únicamente cuando un usuario lo confirma**, ya sea confirmando una sugerencia de la bandeja de WhatsApp o cargándolo manualmente. El sistema no debe generar pedidos por sí solo.
- **RF-24** (F1): El sistema debe precargar el pedido con las cantidades del abono del cliente (RF-07), cuando éste tenga uno, permitiendo modificarlas tanto en más como en menos antes de confirmarlo.
- **RF-25** (F1): El sistema debe permitir registrar un pedido de artículos y cantidades libres para clientes sin abono.
- **RF-26** (F1): El sistema debe presentar un tablero con **los pedidos registrados** del período y su estado: pendiente de entrega, entregado y facturado.
- **RF-27** (F1): El sistema debe permitir confirmar la entrega de un pedido registrando la fecha y las **cantidades realmente entregadas**, que pueden diferir de las pedidas.
- **RF-28** (F1): El sistema debe **cerrar el pedido al confirmarse su entrega** aun cuando las cantidades entregadas sean menores que las pedidas, registrando la diferencia como **faltante**. El faltante no genera ningún pedido ni entrega pendiente.
- **RF-29** (F1): El sistema debe permitir **anular un pedido confirmado que aún no tenga entrega asociada**, dejando registro de auditoría. Un pedido ya entregado no puede anularse.
- **RF-30** (F1): El sistema debe permitir registrar una entrega directa, sin pedido previo, para la venta en mostrador, sobre un cliente existente o sobre el cliente genérico de mostrador (RF-09).
- **RF-31** (F2): El sistema debe permitir indicar, en una entrega de mostrador, un **e-mail de facturación específico para esa venta**, al que se envía el comprobante (RF-65), sin modificar los e-mails del cliente.
- **RF-32** (F1): El sistema debe **generar automáticamente una venta al confirmarse una entrega** (una venta por entrega), aplicando la lista de precios del cliente. La venta queda pendiente de facturar hasta que se la incluya en el proceso de facturación.
- **RF-33** (F1): El sistema debe registrar en auditoría qué usuario creó o modificó cada pedido y cada entrega, y cuándo.

### Mensajería de WhatsApp

- **RF-34** (F1): El sistema debe conectarse a WhatsApp mediante la API oficial (WhatsApp Cloud API) sobre un único número de empresa, con las credenciales del canal parametrizadas por instancia.
- **RF-35** (F1): El sistema debe persistir automáticamente todo mensaje entrante, antes de cualquier interpretación, sin que ninguna persona deba copiar o reenviar nada.
- **RF-36** (F1): El sistema debe vincular cada mensaje persistido al cliente correspondiente según su número de teléfono.
- **RF-37** (F1): El sistema debe ofrecer una bandeja de entrada unificada que permita **leer** las conversaciones de WhatsApp desde la propia aplicación.
- **RF-38** (F1): El sistema debe permitir **responder** esas conversaciones desde la propia aplicación.
- **RF-39** (F1): El sistema debe interpretar automáticamente cada mensaje entrante y clasificarlo como pedido, comprobante de pago, consulta u otro.
- **RF-40** (F1): El sistema debe **proponer un registro** a partir de cada mensaje interpretable y exigir la **confirmación explícita de un usuario** antes de escribir cualquier dato. El sistema no debe registrar ni responder por sí solo.
- **RF-41** (F1): El sistema debe mantener visible y pendiente todo mensaje clasificado como pedido o como pago hasta que un usuario lo resuelva, confirmándolo o descartándolo. Esta cola de pendientes es el mecanismo que garantiza que ningún pedido ni pago se olvide.
- **RF-42** (F1): El sistema debe conservar la trazabilidad entre cada registro confirmado y el mensaje de WhatsApp que lo originó.
- **RF-43** (F1): El sistema debe permitir crear un cliente en el momento a partir de un mensaje recibido de un número no asociado a ningún cliente.
- **RF-44** (F1): El sistema debe enviar automáticamente, cada mes, un mensaje de WhatsApp a cada cliente **con abono vigente**, el **día de aviso indicado en su abono** (RF-07), recordándole el envío del café acordado y detallando los artículos y cantidades de su abono. Si ese día no existe en el mes, el aviso se envía el último día del mes.
- **RF-45** (F1): El sistema debe recibir la respuesta del cliente a ese recordatorio en la bandeja de entrada y tratarla como cualquier otro mensaje entrante: interpretarla, proponer el pedido y esperar la confirmación de un usuario (RF-40, RF-41). El recordatorio automático **no crea ningún pedido por sí solo**.
- **RF-46** (F1): El sistema debe registrar, para cada mes, a qué clientes se les envió el recordatorio y cuáles todavía no respondieron, de modo que el usuario vea a quién falta contactar.
- **RF-47** (F3): El sistema debe permitir enviar al cliente por WhatsApp su comprobante.
- **RF-48** (F3): El sistema debe permitir enviar al cliente por WhatsApp su resumen de cuenta.
- **RF-49** (F3): El sistema debe permitir enviar al cliente por WhatsApp el reclamo de deuda.

### Facturación

- **RF-50** (F2): El sistema debe permitir parametrizar la condición fiscal del emisor como **Responsable Inscripto o Monotributista**, junto con sus datos fiscales.
- **RF-51** (F2): El sistema debe permitir parametrizar el punto de venta y el certificado digital de ARCA del emisor.
- **RF-52** (F2): El sistema debe ofrecer un **proceso de facturación ejecutable a demanda** que agrupe por cliente todas sus **ventas aún no facturadas**.
- **RF-53** (F2): El sistema debe calcular el importe de la factura como la suma de los importes de las ventas incluidas, ya congelados al generarse cada venta (RF-20).
- **RF-54** (F2): El sistema debe permitir, dentro del proceso de facturación, **seleccionar qué ventas se incluyen** y **decidir para cada cliente si se factura o no**.
- **RF-55** (F2): El sistema debe generar una **única factura unificada por cliente** por el total de las ventas incluidas.
- **RF-56** (F2): El sistema debe permitir marcar una venta como **no facturable**: no se emite comprobante fiscal por ella. La venta debe impactar igual en la cuenta corriente del cliente y en los reportes de ventas.
- **RF-57** (F2): El sistema debe permitir **quitar la marca de no facturable** de una venta, que vuelve a quedar disponible para el proceso de facturación.
- **RF-58** (F2): El sistema debe emitir los comprobantes contra el webservice de facturación electrónica de ARCA y obtener el CAE de cada uno.
- **RF-59** (F2): El sistema debe determinar el tipo de comprobante a partir de la condición fiscal del emisor y la del receptor: un emisor Responsable Inscripto emite Factura A a un Responsable Inscripto y a un Monotributista (Ley 27.618), y Factura B a un Consumidor Final; un emisor Monotributista emite siempre Factura C.
- **RF-60** (F2): El sistema debe calcular y discriminar el IVA cuando el emisor es Responsable Inscripto, y no discriminarlo cuando es Monotributista.
- **RF-61** (F2): El sistema debe generar el PDF de cada comprobante con su CAE y su código QR reglamentario.
- **RF-62** (F2): El sistema debe continuar emitiendo el resto de los comprobantes cuando uno falla, dejando el fallido en estado de error con el mensaje devuelto por ARCA y permitiendo su reintento.
- **RF-63** (F2): El sistema debe permitir emitir **notas de crédito** contra ARCA para anular o corregir un comprobante ya emitido.
- **RF-64** (F2): El sistema debe impedir que una misma venta se incluya en más de una factura.
- **RF-65** (F2): El sistema debe enviar automáticamente por correo electrónico el PDF de cada comprobante emitido, con su CAE y su código QR, al **e-mail de facturación** del cliente (RF-01) o, si la venta de mostrador indicó un e-mail específico (RF-31), a esa dirección, al momento de obtener el CAE.

### Cobranzas y cuenta corriente

- **RF-66** (F3): El sistema debe extraer por OCR el importe y la fecha de los comprobantes de transferencia recibidos por WhatsApp o por correo electrónico como imagen o PDF, y proponer la cobranza correspondiente.
- **RF-67** (F3): El sistema debe permitir registrar una cobranza con su fecha, importe, medio de pago (transferencia, cheque o efectivo) y comprobante adjunto, ya sea confirmando la sugerencia del OCR o cargándola manualmente.
- **RF-68** (F3): El sistema debe registrar toda cobranza **a cuenta del cliente, sin imputarla a ningún comprobante en particular**.
- **RF-69** (F3): El sistema debe calcular el saldo de la cuenta corriente de cada cliente como la suma de sus ventas menos la suma de sus cobranzas, actualizado en tiempo real.
- **RF-70** (F3): El sistema debe mostrar ese saldo junto al detalle cronológico de los movimientos que lo componen.
- **RF-71** (F3): El sistema debe reflejar el pago en exceso como **saldo a favor** del cliente, que se descuenta automáticamente de sus ventas siguientes.
- **RF-72** (F3): El sistema debe listar los clientes deudores ordenados por saldo y por antigüedad de la deuda, medida desde la fecha de la venta.
- **RF-73** (F3): El sistema debe permitir ajustar manualmente la cuenta corriente de un cliente exigiendo un motivo y dejando registro de auditoría.
- **RF-74** (F3): El sistema debe leer automáticamente los correos que lleguen a la casilla de cobranzas de la empresa y persistirlos como pendientes.
- **RF-75** (F3): El sistema debe vincular cada correo persistido al cliente correspondiente según su dirección de e-mail (RF-01), para que sus comprobantes adjuntos sigan el mismo circuito de sugerencia y confirmación que los recibidos por WhatsApp (RF-66, RF-67).
- **RF-76** (F3): El sistema debe **descartar** los correos recibidos en la casilla de cobranzas desde direcciones no asociadas a ningún cliente, sin generar pendientes ni sugerencias.

### Reportes

- **RF-77** (F3): El sistema debe reportar las ventas de un período con corte por cliente, por artículo y por tipo de producto.
- **RF-78** (F3): El sistema debe reportar las ventas facturadas y las no facturadas por separado.
- **RF-79** (F3): El sistema debe reportar las ventas aún no facturadas, por cliente y por antigüedad.
- **RF-80** (F3): El sistema debe reportar el estado de cobranzas del período: monto cobrado, deuda total y antigüedad de la deuda.
- **RF-81** (F3): El sistema debe emitir el resumen de cuenta corriente de cada cliente.
- **RF-82** (F3): El sistema debe reportar la rentabilidad estimada por artículo y por cliente, calculada como venta menos el **costo congelado en la línea de venta** (RF-21).
- **RF-83** (F3): El sistema debe reportar la evolución mensual de ventas y de cobranzas.

### Usuarios y configuración

- **RF-84** (F1): El sistema debe autenticar a los usuarios con credenciales individuales.
- **RF-85** (F1): El sistema debe autorizar las acciones de cada usuario según los roles de Encargado de Pedidos, Encargado de Facturación, Responsable de Finanzas y Administrador.
- **RF-86** (F1): El sistema debe registrar en auditoría toda operación que modifique datos económicos, guardando usuario, fecha, acción y valor anterior.
- **RF-87** (F1): El sistema debe permitir configurar por instancia los datos de la empresa emisora, sin requerir cambios en el código.
- **RF-88** (F1): El sistema debe permitir configurar por instancia las credenciales de ARCA, las de WhatsApp y las de la casilla de correo de la empresa (envío y lectura de la casilla de cobranzas), sin requerir cambios en el código.

## Requerimientos No Funcionales

- **RNF-01 — Responsive y mobile-first.** Las pantallas de pedidos, entregas y bandeja de WhatsApp deben ser plenamente operables en un navegador móvil con un ancho de 360 px, sin scroll horizontal.
- **RNF-02 — Velocidad de registro.** Registrar un pedido desde el celular debe tomar menos de 30 segundos. Confirmar una sugerencia de la bandeja debe requerir 1 solo toque.
- **RNF-03 — Rendimiento.** Toda pantalla de operación diaria debe responder en menos de 3 segundos en el percentil 95, con un volumen de al menos 150 clientes, 150 pedidos mensuales y 3 años de historia.
- **RNF-04 — Captura sin pérdida.** El 100% de los mensajes entrantes de WhatsApp debe persistirse **antes** de intentar interpretarlos. Un fallo de interpretación nunca debe hacer desaparecer un mensaje de la bandeja.
- **RNF-05 — Tolerancia a fallos de terceros.** La indisponibilidad de ARCA o de WhatsApp no debe bloquear la operación. Las emisiones fallidas y los mensajes pendientes se encolan y se reintentan automáticamente **durante un máximo de 24 h** antes de marcarse como error definitivo que requiere intervención manual.
- **RNF-06 — Concurrencia.** El sistema debe soportar al menos 4 usuarios trabajando en simultáneo sin bloqueos ni pérdida de datos.
- **RNF-07 — Integridad del histórico.** El 0% de las ventas ya generadas puede ver alterado su importe por un cambio posterior de costo o de porcentaje de utilidad.
- **RNF-08 — Auditabilidad.** El 100% de las operaciones que modifican datos económicos debe quedar registrado con usuario, fecha, acción y valor anterior.
- **RNF-09 — No destructividad y retención.** El 0% de los registros con historial económico asociado puede borrarse físicamente: las correcciones se hacen por anulación o ajuste con motivo. La retención del historial completo (ventas, comprobantes, cobranzas y auditoría) es **indefinida, sin política de purga**.
- **RNF-10 — Seguridad de credenciales.** Los certificados de ARCA, los tokens de WhatsApp y las credenciales de correo deben almacenarse cifrados. **0 credenciales** pueden residir en el repositorio de código.
- **RNF-11 — Despliegue por instancia.** El sistema debe desplegarse containerizado, con una instancia y una base de datos independientes por empresa. Toda diferencia entre empresas (condición fiscal, datos del emisor, canal de WhatsApp, marca) debe resolverse por configuración, con **0 cambios de código**. Poner en marcha una instancia nueva debe llevar **menos de 1 día** de trabajo.
- **RNF-12 — Respaldo y recuperación.** Ante una caída, la pérdida máxima de información debe ser de **1 hora** (RPO ≤ 1 h) y el sistema debe volver a estar operativo en **menos de 1 hora** (RTO ≤ 1 h), con procedimiento de restauración probado.
- **RNF-13 — Localización.** El 100% de la interfaz debe estar en español de Argentina, y la única moneda soportada es el peso argentino.

## Criterios de Aceptación

### Clientes y abonos

- **AC-01 (RF-01):** Dado los datos de un cliente, cuando el usuario lo da de alta con razón social, CUIT o DNI, condición frente al IVA, teléfono de WhatsApp, dirección de entrega y sus tres e-mails (general, facturación y cobranzas), entonces el cliente queda registrado y disponible para pedidos.
- **AC-02 (RF-02):** Dado un cliente registrado, cuando el usuario modifica su dirección de entrega, entonces la ficha del cliente muestra la dirección nueva.
- **AC-03 (RF-03):** Dado un cliente registrado, cuando el usuario lo da de baja lógica, entonces el cliente deja de estar disponible para nuevos pedidos y su historial sigue consultable.
- **AC-04 (RF-04):** Dado el alta de un cliente sin e-mail de cobranzas, cuando el usuario intenta guardarlo, entonces el sistema lo rechaza indicando que los tres e-mails son obligatorios.
- **AC-05 (RF-04):** Dado el alta de un cliente con la misma dirección de correo en los tres campos de e-mail, cuando el usuario lo guarda, entonces el sistema lo guarda y los tres campos muestran esa dirección.
- **AC-06 (RF-05, RF-06):** Dado un cliente y una lista de precios existentes, cuando el usuario le asigna esa lista y la forma de pago por defecto "transferencia", entonces el cliente queda con esa lista y ese default, y una cobranza posterior puede registrarse con otro medio de pago sin alterar el valor por defecto.
- **AC-07 (RF-07):** Dado un cliente, cuando el usuario le define un abono de 5 kg de café en grano y 100 cápsulas con su fecha de inicio y su día de aviso, entonces el abono queda guardado con esos dos artículos, cantidades, fecha de inicio y día de aviso; y dado otro cliente sin abono, cuando se lo guarda, entonces queda registrado sin abono y puede registrar pedidos.
- **AC-08 (RF-07):** Dado el alta de un abono realizada el 27/07/2026, cuando el usuario no modifica los valores propuestos, entonces la fecha de inicio queda en 27/07/2026 y el día de aviso en 27.
- **AC-09 (RF-08):** Dado un cliente con al menos un pedido o entrega en su historial, cuando el usuario intenta borrarlo físicamente, entonces el sistema lo impide y solo permite la baja lógica.
- **AC-10 (RF-09):** Dada una instancia recién puesta en marcha, cuando el usuario abre el listado de clientes, entonces existe el cliente genérico de mostrador con la dirección genérica de la empresa en sus tres campos de e-mail.
- **AC-11 (RF-10):** Dado un cliente con consumo registrado en distintos meses, cuando el usuario abre su ficha, entonces ve el historial de consumo de los últimos 12 meses móviles.

### Artículos, costos y listas de precios

- **AC-12 (RF-11):** Dado los datos de un artículo, cuando el usuario lo da de alta con nombre, tipo, presentación, unidad de medida y costo, entonces queda registrado y disponible para listas de precios y pedidos.
- **AC-13 (RF-12):** Dado un artículo registrado, cuando el usuario modifica su presentación, entonces el catálogo muestra el valor nuevo.
- **AC-14 (RF-13):** Dado un artículo registrado, cuando el usuario lo da de baja, entonces deja de estar disponible para nuevos pedidos y nuevas listas de precios.
- **AC-15 (RF-14):** Dado el catálogo, cuando el usuario da de alta un artículo de cápsulas (por cantidad), uno de café molido por kilogramo y uno en presentación de un cuarto (por cantidad), entonces los tres quedan registrados con su unidad de medida y pueden venderse en su forma respectiva.
- **AC-16 (RF-15, RF-16, RF-32):** Dado un artículo con costo $10.000 y una lista de precios donde ese artículo tiene 40% de utilidad, cuando se confirma una entrega de un cliente con esa lista y se genera su venta, entonces el precio unitario de la venta es $14.000.
- **AC-17 (RF-17):** Dado un artículo con costo $10.000 en una lista de precios, cuando el usuario ingresa a mano un precio de venta de $14.000, entonces el sistema calcula y guarda una utilidad del 40% para ese artículo en la lista.
- **AC-18 (RF-18):** Dado un catálogo con costos, cuando el usuario aplica una actualización masiva del 20%, entonces el costo de cada artículo sube un 20%.
- **AC-19 (RF-19):** Dado un artículo, cuando el usuario carga individualmente su costo, entonces ese costo queda actualizado sin afectar a los demás.
- **AC-20 (RF-20):** Dada una venta ya generada a $14.000, cuando luego se actualiza el costo del artículo en un 20%, entonces al consultar la venta su importe sigue siendo el original ($14.000).
- **AC-21 (RF-21):** Dada una venta generada con un artículo cuyo costo era $10.000, cuando luego el costo del artículo pasa a $12.000, entonces la línea de venta conserva el costo congelado de $10.000.
- **AC-22 (RF-22):** Dado un artículo cuyo costo pasa de $10.000 a $12.000, cuando se consulta su historial de costos, entonces figura el cambio con el valor anterior ($10.000), la fecha y el usuario.

### Pedidos y entregas

- **AC-23 (RF-23, RF-26):** Dado que existen clientes con abono y comienza un nuevo mes, cuando ningún usuario confirmó todavía ningún pedido, entonces el tablero del mes está vacío: el sistema no crea pedidos por su cuenta.
- **AC-24 (RF-23, RF-24):** Dado un cliente cuyo abono es de 5 kg de café en grano y 100 cápsulas, cuando el usuario inicia el pedido del mes, entonces el sistema lo precarga con esas cantidades, y al modificarlas a 3 kg y confirmarlas, el pedido queda registrado por 3 kg y 100 cápsulas y el abono permanece sin cambios.
- **AC-25 (RF-25):** Dado un cliente sin abono, cuando el usuario registra un pedido con artículos y cantidades libres, entonces el pedido queda registrado con esos artículos y cantidades y aparece en el tablero como pendiente de entrega.
- **AC-26 (RF-26):** Dado un pedido confirmado que figura en el tablero como pendiente de entrega, cuando se confirma su entrega y luego su venta se incluye en una factura, entonces el tablero lo muestra sucesivamente en los estados entregado y facturado.
- **AC-27 (RF-27, RF-32):** Dado un pedido registrado por 5 kg, cuando el usuario confirma la entrega por 4 kg, entonces la entrega queda registrada con 4 kg y con su fecha, y el sistema **genera automáticamente la venta** por 4 kg con los precios de la lista del cliente congelados, pendiente de facturar.
- **AC-28 (RF-28):** Dado un pedido registrado por 5 kg, cuando el usuario confirma la entrega por 4 kg, entonces el pedido queda cerrado en estado entregado, el faltante de 1 kg queda registrado como faltante, y no se genera ningún pedido ni entrega pendiente por ese kilogramo.
- **AC-29 (RF-29):** Dado un pedido confirmado sin entrega asociada, cuando el usuario lo anula, entonces el pedido queda anulado, deja de figurar como pendiente de entrega y la auditoría registra el usuario y la fecha; y dado un pedido ya entregado, cuando el usuario intenta anularlo, entonces el sistema lo impide.
- **AC-30 (RF-30, RF-32):** Dada una venta en mostrador, cuando el usuario registra la entrega directa sin pedido previo, entonces la entrega queda registrada y su venta se genera automáticamente, pendiente de facturar, igual que cualquier otra.
- **AC-31 (RF-31):** Dada una entrega de mostrador sobre el cliente genérico, cuando el usuario indica un e-mail de facturación específico para esa venta y se emite su comprobante, entonces el PDF se envía a esa dirección y los e-mails del cliente genérico permanecen sin cambios.
- **AC-32 (RF-33):** Dado un pedido, cuando un usuario lo crea y otro lo modifica, entonces la auditoría del pedido registra ambos usuarios, sus acciones y las fechas.

### Mensajería de WhatsApp

- **AC-33 (RF-34):** Dado el canal de WhatsApp configurado con las credenciales de la instancia sobre el número único de la empresa, cuando llega o se envía un mensaje, entonces se cursa a través de la WhatsApp Cloud API oficial de ese número, sin usar teléfonos personales.
- **AC-34 (RF-35, RF-36, RF-39, RF-40, RF-41):** Dado un mensaje de WhatsApp de un cliente registrado pidiendo café, cuando el mensaje llega al número de la empresa, entonces queda persistido, vinculado al cliente por su número y visible en la bandeja con una sugerencia de pedido, y **permanece pendiente hasta que un usuario la confirma o la descarta**; ningún pedido se crea sin esa confirmación.
- **AC-35 (RF-39):** Dado un mensaje de un cliente que pregunta un horario de atención, cuando el sistema lo interpreta, entonces lo clasifica como consulta, no genera ninguna sugerencia de pedido ni de cobranza, y no ingresa en la cola de pendientes de pedidos y pagos.
- **AC-36 (RF-37, RF-38):** Dada una conversación con un cliente, cuando el usuario abre la bandeja unificada, entonces lee el hilo completo desde la aplicación, y al responder desde ahí el mensaje se envía al cliente y queda en el hilo.
- **AC-37 (RF-42):** Dado un pedido confirmado a partir de un mensaje de WhatsApp, cuando el usuario consulta ese pedido, entonces puede ver el mensaje original que lo originó.
- **AC-38 (RF-43):** Dado un mensaje entrante de un número no asociado a ningún cliente, cuando el usuario crea el cliente desde ese mensaje, entonces el cliente queda creado con ese número de WhatsApp y el mensaje vinculado a él.
- **AC-39 (RF-44):** Dado un cliente con abono vigente de 5 kg de café en grano y día de aviso 5, cuando llega el día 5 del mes, entonces el sistema le envía automáticamente por WhatsApp el recordatorio del envío acordado detallando ese abono.
- **AC-40 (RF-44):** Dado un cliente con abono vigente cuyo día de aviso es 31, cuando transcurre un mes de 30 días, entonces el recordatorio se envía el día 30 de ese mes.
- **AC-41 (RF-45):** Dado ese recordatorio ya enviado, cuando el cliente responde, entonces su respuesta aparece en la bandeja como sugerencia de pedido pendiente de confirmación, **sin que se cree ningún pedido automáticamente**.
- **AC-42 (RF-46):** Dado ese recordatorio ya enviado, cuando el cliente aún no respondió, entonces figura en la lista de clientes recordados sin respuesta.
- **AC-43 (RF-47):** Dado un comprobante emitido a un cliente, cuando el usuario dispara su envío, entonces el sistema se lo envía al cliente por WhatsApp.
- **AC-44 (RF-48):** Dado un cliente con movimientos, cuando el usuario dispara el envío del resumen de cuenta, entonces el sistema se lo envía por WhatsApp.
- **AC-45 (RF-49):** Dado un cliente deudor, cuando el usuario dispara el reclamo de deuda, entonces el sistema se lo envía por WhatsApp; el sistema nunca lo envía por su cuenta.

### Facturación

- **AC-46 (RF-50, RF-51):** Dado el emisor configurado como Responsable Inscripto con sus datos fiscales, punto de venta y certificado de ARCA, cuando se ejecuta la facturación, entonces los comprobantes se emiten con esos datos y ese punto de venta.
- **AC-47 (RF-52, RF-53, RF-55):** Dado un cliente con 3 ventas no facturadas, cuando el usuario ejecuta el proceso de facturación e incluye las 3, entonces el sistema genera **una única factura unificada** por la suma de las tres, sin que el usuario haya realizado ningún cálculo manual.
- **AC-48 (RF-54):** Dado un cliente con 3 ventas no facturadas, cuando el usuario ejecuta el proceso de facturación e incluye solo 2, entonces la factura se emite por la suma de esas 2 y la tercera venta queda disponible para un proceso de facturación posterior.
- **AC-49 (RF-52):** Dada una entrega de mostrador registrada hoy con su venta ya generada, cuando el usuario ejecuta el proceso de facturación para ese cliente en el momento, entonces la factura se emite sin esperar al cierre del período.
- **AC-50 (RF-54, RF-56):** Dado un cliente con ventas no facturadas, cuando el usuario ejecuta el proceso de facturación y las marca como **no facturables**, entonces el sistema **no emite comprobante fiscal**, y esas ventas igualmente aparecen en la cuenta corriente del cliente y en el reporte de ventas del período.
- **AC-51 (RF-57):** Dada una venta marcada como no facturable, cuando el usuario le quita la marca, entonces la venta vuelve a aparecer entre las disponibles del proceso de facturación.
- **AC-52 (RF-59, RF-60):** Dado un emisor Monotributista, cuando se factura a un cliente Responsable Inscripto, entonces el sistema emite una Factura C sin IVA discriminado.
- **AC-53 (RF-59, RF-60):** Dado un emisor Responsable Inscripto, cuando se factura a ese mismo cliente Responsable Inscripto, entonces el sistema emite una Factura A con IVA discriminado.
- **AC-54 (RF-59):** Dado un emisor Responsable Inscripto, cuando se factura a un cliente Monotributista, entonces el sistema emite una Factura A.
- **AC-55 (RF-59):** Dado un emisor Responsable Inscripto, cuando se factura a un cliente Consumidor Final, entonces el sistema emite una Factura B.
- **AC-56 (RF-58, RF-61):** Dado el proceso de facturación de más de 100 clientes revisado por el usuario, cuando lo ejecuta, entonces el sistema obtiene el CAE de ARCA para cada comprobante y genera su PDF con el código QR, y el proceso completo se resuelve en menos de 30 minutos.
- **AC-57 (RF-62):** Dado un proceso de facturación de 100 comprobantes en el que ARCA rechaza uno, cuando se ejecuta la emisión, entonces los otros 99 se emiten con su CAE y el rechazado queda en estado de error con el mensaje de ARCA y disponible para reintento.
- **AC-58 (RF-63):** Dada una factura emitida con un importe incorrecto, cuando el encargado emite la nota de crédito correspondiente, entonces el sistema la registra contra ARCA con su CAE y el saldo de la cuenta corriente del cliente se corrige.
- **AC-59 (RF-64):** Dada una venta ya incluida en una factura, cuando se ejecuta un nuevo proceso de facturación para ese cliente, entonces esa venta **no aparece** entre las disponibles.
- **AC-60 (RF-65):** Dada una factura emitida a un cliente, cuando el sistema obtiene su CAE, entonces envía automáticamente el PDF del comprobante al e-mail de facturación de ese cliente.

### Cobranzas y cuenta corriente

- **AC-61 (RF-66, RF-67, RF-68):** Dado que un cliente envía por WhatsApp la imagen de un comprobante de transferencia por $50.000, cuando el mensaje llega, entonces el sistema propone una cobranza de $50.000 por transferencia para ese cliente, y al confirmarla el usuario, la cobranza queda registrada a cuenta, sin imputarse a ningún comprobante.
- **AC-62 (RF-69, RF-70):** Dado un cliente con ventas por $100.000 y cobranzas por $70.000, cuando el responsable de finanzas consulta su cuenta corriente, entonces el saldo muestra una deuda de $30.000 y el detalle cronológico de los movimientos que la componen.
- **AC-63 (RF-71):** Dado un cliente con una deuda de $30.000, cuando se registra una cobranza de $50.000, entonces el sistema registra un saldo a favor de $20.000 que se descuenta automáticamente de su próxima venta.
- **AC-64 (RF-72):** Dados tres clientes deudores con saldos y antigüedades distintas, cuando el usuario abre la lista de deudores, entonces puede ordenarlos por saldo y por antigüedad de la deuda medida desde la fecha de la venta.
- **AC-65 (RF-73):** Dado un cliente, cuando el usuario ajusta manualmente su cuenta corriente indicando un motivo, entonces el saldo se corrige y la auditoría registra el ajuste, el motivo, el usuario y la fecha; y sin motivo el sistema no permite el ajuste.
- **AC-66 (RF-74, RF-75, RF-66, RF-67):** Dado que un cliente envía a la casilla de cobranzas de la empresa un correo con el comprobante de una transferencia por $50.000, cuando el correo llega, entonces queda persistido y vinculado al cliente por su dirección de e-mail y el sistema propone una cobranza de $50.000, que se registra sólo cuando un usuario la confirma.
- **AC-67 (RF-76):** Dado un correo recibido en la casilla de cobranzas desde una dirección no asociada a ningún cliente, cuando el correo llega, entonces el sistema lo descarta: no crea pendiente, ni sugerencia, ni cliente.

### Reportes

- **AC-68 (RF-77):** Dado un período con dos ventas de un cliente por $10.000 y $20.000 y una venta de otro cliente por $5.000, cuando el usuario genera el reporte de ventas con corte por cliente, entonces el reporte muestra $30.000 para el primero, $5.000 para el segundo y un total de $35.000.
- **AC-69 (RF-78):** Dado un período con una venta facturada y una venta marcada como no facturable, cuando el usuario genera el reporte, entonces ambas aparecen separadas en facturadas y no facturadas.
- **AC-70 (RF-79):** Dadas ventas no facturadas de distintos clientes y antigüedades, cuando el usuario genera el reporte de ventas no facturadas, entonces las ve por cliente y por antigüedad.
- **AC-71 (RF-80):** Dado un período con cobranzas y deuda conocidas, cuando el usuario genera el estado de cobranzas, entonces ve el monto cobrado, la deuda total y la antigüedad de la deuda.
- **AC-72 (RF-81):** Dado un cliente con movimientos, cuando el usuario emite su resumen de cuenta corriente, entonces obtiene el detalle de ventas y cobranzas con el saldo final.
- **AC-73 (RF-82, RF-21):** Dado un artículo con costo $10.000 vendido a $14.000, cuando el usuario consulta el reporte de rentabilidad, entonces la rentabilidad estimada de esa venta es $4.000, agregable por artículo y por cliente; y si luego el costo del artículo pasa a $12.000, la rentabilidad de esa venta sigue siendo $4.000.
- **AC-74 (RF-83):** Dadas ventas y cobranzas de varios meses, cuando el usuario genera el reporte de evolución mensual, entonces ve la serie mensual de ventas y de cobranzas.

### Usuarios, configuración y RNF

- **AC-75 (RF-84):** Dado un usuario con credenciales inválidas, cuando intenta ingresar al sistema, entonces el acceso se le deniega; y con credenciales válidas, ingresa.
- **AC-76 (RF-85):** Dado un usuario con rol de Encargado de Pedidos, cuando intenta acceder al proceso de facturación o a la configuración fiscal, entonces el sistema le deniega el acceso.
- **AC-77 (RF-86, RNF-08):** Dado que un usuario modifica la cantidad entregada de una entrega ya confirmada, cuando se consulta la auditoría de ese registro, entonces se ve qué usuario lo cambió, cuándo, y cuál era el valor anterior.
- **AC-78 (RF-87, RF-88):** Dado el archivo de configuración de la instancia, cuando el administrador carga los datos de la empresa emisora y las credenciales de ARCA, de WhatsApp y de la casilla de correo, entonces el sistema opera con esos valores sin ningún cambio de código.
- **AC-79 (RNF-04, RNF-05):** Dado que el servicio de interpretación de mensajes está caído, cuando llega un mensaje de WhatsApp, entonces el mensaje igualmente queda persistido y visible en la bandeja como pendiente de clasificar, sin perderse.
- **AC-80 (RNF-11):** Dado que el sistema se despliega para una segunda empresa con condición fiscal distinta, cuando se levanta la nueva instancia, entonces la única diferencia respecto de la primera es su archivo de configuración, sin ningún cambio en el código.
- **AC-81 (RNF-01, RNF-02):** Dado un usuario operando desde un celular de 360 px de ancho, cuando registra un pedido a partir del abono precargado, entonces completa la operación en menos de 30 segundos y sin scroll horizontal.

## Fuera de Alcance

- **Generación automática de pedidos.** El sistema nunca crea un pedido por su cuenta: siempre nace de la confirmación de un usuario.
- **Clasificación de clientes** entre abonados y de mostrador. Todos son clientes; el abono es un dato opcional.
- **Gestión de stock e inventario.** Una entrega nunca se bloquea por falta de producto.
- **Gestión de faltantes como backorder.** El faltante de una entrega se registra (RF-28) pero no genera pedidos pendientes ni entregas futuras automáticas.
- **Emisión de remitos.** La entrega se confirma en el sistema, pero no genera documento.
- **Logística, ruteo y asignación de repartidores.** Sólo se registra que se entregó y en qué fecha, no quién lo hizo.
- **Migración de los datos históricos del Excel.** El sistema arranca vacío.
- **Exportación a Excel** o a cualquier otro formato de planilla.
- **Contabilidad, liquidación de impuestos e integración con estudio contable.**
- **Producción, tostado y trazabilidad del grano.**
- **Multi-tenancy.** El sistema no aloja varias empresas en una misma instancia: cada empresa tiene la suya, con carteras de clientes totalmente separadas.
- **Imputación de una cobranza a un comprobante específico.** Los pagos se registran siempre a cuenta del cliente; el sistema responde "cuánto me debe este cliente", no "esta factura está paga".
- **Bot autónomo de WhatsApp.** El sistema interpreta y sugiere, pero no responde ni registra por sí solo: toda escritura de datos requiere confirmación humana.
- **Reclamo automático de deuda.** Los únicos envíos que el sistema realiza sin intervención de un usuario son el recordatorio mensual del abono por WhatsApp (RF-44) y el envío por e-mail del comprobante emitido (RF-65). El reclamo de deuda y el envío del resumen de cuenta siempre los dispara una persona.
- **E-commerce, portal de autogestión o app nativa para el cliente final.**
- **Descuentos, bonificaciones y promociones** más allá del porcentaje de utilidad definido por artículo en la lista de precios del cliente.
- **Operación en múltiples monedas.** Todo en pesos argentinos.
- **Alta de clientes a partir de correos electrónicos.** Los correos de direcciones desconocidas en la casilla de cobranzas se descartan (RF-76); el alta desde un contacto entrante existe sólo para WhatsApp (RF-43).

## Riesgos y Dependencias

- **Riesgo:** los usuarios no adoptan el número único de empresa y siguen conversando desde sus teléfonos personales, con lo cual el sistema queda ciego y la captura automática de pedidos y pagos deja de funcionar. Es el riesgo crítico del proyecto: invalida la propuesta de valor entera. → **Mitigación:** que la bandeja del sistema sea mejor que WhatsApp para su trabajo (historial del cliente, abono, deuda y sugerencias en la misma pantalla), comunicar el cambio de número a los clientes con anticipación, e involucrar a los dos usuarios operativos desde el primer día del desarrollo.
- **Riesgo:** un cliente con abono no pide y nadie lo contacta, con lo cual no recibe su café y el sistema no lo advierte, porque no genera pedidos por su cuenta. → **Mitigación:** el recordatorio automático mensual del día de aviso de cada abono (RF-44), incluido en la Fase 1, invierte la iniciativa: el sistema abre la conversación con todos los clientes con abono vigente, y el listado de recordados sin respuesta (RF-46) muestra a quién falta contactar. La cola de pendientes de la bandeja (RF-41) garantiza que la respuesta que llegue no se pierda.
- **Riesgo:** el recordatorio automático mensual se percibe como spam, o se envía a un cliente cuyo abono ya no está vigente. → **Mitigación:** se envía sólo a clientes con abono vigente, una vez por mes, y el día se configura por abono (RF-07).
- **Riesgo:** la verificación del negocio en Meta demora y bloquea todo el módulo de WhatsApp, que es el corazón del producto. → **Mitigación:** iniciar el trámite de alta y verificación antes de escribir la primera línea de código, no cuando el módulo esté listo.
- **Riesgo:** la interpretación automática de los mensajes genera sugerencias erróneas (pedidos mal leídos, importes mal extraídos por el OCR) y corrompe los datos. → **Mitigación:** ninguna sugerencia escribe datos por sí sola (RF-40). Una sugerencia incorrecta cuesta un toque de descarte, no un registro corrupto.
- **Riesgo:** ARCA está indisponible o rechaza comprobantes durante el proceso de facturación, y el cierre se cae. → **Mitigación:** probar contra el ambiente de homologación, encolar y reintentar, y aislar el fallo de un comprobante del resto (RF-62).
- **Riesgo:** las ventas se acumulan sin facturar, porque nada obliga a ejecutar el proceso de facturación. → **Mitigación:** reporte de ventas no facturadas por antigüedad (RF-79), que hace visible la deuda de facturación.
- **Riesgo:** el equipo desconfía del sistema y mantiene el Excel "por las dudas", con lo cual la doble carga persiste y el objetivo O4 no se cumple. → **Mitigación:** definir como criterio de salida de la Fase 1 un mes completo de operación real sin tocar el Excel; permitir la doble carga sólo durante ese primer mes de transición.
- **Riesgo:** el desarrollo lo realiza una sola persona y el alcance completo se estira en el tiempo. → **Mitigación:** las tres fases entregan valor de forma independiente. Si sólo se completa la Fase 1, el problema más caro (pedidos perdidos) ya está resuelto.
- **Riesgo:** el modelo de cobranza a cuenta resulta insuficiente y aparece la necesidad de saber si una factura puntual está paga. → **Mitigación:** es una decisión consciente que simplifica radicalmente la operación. El modelo de datos debe permitir agregar imputación más adelante sin migración destructiva.
- **Dependencia:** WhatsApp Cloud API (Meta). Requiere cuenta de WhatsApp Business, verificación del negocio y un número de teléfono dedicado que no puede estar en uso en la aplicación de WhatsApp. Tiene costo por conversación, a dimensionar sobre un volumen de más de 100 clientes.
- **Dependencia:** plantilla de mensaje aprobada por Meta para el recordatorio mensual del abono (RF-44). Los mensajes que la empresa inicia sin una conversación abierta sólo pueden enviarse mediante una plantilla previamente aprobada, y esa aprobación es un trámite con tiempo propio. Al estar RF-44 en la Fase 1, la plantilla es un bloqueante del primer release: su solicitud debe iniciarse junto con el alta del canal, no después. Además, el recordatorio abre más de 100 conversaciones por mes — distribuidas según el día de aviso de cada abono —, lo que impacta directamente en el costo del canal.
- **Dependencia:** servicios web de ARCA. Requiere certificado digital, delegación del servicio de facturación electrónica al certificado y un punto de venta habilitado para webservice. La numeración de comprobantes es correlativa por punto de venta y el CAE tiene fecha de vencimiento.
- **Dependencia:** normativa fiscal vigente. Los campos obligatorios del comprobante y las reglas de tipo de comprobante por condición fiscal del receptor (RF-59, hoy según Ley 27.618) deben verificarse contra la documentación oficial de ARCA al momento de implementar.
- **Dependencia:** servicio de OCR para la extracción de importe y fecha de los comprobantes de transferencia.
- **Dependencia:** servicio de correo electrónico de la empresa, con credenciales por instancia: envío para los comprobantes emitidos (RF-65) y lectura de la casilla de cobranzas monitoreada (RF-74).
- **Dependencia:** cambio de hábito de los usuarios. La comunicación comercial debe pasar íntegramente por el número único de la empresa. Sin esto, la Fase 1 no funciona.
