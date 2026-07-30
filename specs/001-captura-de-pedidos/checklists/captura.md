# Checklist de Captura y Bandeja: Fase 1 — Fuente de verdad única y captura de pedidos

**Propósito**: validar la **calidad de los requerimientos** de la mensajería con el cliente — persistencia, interpretación, cola de pendientes y recordatorio mensual. Cada ítem pregunta si lo escrito alcanza para implementar y verificar la promesa O1 («ningún pedido se pierde») sin adivinar.
**Creado**: 2026-07-29
**Funcionalidad**: [spec.md](../spec.md)
**Profundidad**: puerta formal previa a `/speckit-plan`

## Completitud de los Requerimientos

- [ ] CHK001 - ¿Está definido el criterio por el cual un mensaje se clasifica como pedido, pago, consulta u otro, o queda enteramente librado al intérprete? [Claridad, Spec §FR-038]
- [ ] CHK002 - ¿Está definido qué contiene una sugerencia de pedido: artículos y cantidades extraídos del mensaje, o sólo la señal de que hay un pedido? [Claridad, Spec §FR-040]
- [ ] CHK003 - ¿Existe requerimiento para el caso en que la interpretación es dudosa o de baja confianza, distinto del caso en que falla? [Hueco, Spec §FR-038, §FR-040]
- [x] CHK004 - ¿Existe requerimiento para reclasificar a mano un mensaje que el sistema clasificó mal — por ejemplo, un pedido leído como consulta? **Resuelto 2026-07-29**: FR-041b agrega la reclasificación manual, que genera la sugerencia y conserva la trazabilidad. [Hueco resuelto, Spec §FR-041b, §FR-045]
- [ ] CHK005 - ¿Existe requerimiento de deduplicación para el mismo mensaje entrante reentregado más de una vez por el canal? [Hueco, Spec §FR-034]
- [ ] CHK006 - ¿Está definido qué ocurre con un mensaje proveniente del número de un cliente dado de baja? [Hueco, Spec §FR-035, §FR-003]
- [ ] CHK007 - ¿Está definido cómo se resuelve una sugerencia que no puede confirmarse tal cual — por ejemplo, un pedido de un artículo inexistente o dado de baja? Sigue abierto: FR-041c cubre los pendientes **sin** sugerencia, no la sugerencia inconfirmable. [Hueco, Spec §FR-040, §FR-041]
- [ ] CHK008 - ¿Está definido si descartar una sugerencia exige un motivo, y si ese descarte queda registrado? [Hueco, Spec §FR-041]
- [ ] CHK009 - ¿Están definidos el almacenamiento y la retención del contenido de los mensajes, incluidas las imágenes, audios y documentos que FR-039 manda persistir? [Hueco, Spec §FR-034, §FR-039]
- [ ] CHK010 - ¿Existe algún requerimiento sobre el tratamiento del contenido de las conversaciones como dato personal del cliente? [Hueco, Spec §FR-034]
- [ ] CHK011 - ¿Está definido el orden o la priorización de la cola de pendientes, o cualquier orden satisface el requerimiento? [Hueco, Spec §FR-041]
- [ ] CHK012 - ¿Está definido el comportamiento cuando un cliente con abono vigente no tiene teléfono válido al llegar su día de aviso? [Hueco, Spec §FR-047]
- [ ] CHK013 - ¿Está definida la zona horaria que determina el día de aviso, el «último día del mes» y el corte del período? Sin ella, FR-048 y el tablero son ambiguos. [Hueco, Spec §FR-047, §FR-048, §FR-026]

## Claridad y Ambigüedad

- [ ] CHK014 - ¿Está definido qué es un mensaje «interpretable», término del que depende toda la regla de confirmación? [Ambigüedad, Spec §FR-040]
- [ ] CHK015 - ¿Está definido qué cuenta como «respondió» para la lista de recordados sin respuesta: cualquier mensaje entrante posterior, o sólo uno clasificado como pedido? [Ambigüedad, Spec §FR-050]
- [ ] CHK016 - ¿Está definido si el recordatorio del mes de alta del abono se envía cuando la fecha de inicio cae después del día de aviso de ese mes? [Ambigüedad, Spec §FR-047, §Casos Borde]
- [ ] CHK017 - ¿Está definido desde qué momento se cuentan las 24 h de reintento: el primer intento fallido o el encolado del mensaje? [Claridad, Spec §FR-046]
- [ ] CHK018 - ¿Está definido si un mensaje «pendiente de clasificar» puede pasar a interpretarse luego, o su única salida es la carga manual? [Ambigüedad, Spec §FR-039]
- [ ] CHK019 - ¿Está definido si «un solo toque» incluye la revisión previa de la sugerencia, o exige confirmarla sin abrirla? [Claridad, Medibilidad, Spec §FR-042, §SC-003]

## Consistencia Interna

- [x] CHK020 - ¿El alta de clientes está definida en un único lugar, sin que la bandeja pueda crear clientes con datos incompletos? **Resuelto 2026-07-29**: FR-044 se redefinió — el alta vive sólo en la gestión de clientes y los mensajes previos se vinculan solos. [Conflicto resuelto, Spec §FR-044, §FR-001, §FR-004]
- [ ] CHK021 - ¿La regla de vinculación por teléfono es consistente entre el caso de número desconocido, el de número compartido y el de cliente dado de baja? [Consistencia, Spec §FR-035, §FR-044]
- [ ] CHK022 - ¿Los requerimientos de la cola de pendientes y los de la clasificación coinciden en qué clases de mensaje entran en la cola? [Consistencia, Spec §FR-041, §FR-045]
- [ ] CHK023 - ¿El requerimiento de responder desde la aplicación es consistente con la restricción externa de que un mensaje iniciado por la empresa requiere plantilla aprobada? [Consistencia, Spec §FR-037, §Supuestos]
- [ ] CHK024 - ¿La trazabilidad exigida entre registro y mensaje cubre también la dirección inversa, desde el mensaje al registro que originó? [Completitud, Spec §FR-043]

## Calidad de los Criterios de Aceptación

- [ ] CHK025 - ¿«El 100% de los mensajes queda visible en la bandeja» es verificable con lo que el spec exige registrar sobre los mensajes recibidos? [Medibilidad, Spec §SC-001]
- [ ] CHK026 - ¿Existe criterio de aceptación que distinga un mensaje perdido de uno persistido pero no mostrado? [Cobertura, Spec §SC-001, §FR-034]
- [ ] CHK027 - ¿«El 100% de los clientes con abono vigente recibe su recordatorio» está acotado a los casos en que el envío es posible (número válido, canal disponible)? [Medibilidad, Spec §SC-004, §FR-046]
- [ ] CHK028 - ¿Los escenarios de aceptación cubren la clasificación errónea, además de la interpretación caída? [Cobertura, Spec §Historia 3]

## Cobertura de Escenarios y Casos Borde

- [x] CHK029 - ¿Está cubierta la vinculación retroactiva de los mensajes que llegaron antes de que el cliente existiera? **Resuelto 2026-07-29**: FR-044 lo exige explícitamente. [Cobertura, Caso borde, Spec §FR-044]
- [ ] CHK030 - ¿Está cubierto el volumen del día de aviso más cargado, cuando el recordatorio abre decenas de conversaciones a la vez, y el límite de tasa del canal? [Hueco, Dependencia, Spec §FR-047]
- [ ] CHK031 - ¿Está cubierto el escenario de un mensaje entrante recibido fuera del horario laboral o durante una caída de la aplicación? [Cobertura, Spec §FR-034]
- [ ] CHK032 - ¿Está cubierto qué pasa con las sugerencias pendientes de un cliente que se da de baja? [Caso borde, Hueco, Spec §FR-003, §FR-041]
- [ ] CHK033 - ¿Está cubierto el recordatorio de un abono cuyo día de aviso es 29 en febrero, además del caso del 31? [Cobertura, Spec §FR-048]
- [ ] CHK034 - ¿Está cubierta la respuesta del cliente que llega semanas después del recordatorio, ya entrado el mes siguiente? [Caso borde, Hueco, Spec §FR-049, §FR-050]

## Supuestos y Dependencias

- [ ] CHK035 - ¿Está documentado como dependencia bloqueante que la plantilla del recordatorio necesita aprobación externa antes del primer release? [Dependencia, Spec §Supuestos]
- [ ] CHK036 - ¿Está documentado el supuesto de que el equipo abandona sus teléfonos personales, del que depende toda la captura? [Supuesto, Dependencia, Spec §FR-033]
- [ ] CHK037 - ¿Está declarado el supuesto de que existe un servicio de interpretación externo con costo y disponibilidad propios, más allá de su modo de falla? [Supuesto, Spec §FR-038, §Historia 3]
- [ ] CHK038 - ¿Está documentado el supuesto de que la bandeja es la única superficie donde el equipo se entera de los fallos, sin aviso fuera de la aplicación? [Supuesto, Spec §FR-046a, §SC-017]

## Notas

- Este checklist audita el **texto del spec**, no la implementación. Un ítem sin marcar significa que el requerimiento no está escrito con la precisión necesaria.
- CHK020 y CHK029 quedaron resueltos el 2026-07-29 al redefinir FR-044: un cliente no se crea desde WhatsApp, se crea en la aplicación, y los mensajes anteriores de ese teléfono se vinculan solos.
- CHK004, CHK005 y CHK013 son los huecos de mayor riesgo para la promesa O1: una clasificación errónea sin vuelta atrás, un mensaje duplicado y un corte de día ambiguo son las tres formas silenciosas de perder un pedido.
