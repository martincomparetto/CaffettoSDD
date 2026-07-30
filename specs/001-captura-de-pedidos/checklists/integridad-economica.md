# Checklist de Integridad Económica: Fase 1 — Fuente de verdad única y captura de pedidos

**Propósito**: validar la **calidad de los requerimientos** que gobiernan costos, precios, ventas y auditoría — no el comportamiento del sistema. Cada ítem pregunta si lo escrito en el spec alcanza para implementar y verificar sin adivinar.
**Creado**: 2026-07-29
**Funcionalidad**: [spec.md](../spec.md)
**Profundidad**: puerta formal previa a `/speckit-plan`

## Completitud de los Requerimientos

- [ ] CHK001 - ¿Están enumerados los datos que cuentan como «económicos», o queda a interpretación de quien implemente? [Claridad, Spec §FR-055]
- [ ] CHK002 - ¿Existe requerimiento para corregir una entrega ya confirmada y para el efecto de esa corrección sobre la venta ya generada? El spec sólo norma la anulación del pedido sin entrega. [Hueco, Spec §FR-029, §FR-031]
- [ ] CHK003 - ¿Está definido qué pasa con la venta cuando la entrega que la generó se corrige o se anula? [Hueco, Spec §FR-031]
- [ ] CHK004 - ¿Están definidos los límites válidos del costo de un artículo (cero, negativo, sin costo)? [Hueco, Spec §FR-011]
- [ ] CHK005 - ¿Está definido si se admite un porcentaje de utilidad negativo, o un precio de venta menor al costo? [Hueco, Spec §FR-015, §FR-017]
- [ ] CHK006 - ¿Está definido qué artículos abarca la actualización masiva de costos: incluye o excluye los dados de baja? [Hueco, Spec §FR-018]
- [ ] CHK007 - ¿Está definido si la actualización masiva admite un porcentaje negativo para bajar costos? [Hueco, Spec §FR-018]
- [ ] CHK008 - ¿Está requerido que la actualización masiva deje su asiento en el historial de costos de cada artículo afectado? [Completitud, Spec §FR-018, §FR-022]
- [ ] CHK009 - ¿Está definido si un costo cargado por error puede corregirse, y qué queda registrado en ese caso? [Hueco, Spec §FR-019, §FR-022]
- [ ] CHK010 - ¿Está definido qué lista de precios se aplica cuando el cliente no tiene ninguna asignada? FR-005 permite asignarla pero no la exige. [Hueco, Spec §FR-005, §FR-031]
- [ ] CHK011 - ¿Está definida la lista de precios del cliente genérico de mostrador? [Hueco, Spec §FR-010, §FR-030]
- [ ] CHK012 - ¿Está definido si el importe de la venta es neto o final, de modo que la Fase 2 pueda discriminar IVA sin reinterpretar ventas ya congeladas? [Hueco, Spec §FR-031]
- [ ] CHK013 - ¿Está requerida la retención indefinida del historial económico, o sólo la prohibición de borrar? [Completitud, Spec §FR-059]
- [ ] CHK014 - ¿Está definido si un artículo o un cliente sin historial económico puede borrarse físicamente, o la prohibición es absoluta? [Claridad, Spec §FR-009, §FR-013, §FR-059]

## Claridad y Ambigüedad

- [ ] CHK015 - Cuando el precio se ingresa a mano y la utilidad derivada no lo reproduce exactamente con 2 decimales, ¿está definido cuál de los dos valores manda? [Ambigüedad, Spec §FR-016a, §FR-017]
- [ ] CHK016 - ¿Está definida la fecha que lleva la venta: la de la entrega, la de confirmación o la del día en curso? [Claridad, Spec §FR-031]
- [ ] CHK017 - ¿Está definido si el faltante se registra sólo como cantidad o también valorizado? [Claridad, Spec §FR-028]
- [ ] CHK018 - ¿Está definido el «período» del tablero con precisión suficiente (mes calendario, zona horaria de corte) para que dos personas coincidan en qué pedidos entran? [Claridad, Spec §FR-026, Supuestos]
- [ ] CHK019 - ¿Está definido qué significa «costo vigente» en el momento exacto en que se congela la línea de venta? [Claridad, Spec §FR-021]
- [ ] CHK020 - ¿Está definido el momento en que el precio queda congelado: al confirmar la entrega o al generarse la venta, si pudieran diferir? [Ambigüedad, Spec §FR-020, §FR-031]

## Consistencia Interna

- [ ] CHK021 - ¿La matriz de permisos incluye la consulta de auditoría, o queda un requerimiento sin rol asignado? [Consistencia, Spec §FR-052, §FR-056]
- [ ] CHK022 - ¿La matriz de permisos define quién puede anular un pedido, siendo una acción con efecto económico dentro de «Pedidos y entregas»? [Consistencia, Spec §FR-029, §FR-052]
- [ ] CHK023 - ¿Los requerimientos de precisión de FR-016a se aplican de forma consistente al cálculo del precio, a la utilidad derivada y al importe de la línea, sin regla contradictoria entre ellos? [Consistencia, Spec §FR-016, §FR-016a, §FR-017]
- [ ] CHK024 - ¿La prohibición de borrado físico y la baja lógica del cliente y del artículo se enuncian sin contradicción entre sí? [Consistencia, Spec §FR-003, §FR-013, §FR-059]
- [ ] CHK025 - ¿El requerimiento de auditoría automática y el de concurrencia describen el mismo comportamiento cuando un guardado se rechaza por conflicto (¿queda o no asiento de auditoría)? [Consistencia, Spec §FR-055, §FR-055a]

## Calidad de los Criterios de Aceptación

- [ ] CHK026 - ¿«El 0% de las ventas ve alterado su importe» es verificable con los datos que el spec exige registrar? [Medibilidad, Spec §SC-007]
- [ ] CHK027 - ¿«El 100% de las operaciones que modifican datos económicos» es medible sin la enumeración que pide CHK001? [Medibilidad, Spec §SC-008]
- [ ] CHK028 - ¿Los escenarios de aceptación económicos usan valores que permiten distinguir la regla de redondeo elegida, o todos cierran en números exactos? [Calidad de criterios, Spec §Historia 1, §Historia 2]
- [ ] CHK029 - ¿Existe criterio de aceptación para el asiento de auditoría de una **creación**, donde no hay valor anterior? [Cobertura, Spec §FR-055]

## Cobertura de Escenarios y Casos Borde

- [ ] CHK030 - ¿Está cubierto el escenario de un cambio de costo ocurrido entre la confirmación de la entrega y la generación de la venta? [Cobertura, Caso borde, Spec §FR-020, §FR-021]
- [ ] CHK031 - ¿Está cubierta la actualización masiva de costos ejecutada por dos usuarios a la vez, dado que toca todos los artículos? [Cobertura, Spec §FR-018, §FR-055a]
- [ ] CHK032 - ¿Está cubierto el pedido que incluye un artículo dado de baja después de haberse precargado desde el abono, y su efecto sobre el precio? [Cobertura, Spec §FR-024, §Casos Borde]
- [ ] CHK033 - ¿Está cubierta la entrega con cantidad mayor a la pedida en los requerimientos, o vive sólo como supuesto? [Cobertura, Spec §Supuestos, §FR-027]
- [ ] CHK034 - ¿Está cubierta la entrega de cantidad cero o la entrega vacía? [Caso borde, Hueco, Spec §FR-027]

## Supuestos y Dependencias

- [ ] CHK035 - ¿El supuesto «una entrega genera exactamente una venta» está reflejado como requerimiento verificable y no sólo como supuesto? [Supuesto, Spec §Supuestos, §FR-031]
- [ ] CHK036 - ¿Está validado el supuesto de que la Fase 2 podrá facturar ventas congeladas en Fase 1 sin necesitar datos que hoy no se registran (condición fiscal al momento de la venta, discriminación de IVA)? [Supuesto, Dependencia, Spec §Fuera de Alcance]
- [ ] CHK037 - ¿Está documentado si el porcentaje de utilidad por defecto del artículo debe conservar su valor histórico, o sólo importa el vigente? [Supuesto, Spec §FR-011, §FR-015a]

## Notas

- Este checklist audita el **texto del spec**, no la implementación. Un ítem sin marcar significa que el requerimiento no está escrito con la precisión necesaria, no que el sistema falle.
- Los ítems marcados `[Hueco]` señalan requerimientos ausentes; resolverlos puede requerir volver a `/speckit-clarify` o editar el spec directamente.
- CHK002 y CHK003 son los de mayor riesgo: el spec permite modificar una entrega ya confirmada (lo asume el escenario de auditoría de la Historia 5) pero no dice qué pasa con su venta.
