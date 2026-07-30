# Checklist de Seguridad y Acceso: Fase 1 — Fuente de verdad única y captura de pedidos

**Propósito**: validar la **calidad de los requerimientos** de autenticación, autorización, credenciales y configuración por instancia. Cada ítem pregunta si lo escrito alcanza para implementar y verificar sin adivinar, no si el sistema es seguro.
**Creado**: 2026-07-29
**Funcionalidad**: [spec.md](../spec.md)
**Profundidad**: puerta formal previa a `/speckit-plan`

## Completitud de los Requerimientos

- [ ] CHK001 - ¿Están definidos la duración de la sesión, su caducidad y su renovación? El spec exige autenticar pero no dice cuánto dura la sesión. [Hueco, Spec §FR-051]
- [ ] CHK002 - ¿Existen requerimientos de política de contraseña (longitud, complejidad, cambio) para las credenciales individuales? [Hueco, Spec §FR-051]
- [ ] CHK003 - ¿Existe requerimiento sobre intentos fallidos consecutivos — bloqueo, demora o ninguno? [Hueco, Spec §FR-051, §AC-75]
- [ ] CHK004 - ¿Existe requerimiento para recuperar el acceso de un usuario que olvidó su contraseña? [Hueco, Spec §FR-051, §FR-054]
- [ ] CHK005 - ¿Está definido si un usuario puede tener más de un rol a la vez, o exactamente uno? La matriz asume un rol por usuario sin decirlo. [Hueco, Spec §FR-052]
- [ ] CHK006 - ¿Está requerido que las credenciales de los servicios externos se almacenen cifradas, y no sólo que no vivan en el repositorio? RNF-10 exige ambas cosas; FR-058 recoge una. [Hueco, Trazabilidad, Spec §FR-058]
- [ ] CHK007 - ¿Está requerido que la instancia falle al arrancar cuando su configuración es inválida o incompleta, en lugar de fallar en la primera operación? [Hueco, Spec §FR-057, §FR-058]
- [ ] CHK008 - ¿Está definido si la configuración de la instancia puede cambiarse en caliente o exige reinicio? [Hueco, Spec §FR-057]
- [ ] CHK009 - ¿Existe requerimiento de auditoría para los eventos de seguridad (ingresos, ingresos fallidos, denegaciones, cambios de rol)? FR-055 cubre sólo datos económicos. [Hueco, Spec §FR-055]
- [ ] CHK010 - ¿Está definido cómo nace el primer usuario administrador como requerimiento, o vive únicamente como supuesto? [Completitud, Supuesto, Spec §Supuestos, §FR-054]
- [ ] CHK011 - ¿Está requerido que el administrador inicial deba cambiar su credencial provista por configuración antes de operar? [Hueco, Spec §Supuestos]
- [ ] CHK012 - ¿Existe requerimiento sobre el tratamiento de los datos personales del cliente (CUIT o DNI, teléfono, dirección) que el sistema almacena? [Hueco, Spec §FR-001]
- [ ] CHK013 - ¿Está definido qué pasa con la sesión abierta de un usuario al que se le da de baja o se le cambia el rol? [Hueco, Spec §FR-054]
- [ ] CHK014 - ¿Está definido si la verificación de salud, único punto sin autenticación, expone o no información de la instancia? [Hueco, Spec §Historia 5, escenario 3]

## Claridad y Ambigüedad

- [ ] CHK015 - ¿«Lee y escribe» está definido con precisión suficiente para saber si incluye crear, modificar, dar de baja y anular, o admite lecturas distintas por área? [Ambigüedad, Spec §FR-052]
- [ ] CHK016 - ¿Está definido si «sin acceso» significa no ver la función o verla deshabilitada? [Claridad, Spec §FR-052]
- [ ] CHK017 - Resolver sugerencias ya quedó separado de conversar, pero ¿la matriz distingue **leer** una conversación de **responderla**, que siguen unidas en una sola celda? [Claridad, Spec §FR-052]
- [ ] CHK018 - ¿Está definido el alcance de «configuración y usuarios» como una sola celda de la matriz, siendo dos capacidades distintas? [Claridad, Spec §FR-052]

## Consistencia Interna

- [x] CHK019 - El Encargado de Facturación tiene escritura en la bandeja y sólo lectura en pedidos, pero confirmar una sugerencia crea un pedido. ¿Está resuelta esa contradicción? **Resuelto 2026-07-29**: la matriz separa conversar de resolver sugerencias y FR-052a ata el permiso al área del registro que se crea. [Conflicto resuelto, Spec §FR-052, §FR-052a, §FR-040]
- [ ] CHK020 - ¿La matriz cubre la consulta de auditoría, que ninguna de sus cinco columnas menciona? [Consistencia, Spec §FR-052, §FR-056]
- [ ] CHK021 - ¿La matriz cubre la lista de clientes recordados sin respuesta y el disparo del recordatorio? [Consistencia, Spec §FR-052, §FR-047, §FR-050]
- [ ] CHK022 - ¿El requerimiento de distinguir falta de sesión de falta de permisos es consistente con lo que la matriz define como «sin acceso»? [Consistencia, Spec §FR-053, §FR-052]
- [ ] CHK023 - ¿La prohibición de exponer credenciales convive sin contradicción con el requerimiento de configurarlas por instancia desde la aplicación? [Consistencia, Spec §FR-057, §FR-058]

## Calidad de los Criterios de Aceptación

- [ ] CHK024 - ¿«0 credenciales residen en el repositorio de código» está expresado de forma que pueda verificarse de manera objetiva y repetible? [Medibilidad, Spec §SC-015]
- [ ] CHK025 - ¿Existe criterio de aceptación para la denegación por rol de cada área de la matriz, o sólo para el ejemplo del Encargado de Pedidos? [Cobertura, Spec §Historia 5, §FR-052]
- [ ] CHK026 - ¿Existe criterio de aceptación que verifique la distinción entre respuesta por falta de sesión y por permisos insuficientes? [Calidad de criterios, Spec §FR-053]
- [ ] CHK027 - ¿«Menos de 1 día y 0 cambios de código» para poner en marcha una instancia es verificable con lo que el spec exige documentar de la configuración? [Medibilidad, Spec §SC-012]

## Cobertura de Escenarios y Casos Borde

- [ ] CHK028 - ¿Está cubierto el intento de darse de baja a sí mismo, o de quitarse el rol de administrador siendo el único? [Caso borde, Hueco, Spec §FR-054]
- [ ] CHK029 - ¿Está cubierto el escenario de quedarse sin ningún administrador activo en la instancia? [Caso borde, Hueco, Spec §FR-054]
- [ ] CHK030 - ¿Está cubierto el acceso concurrente del mismo usuario desde dos dispositivos, algo esperable en una operación mayormente móvil? [Cobertura, Hueco, Spec §FR-051, §SC-011]
- [ ] CHK031 - ¿Está cubierto qué ocurre cuando las credenciales del canal de mensajería son válidas al arrancar pero dejan de serlo después? [Cobertura, Spec §FR-058, §FR-046]
- [ ] CHK032 - ¿Está cubierta la rotación de una credencial de servicio externo sin interrumpir la operación? [Hueco, Spec §FR-058]

## Supuestos y Dependencias

- [ ] CHK033 - ¿Está documentado el supuesto de que la autenticación es prerrequisito de las historias 1 a 4, con el efecto que eso tiene sobre el orden de construcción? [Supuesto, Spec §Supuestos]
- [ ] CHK034 - ¿Está declarado el supuesto de que cada empresa tiene su instancia y su base, de modo que no hacen falta requerimientos de aislamiento entre carteras de clientes? [Supuesto, Spec §SC-012, §Fuera de Alcance]
- [ ] CHK035 - ¿Está documentado quién es responsable de custodiar las credenciales de la instancia fuera del sistema? [Dependencia, Hueco, Spec §FR-058]

## Notas

- Este checklist audita el **texto del spec**, no la implementación ni la postura de seguridad del sistema.
- CHK019 quedó resuelto el 2026-07-29: la matriz pasó de cinco a seis columnas, separando «Conversaciones» de «Resolver sugerencias», y FR-052a ata el permiso de resolver al área del registro que la sugerencia crea. CHK017 sigue abierto por la parte que no se tocó: leer y responder siguen siendo una sola capacidad.
- CHK006 es una omisión de trazabilidad frente al PRD: RNF-10 exige almacenamiento cifrado **y** ausencia del repositorio; el spec recogió sólo lo segundo.
