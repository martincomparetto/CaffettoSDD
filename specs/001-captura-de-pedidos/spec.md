# Especificación: Fase 1 — Fuente de verdad única y captura de pedidos

**Rama**: `feat/captura-de-pedidos`

**Creado**: 2026-07-29

**Estado**: Borrador

**Entrada**: `PRD.md` (PRD-001 Caffetto), alcance limitado a los requerimientos marcados **(F1)**

## Aclaraciones

### Sesión 2026-07-29

- Q: ¿Puede el mismo número de WhatsApp pertenecer a más de un cliente, y qué identifica a un cliente de forma única? → A: El teléfono puede repetirse; el CUIT o DNI es único entre clientes activos. Un mensaje de un número compartido por varios clientes queda sin vincular y el usuario elige el cliente desde la bandeja.
- Q: Cuando se da de alta un artículo nuevo, ¿qué pasa con las listas de precios que ya existían? → A: El artículo se agrega automáticamente a todas las listas con un porcentaje de utilidad por defecto definido en su alta, editable después lista por lista.
- Q: ¿Qué precisión y qué regla de redondeo rigen para cantidades, costos, precios e importes? → A: Cantidades con 3 decimales en kilogramos y enteras por unidad; costos y precios unitarios con 2 decimales redondeados al centavo (empate hacia arriba); el importe de la línea es el precio unitario ya redondeado por la cantidad.
- Q: Cuando dos usuarios tocan el mismo registro a la vez (o confirman la misma sugerencia), ¿qué hace el sistema? → A: Nadie queda bloqueado y nada se sobrescribe en silencio: el segundo en guardar recibe el aviso de que el registro cambió mientras editaba y vuelve a cargarlo. Una sugerencia sólo puede resolverse una vez.
- Q: ¿Cómo se entera el equipo de un envío que quedó en error definitivo o de que la interpretación está caída? → A: La propia bandeja lo muestra como trabajo pendiente, con su contador y la opción de reintentar el envío a mano. No hay notificación fuera de la aplicación.
- Q: ¿Cómo se resuelve el alta de un cliente desde un mensaje entrante, si en ese momento no se conocen el CUIT ni los e-mails? → A: Un cliente no se crea desde WhatsApp. El alta vive en la gestión de clientes, con todos sus datos obligatorios; el mensaje de un número desconocido queda en la bandeja sin vincular y se vincula solo cuando exista un cliente activo con ese teléfono. Redefine RF-43.
- Q: El Encargado de Facturación tiene escritura en la bandeja pero sólo lectura en pedidos, y resolver una sugerencia crea un pedido. ¿Cómo se destraba? → A: Se separa conversar de resolver: la matriz distingue leer y responder conversaciones de resolver sugerencias, y resolver una sugerencia exige escritura sobre el área del registro que crea.
- Q: Un mensaje clasificado como pago debe quedar pendiente hasta que alguien lo resuelva, pero en Fase 1 no genera sugerencia y no había forma de resolverlo. ¿Cómo se cierra? → A: Todo mensaje pendiente —de pedido, de pago o pendiente de clasificar— se resuelve por la misma vía: confirmando su sugerencia cuando la tiene, o marcándolo como resuelto. Un mensaje pendiente es el que está clasificado como pedido, pago o pendiente de clasificar y todavía no fue resuelto. *(análisis 2026-07-29)*
- Q: FR-039 dice que un usuario resuelve a mano los mensajes pendientes de clasificar, pero no había forma de hacerlo. ¿Cómo se resuelve? → A: El usuario puede reclasificar cualquier mensaje a mano. Reclasificarlo como pedido genera su sugerencia y conserva la trazabilidad; eso también repara una clasificación automática errónea. *(análisis 2026-07-29)*

## Escenarios de Usuario y Pruebas *(obligatorio)*

Esta especificación cubre la **Fase 1** del PRD: reemplazar el Excel por una fuente de verdad
única, capturar los pedidos que hoy se pierden y hacer que el sistema abra la conversación
mensual con cada cliente con abono. La facturación contra ARCA (Fase 2) y las cobranzas, el OCR
y los reportes (Fase 3) quedan fuera; ver **Fuera de Alcance**.

### Historia 1 — Catálogo, costos y listas de precios sin fórmulas frágiles (Prioridad: P1)

La administradora carga los artículos que vende la empresa con su costo, arma las listas de
precios definiendo el porcentaje de utilidad de cada artículo, y actualiza los costos cuando
suben — de a uno o de forma masiva por porcentaje. El sistema calcula los precios de venta;
nadie escribe una fórmula.

**Por qué esta prioridad**: es la hoja del Excel que se rompe con una celda borrada y hace que
toda la planilla muestre precios incorrectos. Sin catálogo ni precios no hay pedido posible, y
resolver esto primero elimina el cálculo manual de precios desde el día uno.

**Prueba independiente**: cargar tres artículos (cápsulas por cantidad, café molido por
kilogramo y presentación de un cuarto por cantidad), armar una lista de precios con su utilidad
por artículo, aplicar un aumento masivo de costos y verificar que los precios de venta se
recalculan solos y que el historial de costos registra el cambio.

**Escenarios de aceptación**:

1. **Dado** los datos de un artículo, **cuando** la administradora lo da de alta con nombre, tipo, presentación, unidad de medida y costo, **entonces** queda registrado y disponible para listas de precios y pedidos. *(AC-12)*
2. **Dado** un artículo con costo $10.000 y una lista de precios donde ese artículo tiene 40% de utilidad, **cuando** se consulta su precio de venta en esa lista, **entonces** el precio es $14.000. *(AC-16)*
3. **Dado** un artículo con costo $10.000 en una lista de precios, **cuando** la administradora ingresa a mano un precio de venta de $14.000, **entonces** el sistema calcula y guarda una utilidad del 40% para ese artículo en esa lista. *(AC-17)*
4. **Dado** un catálogo con costos cargados, **cuando** la administradora aplica una actualización masiva del 20%, **entonces** el costo de cada artículo sube un 20%. *(AC-18)*
5. **Dado** un artículo cuyo costo pasa de $10.000 a $12.000, **cuando** se consulta su historial de costos, **entonces** figura el cambio con el valor anterior, la fecha y el usuario. *(AC-22)*
6. **Dado** un artículo registrado, **cuando** la administradora lo da de baja, **entonces** deja de estar disponible para nuevos pedidos y nuevas listas de precios, y las ventas que lo incluyen siguen consultables. *(AC-14)*
7. **Dadas** tres listas de precios ya existentes, **cuando** la administradora da de alta un artículo con 35% de utilidad por defecto, **entonces** el artículo aparece en las tres listas con 35% y su precio calculado, y puede editarse la utilidad de cada lista por separado. *(aclaración 2026-07-29)*

---

### Historia 2 — El pedido del mes en segundos, cerrado con su entrega (Prioridad: P2)

La encargada de pedidos da de alta a sus clientes con su abono opcional, y a inicio de mes
registra el pedido de cada uno: el sistema lo precarga con las cantidades del abono, ella las
ajusta y confirma. Cuando el café sale, confirma la entrega con las cantidades realmente
entregadas y el sistema genera la venta con los precios y los costos congelados. El tablero del
mes muestra en qué estado está cada pedido.

**Por qué esta prioridad**: es el reemplazo del Excel para la operación diaria y la primera
mitad del objetivo O6 (el dato se registra una sola vez). También es lo que hace que exista una
venta: sin entrega confirmada no hay nada que facturar en la Fase 2.

**Prueba independiente**: con el catálogo y una lista de precios de la Historia 1, dar de alta un
cliente con abono de 5 kg de café en grano y 100 cápsulas, registrar su pedido del mes desde un
celular en menos de 30 segundos, confirmar la entrega por 4 kg y verificar que la venta se generó
por lo entregado con el precio de la lista congelado y que el faltante quedó registrado.

**Escenarios de aceptación**:

1. **Dado** los datos de un cliente, **cuando** la encargada lo da de alta con razón social, CUIT o DNI, condición frente al IVA, teléfono de WhatsApp, dirección de entrega y sus tres e-mails, **entonces** el cliente queda registrado y disponible para pedidos. *(AC-01)*
2. **Dado** el alta de un cliente sin e-mail de cobranzas, **cuando** la encargada intenta guardarlo, **entonces** el sistema lo rechaza indicando que los tres e-mails son obligatorios; y con la misma dirección en los tres campos, lo guarda. *(AC-04, AC-05)*
3. **Dado** un cliente, **cuando** se le define un abono de 5 kg de café en grano y 100 cápsulas con su fecha de inicio y su día de aviso, **entonces** el abono queda guardado con esos dos artículos, cantidades, fecha de inicio y día de aviso; y otro cliente sin abono queda registrado igual y puede registrar pedidos. *(AC-07)*
4. **Dado** el alta de un abono realizada el 27/07/2026, **cuando** la encargada no modifica los valores propuestos, **entonces** la fecha de inicio queda en 27/07/2026 y el día de aviso en 27. *(AC-08)*
5. **Dado** un cliente con al menos un pedido o entrega en su historial, **cuando** se intenta borrarlo físicamente, **entonces** el sistema lo impide y sólo permite la baja lógica, y su historial sigue consultable. *(AC-03, AC-09)*
6. **Dado** que existen clientes con abono y comienza un nuevo mes, **cuando** ningún usuario confirmó todavía ningún pedido, **entonces** el tablero del mes está vacío: el sistema no crea pedidos por su cuenta. *(AC-23)*
7. **Dado** un cliente cuyo abono es de 5 kg de café en grano y 100 cápsulas, **cuando** la encargada inicia el pedido del mes, **entonces** el sistema lo precarga con esas cantidades; y al modificarlas a 3 kg y confirmar, el pedido queda por 3 kg y 100 cápsulas y el abono permanece sin cambios. *(AC-24)*
8. **Dado** un cliente sin abono, **cuando** la encargada registra un pedido con artículos y cantidades libres, **entonces** el pedido queda registrado y aparece en el tablero como pendiente de entrega. *(AC-25)*
9. **Dado** un pedido registrado por 5 kg, **cuando** la encargada confirma la entrega por 4 kg, **entonces** la entrega queda registrada con 4 kg y su fecha, el sistema genera automáticamente la venta por 4 kg con el precio de la lista del cliente congelado, el pedido queda cerrado como entregado y el faltante de 1 kg queda registrado sin generar pedido ni entrega pendiente. *(AC-27, AC-28)*
10. **Dada** una venta ya generada a $14.000, **cuando** después se actualiza el costo del artículo un 20%, **entonces** el importe de la venta sigue siendo $14.000 y la línea conserva el costo congelado de $10.000. *(AC-20, AC-21)*
11. **Dado** un pedido confirmado sin entrega asociada, **cuando** la encargada lo anula, **entonces** queda anulado y deja de figurar como pendiente; y un pedido ya entregado no puede anularse. *(AC-29)*
12. **Dada** una venta en mostrador, **cuando** la encargada registra la entrega directa sin pedido previo sobre el cliente genérico, **entonces** la entrega queda registrada y su venta se genera automáticamente, pendiente de facturar. *(AC-30)*
13. **Dado** un pedido confirmado que figura como pendiente de entrega, **cuando** se confirma su entrega, **entonces** el tablero lo muestra como entregado. *(AC-26, parte de Fase 1)*
14. **Dado** un pedido abierto por dos usuarios a la vez, **cuando** el segundo guarda después del primero, **entonces** el sistema le informa que el pedido cambió mientras lo editaba y no sobrescribe el cambio del primero. *(aclaración 2026-07-29)*

---

### Historia 3 — Ningún mensaje del cliente se pierde (Prioridad: P3)

Los clientes escriben al número único de la empresa. Todo mensaje queda guardado antes de
intentar entenderlo. La encargada abre una bandeja unificada, lee el hilo completo, responde
desde ahí, y sobre los mensajes que el sistema entendió como pedido encuentra una sugerencia que
confirma con un solo toque. Nada se registra sin que ella lo confirme, y nada desaparece de la
bandeja hasta que ella lo resuelve.

**Por qué esta prioridad**: es el objetivo O1, el dolor más caro del PRD — un pedido perdido es
un ingreso perdido. Va después de las historias 1 y 2 porque la sugerencia que la bandeja
confirma es un pedido, y el pedido tiene que existir antes de poder sugerirlo.

**Prueba independiente**: enviar un mensaje de texto desde el número de un cliente registrado
pidiendo café y verificar que queda persistido, vinculado al cliente, visible en la bandeja con
su sugerencia de pedido, y que sigue pendiente hasta que un usuario la confirma o la descarta;
después, con el servicio de interpretación caído, verificar que el mensaje igual queda en la
bandeja como pendiente de clasificar.

**Escenarios de aceptación**:

1. **Dado** el canal configurado con las credenciales de la instancia sobre el número único de la empresa, **cuando** llega o se envía un mensaje, **entonces** se cursa por ese número, sin usar teléfonos personales. *(AC-33)*
2. **Dado** un mensaje de texto de un cliente registrado pidiendo café, **cuando** el mensaje llega, **entonces** queda persistido, vinculado al cliente por su número y visible en la bandeja con una sugerencia de pedido, y permanece pendiente hasta que un usuario la confirma o la descarta; ningún pedido se crea sin esa confirmación. *(AC-34)*
3. **Dado** un mensaje de un cliente que pregunta el horario de atención, **cuando** el sistema lo interpreta, **entonces** lo clasifica como consulta, no genera sugerencia y no ingresa en la cola de pendientes. *(AC-35)*
4. **Dada** una conversación con un cliente, **cuando** la encargada abre la bandeja unificada, **entonces** lee el hilo completo desde la aplicación, y al responder desde ahí el mensaje se envía al cliente y queda en el hilo. *(AC-36)*
5. **Dado** un pedido confirmado a partir de un mensaje, **cuando** se consulta ese pedido, **entonces** puede verse el mensaje original que lo originó. *(AC-37)*
6. **Dado** un mensaje entrante de un número no asociado a ningún cliente, **cuando** más tarde se da de alta en la aplicación un cliente activo con ese teléfono, **entonces** los mensajes ya recibidos de ese número quedan vinculados a ese cliente, sin que la bandeja haya creado nada. *(AC-38, redefinido por aclaración 2026-07-29)*
7. **Dado** que el servicio de interpretación está caído, **cuando** llega un mensaje, **entonces** el mensaje queda persistido y visible en la bandeja como pendiente de clasificar, sin perderse. *(AC-79)*
8. **Dado** un mensaje entrante que es una nota de voz, una imagen o un documento, **cuando** llega, **entonces** queda persistido y visible en la bandeja como pendiente de clasificar, para que un usuario lo resuelva a mano. *(decisión de alcance, ver Supuestos)*
9. **Dada** una sugerencia de pedido en la bandeja, **cuando** la encargada la confirma desde un celular, **entonces** el pedido queda registrado con un solo toque. *(RNF-02)*
10. **Dada** una sugerencia de pedido ya confirmada por un usuario, **cuando** otro usuario intenta confirmarla, **entonces** el sistema le informa que ya fue resuelta y no crea un segundo pedido. *(aclaración 2026-07-29)*
11. **Dados** dos clientes activos que comparten el mismo teléfono, **cuando** llega un mensaje de ese número, **entonces** el mensaje queda persistido y sin vincular, la bandeja muestra los dos candidatos y el usuario elige a cuál vincularlo. *(aclaración 2026-07-29)*
12. **Dado** un mensaje cuyo envío falló y agotó sus 24 h de reintentos, **cuando** la encargada abre la bandeja, **entonces** lo ve contado entre los envíos en error definitivo y puede reintentarlo a mano. *(aclaración 2026-07-29)*
13. **Dado** un pedido que el sistema clasificó por error como consulta, **cuando** la encargada lo reclasifica a mano como pedido, **entonces** el sistema genera su sugerencia, el mensaje vuelve a la cola de pendientes y la trazabilidad con el mensaje se conserva. *(FR-041b)*
14. **Dado** un mensaje clasificado como comprobante de pago, **cuando** la encargada lo marca como resuelto, **entonces** deja de contarse entre los pendientes y queda registrado quién lo resolvió y cuándo. *(FR-041c)*

---

### Historia 4 — El sistema abre la conversación del mes (Prioridad: P4)

Cada cliente con abono vigente recibe automáticamente, el día de aviso de su abono, un mensaje
que le recuerda el envío acordado y le detalla los artículos y cantidades. Su respuesta entra a
la bandeja como cualquier otro mensaje. La encargada ve, mes a mes, a quiénes se les avisó y
quiénes todavía no contestaron.

**Por qué esta prioridad**: mitiga el riesgo de que un cliente con abono no pida y nadie lo
advierta, porque el sistema no genera pedidos por su cuenta. Invierte la iniciativa sin romper la
regla de que toda escritura la confirma una persona. Depende de la bandeja de la Historia 3 para
que la respuesta que llegue no se pierda.

**Prueba independiente**: con un cliente con abono vigente y día de aviso 5, adelantar el
calendario al día 5 y verificar que el recordatorio se envió con el detalle de su abono, que la
respuesta del cliente aparece como sugerencia pendiente y que el cliente que no respondió figura
en la lista de recordados sin respuesta.

**Escenarios de aceptación**:

1. **Dado** un cliente con abono vigente de 5 kg de café en grano y día de aviso 5, **cuando** llega el día 5 del mes, **entonces** el sistema le envía automáticamente el recordatorio del envío acordado detallando ese abono. *(AC-39)*
2. **Dado** un cliente con abono vigente cuyo día de aviso es 31, **cuando** transcurre un mes de 30 días, **entonces** el recordatorio se envía el día 30 de ese mes. *(AC-40)*
3. **Dado** ese recordatorio ya enviado, **cuando** el cliente responde, **entonces** su respuesta aparece en la bandeja como sugerencia de pedido pendiente de confirmación, sin que se cree ningún pedido automáticamente. *(AC-41)*
4. **Dado** ese recordatorio ya enviado, **cuando** el cliente aún no respondió, **entonces** figura en la lista de clientes recordados sin respuesta. *(AC-42)*
5. **Dado** un cliente cuyo abono fue dado de baja, **cuando** llega su día de aviso, **entonces** el sistema no le envía ningún recordatorio. *(deriva de «abono vigente», RF-44)*

---

### Historia 5 — Acceso por rol, auditoría consultable e instancia por configuración (Prioridad: P5)

Cada persona entra con sus credenciales y ve lo que su rol le permite. Toda operación que toca
datos económicos queda registrada con quién, cuándo, qué hizo y cuál era el valor anterior, y esa
auditoría se puede consultar desde el registro afectado. Poner en marcha la instancia de otra
empresa es cargar su configuración, sin tocar el código.

**Por qué esta prioridad**: cierra el objetivo O4 — que todo el equipo pueda usar el sistema sin
miedo a romperlo. La autenticación y la escritura automática de la auditoría son prerrequisitos
técnicos de las historias anteriores (ver Supuestos); esta historia entrega la gestión de
usuarios, la matriz de permisos completa, la consulta de la auditoría y la puesta en marcha por
configuración.

**Prueba independiente**: crear un usuario de cada rol, verificar que el Encargado de Pedidos no
puede modificar costos ni la configuración, modificar la cantidad entregada de una entrega ya
confirmada y verificar que la auditoría muestra el usuario, la fecha y el valor anterior.

**Escenarios de aceptación**:

1. **Dado** un usuario con credenciales inválidas, **cuando** intenta ingresar, **entonces** el acceso se le deniega; y con credenciales válidas, ingresa. *(AC-75)*
2. **Dado** un usuario con rol de Encargado de Pedidos, **cuando** intenta modificar los costos de los artículos o la configuración de la instancia, **entonces** el sistema le deniega el acceso. *(AC-76, adaptado a Fase 1)*
3. **Dado** un usuario con rol de Encargado de Facturación, **cuando** lee y responde una conversación de la bandeja, **entonces** puede hacerlo; y cuando intenta confirmar una sugerencia de pedido, **entonces** el sistema le deniega el acceso por no tener escritura sobre pedidos. *(aclaración 2026-07-29)*
4. **Dado** un usuario sin sesión, **cuando** invoca cualquier función del sistema salvo la verificación de salud, **entonces** el sistema le responde que no está autenticado, distinguiéndolo del caso de permisos insuficientes.
5. **Dado** que un usuario modifica la cantidad entregada de una entrega ya confirmada, **cuando** se consulta la auditoría de ese registro, **entonces** se ve qué usuario lo cambió, cuándo y cuál era el valor anterior. *(AC-77)*
6. **Dado** un pedido, **cuando** un usuario lo crea y otro lo modifica, **entonces** la auditoría registra ambos usuarios, sus acciones y las fechas. *(AC-32)*
7. **Dada** la configuración de la instancia, **cuando** el administrador carga los datos de la empresa y las credenciales del canal de mensajería y de la casilla de correo, **entonces** el sistema opera con esos valores sin ningún cambio de código. *(AC-78, parte de Fase 1)*
8. **Dado** que el sistema se despliega para una segunda empresa, **cuando** se levanta la nueva instancia, **entonces** la única diferencia respecto de la primera es su configuración, sin ningún cambio en el código. *(AC-80)*
9. **Dada** una instancia recién puesta en marcha, **cuando** se abre el listado de clientes, **entonces** existe el cliente genérico de mostrador con la dirección genérica de la empresa en sus tres campos de e-mail. *(AC-10)*

---

### Casos Borde

- **Día de aviso inexistente en el mes.** Abono con día 31 en un mes de 30 días: el recordatorio sale el último día del mes.
- **Interpretación caída.** El mensaje se persiste igual y queda pendiente de clasificar; nunca desaparece de la bandeja.
- **Mensaje de un número desconocido.** Queda en la bandeja sin cliente vinculado. La bandeja no da de alta clientes: cuando el cliente se cree en la aplicación con ese teléfono, sus mensajes anteriores se vinculan solos.
- **Mensaje de un número compartido por varios clientes.** Queda sin vincular y el usuario elige entre los candidatos; el sistema no adivina.
- **Alta de un cliente con un CUIT o DNI ya registrado en un cliente activo.** El sistema la rechaza.
- **Entrega menor que el pedido.** El pedido se cierra igual y la diferencia queda registrada como faltante, sin backorder.
- **Entrega mayor que el pedido.** La entrega se registra por lo realmente entregado y la venta se genera por esa cantidad.
- **Anulación de un pedido ya entregado.** El sistema la impide.
- **Cliente o artículo dado de baja.** No aparece para nuevos pedidos ni nuevas listas, y su historial sigue consultable e intacto.
- **Artículo de un abono dado de baja.** El pedido se precarga sin ese artículo y avisa que el abono quedó desactualizado.
- **Cantidad fraccionaria en un artículo medido por unidad.** El sistema la rechaza: las cápsulas y las presentaciones de un cuarto se piden y se entregan en enteros.
- **Alta de abono con fecha de inicio futura.** No se envía recordatorio hasta que la fecha de inicio se alcance.
- **Dos usuarios editando el mismo pedido a la vez.** Ninguno queda bloqueado; el segundo en guardar recibe el aviso de que el registro cambió mientras editaba y vuelve a cargarlo antes de decidir. Ningún cambio se sobrescribe en silencio y la auditoría registra las modificaciones que sí se aplicaron.
- **Dos usuarios confirmando la misma sugerencia de la bandeja.** La primera confirmación crea el registro; la segunda recibe el aviso de que la sugerencia ya fue resuelta y no crea un duplicado.
- **Envío que falla por indisponibilidad del canal.** Se encola y se reintenta hasta 24 h; después queda como error definitivo, visible en la bandeja y reintentable a mano.
- **Mensaje entrante que no es pedido ni pago.** Se clasifica como consulta u otro y no ingresa en la cola de pendientes. Si la clasificación fue errónea, el usuario lo reclasifica y vuelve a la cola *(FR-041b)*.
- **Comprobante de pago en Fase 1.** Queda pendiente en la bandeja hasta que alguien lo marque como resuelto; no genera cobranza, porque las cobranzas son Fase 3 *(FR-041c)*.
- **Cliente que responde el recordatorio con una negativa.** Queda en la bandeja sin sugerencia de pedido y el cliente figura como respondido.

## Requerimientos *(obligatorio)*

### Requerimientos Funcionales

Cada requerimiento indica entre paréntesis su origen en el PRD.

#### Clientes y abonos

- **FR-001**: El sistema DEBE permitir dar de alta clientes con razón social, CUIT o DNI, condición frente al IVA (Responsable Inscripto, Monotributista o Consumidor Final), teléfono de WhatsApp, dirección de entrega, e-mail general, e-mail de facturación y e-mail de cobranzas. El CUIT o DNI DEBE ser único entre los clientes activos; el teléfono de WhatsApp PUEDE repetirse entre clientes. *(RF-01)*
- **FR-002**: El sistema DEBE permitir modificar los datos de un cliente. *(RF-02)*
- **FR-003**: El sistema DEBE permitir dar de baja lógica un cliente, que deja de estar disponible para nuevos pedidos y conserva su historial consultable. *(RF-03)*
- **FR-004**: El sistema DEBE exigir los tres e-mails al guardar un cliente, admitiendo la misma dirección en los tres campos. *(RF-04)*
- **FR-005**: El sistema DEBE permitir asignar a cada cliente una lista de precios. *(RF-05)*
- **FR-006**: El sistema DEBE permitir asignar a cada cliente una forma de pago por defecto (transferencia, cheque o efectivo), sin que ese valor condicione la forma de pago efectiva de cada cobranza. *(RF-06)*
- **FR-007**: El sistema DEBE permitir definir, de forma opcional, un abono para un cliente, compuesto por varios artículos con su cantidad de referencia mensual, una fecha de inicio (por defecto, el día actual) y un día del mes para el envío del aviso (por defecto, el día de la fecha de inicio). Un cliente sin abono DEBE operar igual que uno con abono. *(RF-07)*
- **FR-008**: El sistema DEBE permitir dar de baja el abono de un cliente, que deja de estar vigente y deja de generar recordatorios. *(deriva de «abono vigente», RF-44)*
- **FR-009**: El sistema DEBE impedir el borrado físico de un cliente con historial asociado. *(RF-08)*
- **FR-010**: El sistema DEBE incluir en cada instancia un cliente genérico de mostrador («Consumidor Final»), precargado con una dirección de e-mail genérica de la empresa en sus tres campos de e-mail. *(RF-09)*

#### Artículos, costos y listas de precios

- **FR-011**: El sistema DEBE permitir dar de alta artículos con nombre, tipo (cápsulas, café molido, café en grano), presentación, unidad de medida (kilogramo o unidad), costo y porcentaje de utilidad por defecto. *(RF-11)*
- **FR-012**: El sistema DEBE permitir modificar los datos de un artículo. *(RF-12)*
- **FR-013**: El sistema DEBE permitir dar de baja artículos. *(RF-13)*
- **FR-014**: El sistema DEBE soportar las tres formas de venta del negocio: cápsulas por cantidad, café molido o en grano por kilogramo, y café molido o en grano en presentación de un cuarto por cantidad. *(RF-14)*
- **FR-015**: El sistema DEBE permitir crear listas de precios que contengan todos los artículos, con un porcentaje de utilidad propio para cada artículo dentro de la lista. *(RF-15)*
- **FR-015a**: El sistema DEBE incorporar cada artículo nuevo a todas las listas de precios existentes con su porcentaje de utilidad por defecto *(FR-011)*, quedando editable en cada lista. Ninguna lista puede quedar sin precio para un artículo activo. *(aclaración 2026-07-29)*
- **FR-016**: El sistema DEBE calcular el precio de venta de cada artículo como `costo × (1 + porcentaje de utilidad del artículo en la lista)` cuando se ingresa el porcentaje de utilidad. *(RF-16)*
- **FR-016a**: El sistema DEBE aplicar esta precisión en todo cálculo económico: cantidades con hasta 3 decimales para los artículos medidos en kilogramos y sólo enteras para los medidos por unidad; costos, precios unitarios y porcentajes de utilidad con 2 decimales, redondeando al centavo y resolviendo el empate hacia arriba. El importe de cada línea DEBE ser el precio unitario ya redondeado multiplicado por la cantidad, redondeado a 2 decimales. *(aclaración 2026-07-29)*
- **FR-017**: El sistema DEBE permitir ingresar a mano el precio de venta de un artículo en la lista, calculando el porcentaje de utilidad resultante a partir de su costo. *(RF-17)*
- **FR-018**: El sistema DEBE permitir, en una pantalla dedicada de costos, actualizar de forma masiva el costo de los artículos aplicando un porcentaje. *(RF-18)*
- **FR-019**: El sistema DEBE permitir, en esa misma pantalla, la carga individual del costo de un artículo. *(RF-19)*
- **FR-020**: El sistema DEBE congelar el precio de venta en la línea de venta al generarse la venta, de modo que ninguna actualización posterior de costos o de utilidades modifique una venta ya generada. *(RF-20)*
- **FR-021**: El sistema DEBE congelar el costo vigente del artículo en la línea de venta al generarse la venta. *(RF-21)*
- **FR-022**: El sistema DEBE registrar el historial de cambios de costo con fecha y usuario. *(RF-22)*

#### Pedidos, entregas y ventas

- **FR-023**: El sistema DEBE crear un pedido únicamente cuando un usuario lo confirma, y NUNCA DEBE generar pedidos por sí solo. *(RF-23)*
- **FR-024**: El sistema DEBE precargar el pedido con las cantidades del abono del cliente cuando éste tenga uno, permitiendo modificarlas tanto en más como en menos antes de confirmarlo, sin alterar el abono. *(RF-24)*
- **FR-025**: El sistema DEBE permitir registrar un pedido de artículos y cantidades libres. *(RF-25)*
- **FR-026**: El sistema DEBE presentar un tablero con los pedidos registrados del período y su estado: pendiente de entrega, entregado y facturado. *(RF-26)*
- **FR-027**: El sistema DEBE permitir confirmar la entrega de un pedido registrando la fecha y las cantidades realmente entregadas, que pueden diferir de las pedidas. *(RF-27)*
- **FR-028**: El sistema DEBE cerrar el pedido al confirmarse su entrega aun cuando las cantidades entregadas sean menores que las pedidas, registrando la diferencia como faltante, sin generar pedido ni entrega pendiente por esa diferencia. *(RF-28)*
- **FR-029**: El sistema DEBE permitir anular un pedido confirmado que aún no tenga entrega asociada, e impedir la anulación de uno ya entregado. *(RF-29)*
- **FR-030**: El sistema DEBE permitir registrar una entrega directa, sin pedido previo, sobre un cliente existente o sobre el cliente genérico de mostrador. *(RF-30)*
- **FR-031**: El sistema DEBE generar automáticamente una venta al confirmarse una entrega, una venta por entrega, aplicando la lista de precios del cliente, y dejarla pendiente de facturar. *(RF-32)*
- **FR-032**: El sistema DEBE registrar en auditoría qué usuario creó o modificó cada pedido y cada entrega, y cuándo. *(RF-33)*

#### Canal de mensajería con el cliente

- **FR-033**: El sistema DEBE operar sobre un único número de WhatsApp de la empresa, con las credenciales del canal parametrizadas por instancia. *(RF-34)*
- **FR-034**: El sistema DEBE persistir automáticamente todo mensaje entrante antes de cualquier interpretación, sin que ninguna persona deba copiar ni reenviar nada. *(RF-35, RNF-04)*
- **FR-035**: El sistema DEBE vincular cada mensaje persistido al cliente activo cuyo teléfono coincida con el número de origen. Cuando más de un cliente activo comparta ese número, el mensaje DEBE quedar sin vincular y el usuario DEBE poder elegir a cuál de los candidatos vincularlo desde la bandeja. *(RF-36)*
- **FR-036**: El sistema DEBE ofrecer una bandeja de entrada unificada que permita leer las conversaciones desde la propia aplicación. *(RF-37)*
- **FR-037**: El sistema DEBE permitir responder esas conversaciones desde la propia aplicación. *(RF-38)*
- **FR-038**: El sistema DEBE interpretar automáticamente cada mensaje de texto entrante y clasificarlo como pedido, comprobante de pago, consulta u otro. *(RF-39)*
- **FR-039**: El sistema DEBE dejar los mensajes de audio, imagen o documento persistidos y visibles en la bandeja en estado «pendiente de clasificar», resolubles a mano según FR-041b y FR-041c. *(decisión de alcance de Fase 1; el OCR es RF-66, Fase 3)*
- **FR-040**: El sistema DEBE proponer un registro a partir de cada mensaje interpretable y exigir la confirmación explícita de un usuario antes de escribir cualquier dato. El sistema NUNCA DEBE registrar ni responder por sí solo. *(RF-40)*
- **FR-041**: El sistema DEBE mantener visible y pendiente todo mensaje clasificado como pedido o como comprobante de pago hasta que un usuario lo resuelva, confirmándolo o descartándolo. *(RF-41)*
- **FR-041a**: El sistema DEBE permitir resolver cada sugerencia una sola vez: un segundo intento de confirmarla o descartarla DEBE informar que ya fue resuelta, sin crear un registro duplicado. *(aclaración 2026-07-29)*
- **FR-041b**: El sistema DEBE permitir a un usuario **reclasificar a mano** cualquier mensaje entrante, incluidos los pendientes de clasificar y los que el sistema clasificó mal. Reclasificar un mensaje como pedido DEBE generar su sugerencia conservando la trazabilidad con el mensaje. *(análisis 2026-07-29)*
- **FR-041c**: El sistema DEBE permitir **marcar como resuelto** un mensaje pendiente que no tiene sugerencia asociada —un comprobante de pago o uno pendiente de clasificar—, registrando quién lo resolvió y cuándo. Un mensaje está pendiente mientras esté clasificado como pedido, pago o pendiente de clasificar y no haya sido resuelto. *(análisis 2026-07-29)*
- **FR-042**: El sistema DEBE permitir confirmar una sugerencia de la bandeja con un solo toque. *(RNF-02)*
- **FR-043**: El sistema DEBE conservar la trazabilidad entre cada registro confirmado y el mensaje que lo originó, consultable desde el registro. *(RF-42)*
- **FR-044**: El sistema NO DEBE permitir crear clientes desde la bandeja: el alta ocurre únicamente en la gestión de clientes, con todos sus datos obligatorios *(FR-001, FR-004)*. Los mensajes ya recibidos de un número desconocido DEBEN vincularse automáticamente al cliente cuando se dé de alta un cliente activo con ese teléfono. *(RF-43, redefinido por aclaración 2026-07-29)*
- **FR-045**: El sistema NO DEBE generar sugerencias ni ingresar en la cola de pendientes los mensajes clasificados como consulta u otro. *(AC-35)*
- **FR-046**: El sistema DEBE encolar y reintentar automáticamente durante un máximo de 24 h los mensajes que no pudo enviar, y marcarlos después como error definitivo que requiere intervención manual, sin bloquear la operación. *(RNF-05)*
- **FR-046a**: El sistema DEBE mostrar en la bandeja, como trabajo pendiente y con su contador, los envíos en error definitivo y los mensajes pendientes de clasificar, y DEBE permitir reintentar un envío fallido a mano. Ningún fallo puede quedar visible únicamente en el registro técnico. *(aclaración 2026-07-29)*

#### Recordatorio mensual del abono

- **FR-047**: El sistema DEBE enviar automáticamente, cada mes, un mensaje a cada cliente con abono vigente, el día de aviso indicado en su abono, recordándole el envío acordado y detallando los artículos y cantidades del abono. *(RF-44)*
- **FR-048**: El sistema DEBE enviar el recordatorio el último día del mes cuando el día de aviso no exista en ese mes. *(RF-44)*
- **FR-049**: El sistema DEBE tratar la respuesta al recordatorio como cualquier otro mensaje entrante — interpretarla, proponer el pedido y esperar la confirmación de un usuario — y el recordatorio NUNCA DEBE crear un pedido por sí solo. *(RF-45)*
- **FR-050**: El sistema DEBE registrar, para cada mes, a qué clientes se les envió el recordatorio y cuáles todavía no respondieron. *(RF-46)*

#### Usuarios, auditoría y configuración de la instancia

- **FR-051**: El sistema DEBE autenticar a los usuarios con credenciales individuales. *(RF-84)*
- **FR-052**: El sistema DEBE autorizar cada acción según el rol del usuario, con esta matriz para la Fase 1: *(RF-85)*

  | Rol | Pedidos y entregas | Conversaciones | Resolver sugerencias | Clientes y abonos | Artículos y costos | Configuración y usuarios |
  |---|---|---|---|---|---|---|
  | Encargado de Pedidos | lee y escribe | lee y responde | sí | lee y escribe | lee | sin acceso |
  | Encargado de Facturación | lee | lee y responde | no | lee | lee | sin acceso |
  | Responsable de Finanzas | lee | lee | no | lee | lee | sin acceso |
  | Administrador | lee y escribe | lee y responde | sí | lee y escribe | lee y escribe | lee y escribe |

- **FR-052a**: El sistema DEBE exigir, para resolver una sugerencia, permiso de escritura sobre el área del registro que esa sugerencia crea: confirmar una sugerencia de pedido requiere escritura sobre pedidos y entregas. Leer y responder una conversación NUNCA DEBE habilitar por sí solo la creación de registros. *(aclaración 2026-07-29)*

- **FR-053**: El sistema DEBE distinguir la falta de sesión de la falta de permisos al denegar una acción, porque la interfaz reacciona distinto a cada caso. *(deriva de RF-85)*
- **FR-054**: El sistema DEBE permitir al Administrador dar de alta usuarios, darlos de baja y cambiarles el rol. *(deriva de RF-84, RF-85)*
- **FR-055**: El sistema DEBE registrar en auditoría toda operación que modifique datos económicos, guardando usuario, fecha, acción y valor anterior. *(RF-86, RNF-08)*
- **FR-055a**: El sistema DEBE detectar que un registro fue modificado por otro usuario mientras se lo editaba y rechazar ese guardado informando el conflicto, en lugar de sobrescribir el cambio anterior. NUNCA DEBE bloquear un registro para impedir que otro usuario lo abra. *(aclaración 2026-07-29, RNF-06)*
- **FR-056**: El sistema DEBE permitir consultar la auditoría de un registro desde ese registro. *(AC-77)*
- **FR-057**: El sistema DEBE permitir configurar por instancia los datos de la empresa emisora, sin requerir cambios en el código. *(RF-87)*
- **FR-058**: El sistema DEBE permitir configurar por instancia las credenciales de los servicios externos — canal de mensajería y casilla de correo de la empresa — sin requerir cambios en el código, y NUNCA DEBE alojarlas en el repositorio. *(RF-88, RNF-10)*
- **FR-059**: El sistema NO DEBE borrar físicamente ningún registro con historial económico asociado: las correcciones se hacen por baja lógica, anulación o ajuste con motivo. *(RNF-09)*
- **FR-060**: El sistema DEBE presentar toda su interfaz en español de Argentina y operar únicamente en pesos argentinos. *(RNF-13)*

### Entidades Clave

- **Cliente**: quien compra. Razón social, CUIT o DNI, condición frente al IVA, número de WhatsApp, dirección de entrega, tres e-mails, lista de precios asignada, forma de pago por defecto, estado (activo o dado de baja). El CUIT o DNI lo identifica de forma única entre los activos; el teléfono no es identificador. Incluye el cliente genérico de mostrador.
- **Abono**: acuerdo mensual opcional de un cliente. Artículos con su cantidad de referencia, fecha de inicio, día de aviso y estado de vigencia.
- **Artículo**: lo que se vende. Nombre, tipo, presentación, unidad de medida, costo vigente, porcentaje de utilidad por defecto, estado.
- **Cambio de costo**: cada modificación del costo de un artículo, con valor anterior, valor nuevo, fecha y usuario.
- **Lista de precios**: conjunto de **todos** los artículos activos con el porcentaje de utilidad de cada uno; se asigna a clientes. Los artículos nuevos entran solos con su utilidad por defecto.
- **Pedido**: lo que el cliente pidió, nacido de la confirmación de un usuario. Cliente, período, líneas con artículo y cantidad, estado (pendiente de entrega, entregado, anulado), mensaje de origen si lo hubo.
- **Entrega**: lo que realmente salió. Pedido asociado (opcional en mostrador), fecha, líneas con artículo, cantidad entregada y faltante.
- **Venta**: consecuencia económica de una entrega. Cliente, fecha, líneas con artículo, cantidad, precio unitario congelado, costo unitario congelado e importe de línea, estado de facturación (pendiente de facturar). Los importes se rigen por la precisión de FR-016a.
- **Conversación**: hilo de mensajes con un número de teléfono, vinculado a un cliente cuando el número se reconoce.
- **Mensaje**: cada mensaje entrante o saliente. Contenido, tipo, fecha, dirección, clasificación (pedido, pago, consulta, otro o pendiente de clasificar) y estado de envío para los salientes.
- **Sugerencia**: registro propuesto a partir de un mensaje, pendiente hasta que un usuario lo confirma o lo descarta. Conserva el vínculo con el mensaje y con el registro que generó.
- **Recordatorio de abono**: envío mensual a un cliente con abono vigente. Mes, fecha de envío, estado y si el cliente respondió.
- **Usuario**: quien opera el sistema. Credenciales individuales y rol.
- **Asiento de auditoría**: registro automático de cada operación sobre datos económicos, con usuario, fecha, acción y valor anterior.

## Criterios de Éxito *(obligatorio)*

### Resultados Medibles

- **SC-001**: El 100% de los mensajes que llegan al número de la empresa queda visible en la bandeja, incluso cuando la interpretación falla. Ninguno se pierde.
- **SC-002**: El 100% de los mensajes entendidos como pedido o como pago permanece pendiente hasta que una persona lo confirma o lo descarta. Ninguno se cierra solo.
- **SC-003**: Registrar un pedido desde un celular toma menos de 30 segundos, y confirmar una sugerencia de la bandeja requiere 1 solo toque.
- **SC-004**: El 100% de los clientes con abono vigente recibe su recordatorio en su día de aviso, y quienes no responden aparecen en la lista de recordados sin respuesta.
- **SC-005**: Toda pantalla de operación diaria responde en menos de 3 segundos en el percentil 95, con al menos 150 clientes, 150 pedidos mensuales y 3 años de historia.
- **SC-006**: 4 usuarios trabajan en simultáneo sin bloqueos ni pérdida de datos: 0 sobrescrituras silenciosas y 0 registros duplicados por una doble confirmación.
- **SC-007**: El 0% de las ventas ya generadas ve alterado su importe ni su costo registrado por un cambio posterior de costo o de porcentaje de utilidad.
- **SC-008**: El 100% de las operaciones que modifican datos económicos queda registrado con usuario, fecha, acción y valor anterior, y es consultable desde el registro afectado.
- **SC-009**: El 0% de los registros con historial económico se borra físicamente.
- **SC-010**: El equipo opera un mes completo sin tocar el Excel — criterio de salida de la Fase 1.
- **SC-011**: Las pantallas de pedidos, entregas y bandeja son plenamente operables en un navegador móvil de 360 px de ancho, sin scroll horizontal.
- **SC-012**: Poner en marcha la instancia de otra empresa lleva menos de 1 día y 0 cambios de código.
- **SC-013**: Ante una caída, la pérdida máxima de información es de 1 hora y el sistema vuelve a estar operativo en menos de 1 hora, con procedimiento de restauración probado.
- **SC-014**: El 100% de la interfaz está en español de Argentina y la única moneda es el peso argentino.
- **SC-015**: 0 credenciales residen en el repositorio de código.
- **SC-016**: El importe de cada línea de venta es exactamente su precio unitario congelado multiplicado por la cantidad entregada: 0 diferencias de redondeo entre lo que se muestra y lo que se registra.
- **SC-017**: El 100% de los envíos en error definitivo y de los mensajes pendientes de clasificar es visible desde la bandeja. 0 fallos existen únicamente en el registro técnico.

## Fuera de Alcance

Además de todo lo que el PRD ya declara fuera de alcance, esta especificación **excluye** lo que
el PRD ubica en fases posteriores:

- **Fase 2 — Facturación.** Configuración fiscal del emisor, proceso de facturación, emisión contra ARCA, CAE, tipo de comprobante por condición fiscal, IVA, PDF con QR, notas de crédito, envío del comprobante por e-mail y e-mail de facturación específico de una venta de mostrador *(RF-31, RF-50 a RF-65)*. El estado «facturado» del tablero existe, pero nada lo alcanza todavía en Fase 1.
- **Fase 3 — Cobranzas, cuenta corriente y reportes.** OCR de comprobantes, registro de cobranzas, saldo de cuenta corriente, saldo a favor, deudores, ajustes manuales, lectura de la casilla de cobranzas, historial de consumo del cliente, envíos de comprobante, resumen de cuenta y reclamo por WhatsApp, y todos los reportes *(RF-10, RF-47 a RF-49, RF-66 a RF-83)*.
- **Interpretación de audio, imagen y documentos.** En Fase 1 se persisten y quedan pendientes de clasificar para resolución manual *(FR-039)*.
- **Alta de clientes desde la bandeja.** Redefine RF-43 del PRD: un cliente no se crea desde WhatsApp. El alta ocurre siempre en la gestión de clientes, con sus datos obligatorios, y los mensajes previos de ese teléfono se vinculan solos *(FR-044)*.

## Supuestos

- **Abono vigente** significa que su fecha de inicio ya se alcanzó, no fue dado de baja *(FR-008)* y su cliente está activo. El PRD define fecha de inicio pero no de fin.
- **El recordatorio mensual se envía en el día de aviso incluso si el cliente ya tiene un pedido registrado ese mes.** El PRD lo define por día de aviso, no por ausencia de pedido.
- **La interpretación automática cubre sólo mensajes de texto en Fase 1.** Los demás tipos se persisten y quedan pendientes de clasificar; el OCR llega con la Fase 3.
- **La matriz de permisos de FR-052 refleja cómo trabaja hoy el equipo**: cada rol escribe en su área y lee el resto. Se revisará al incorporar facturación y reportes, donde la separación pesa más.
- **La autenticación *(FR-051)* y la escritura automática de la auditoría *(FR-055)* son prerrequisitos técnicos de las historias 1 a 4**, aunque la Historia 5 entregue la gestión de usuarios, la matriz completa y su consulta. Ninguna función del sistema opera sin sesión.
- **La instancia se pone en marcha con un usuario Administrador inicial** provisto por configuración; el PRD no especifica cómo nace el primer usuario.
- **El sistema arranca vacío.** No hay migración de los datos históricos del Excel, y la doble carga se admite sólo durante el primer mes de transición.
- **La entrega puede registrar cantidades mayores que las pedidas.** La venta se genera por lo realmente entregado; el PRD sólo norma el caso de la cantidad menor.
- **Una entrega genera exactamente una venta**, y una venta pertenece a un único cliente.
- **El período del tablero es el mes calendario**, coherente con el ciclo mensual del abono y de la facturación.
- **La cuenta de WhatsApp Business, la verificación del negocio en Meta y la plantilla aprobada para el recordatorio mensual son un prerrequisito externo** cuyo trámite corre por fuera del desarrollo y bloquea el primer release.
