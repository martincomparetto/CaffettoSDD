<!--
Sync Impact Report
- Versión: (plantilla sin completar) → 1.0.0
- Motivo del salto: primera ratificación. Se reemplazan todos los placeholders por
  contenido concreto y se definen los principios fundacionales del proyecto.
- Principios definidos (4, según lo indicado por el usuario; la plantilla traía 5 espacios):
  * [PRINCIPLE_1_NAME] → I. Test-First (NO NEGOCIABLE)
  * [PRINCIPLE_2_NAME] → II. La IA vive en su propio módulo
  * [PRINCIPLE_3_NAME] → III. La comunicación con el cliente vive en su propio módulo
  * [PRINCIPLE_4_NAME] → IV. Cero secretos en el repositorio
  * [PRINCIPLE_5_NAME] → eliminado (sin quinto principio solicitado)
- Secciones agregadas:
  * [SECTION_2_NAME] → Restricciones Técnicas
  * [SECTION_3_NAME] → Flujo de Trabajo y Puertas de Calidad
- Secciones eliminadas: ninguna
- Plantillas y documentos dependientes:
  * ✅ .specify/templates/plan-template.md — "Constitution Check" completado con las
    puertas derivadas de los cuatro principios
  * ✅ .specify/templates/tasks-template.md — los tests dejan de ser opcionales; se
    documenta el orden rojo-verde-refactor
  * ✅ .specify/templates/spec-template.md — revisado, alineado (sin cambios necesarios)
  * ✅ .specify/templates/checklist-template.md — revisado, alineado (sin cambios necesarios)
  * ✅ AGENTS.md / CLAUDE.md — revisados: sus convenciones no contradicen esta
    constitución (RNF-10 ya prohibía credenciales en el repo)
- TODOs diferidos: ninguno
-->

# Constitución de Caffetto

## Principios Fundamentales

### I. Test-First (NO NEGOCIABLE)

Todo cambio de comportamiento empieza por un test que falla.

- El ciclo es **rojo → verde → refactor**, en ese orden y sin atajos: se escribe el test, se
  verifica que falla por el motivo esperado, se implementa lo mínimo para que pase, y recién
  entonces se refactoriza con la suite en verde.
- PROHIBIDO escribir código de producción sin un test en rojo que lo justifique.
- PROHIBIDO cerrar una tarea o abrir un pull request con la suite en rojo o con tests
  ignorados para "destrabar".
- Todo bug se reproduce primero con un test que falla; ese test es parte de la corrección.
- La evidencia del orden debe ser visible en el historial: el commit (o los commits) del test
  precede al de la implementación, o el pull request lo explicita.
- Backend: `dotnet test` desde `src/`. Frontend: `npm run test` desde `src/Web`. Ambas suites
  deben estar en verde antes de pedir merge.

**Fundamento:** el sistema maneja plata ajena — importes facturados, cuentas corrientes,
cobranzas. Un test escrito después de la implementación documenta lo que el código hace; uno
escrito antes documenta lo que el negocio pidió. Sólo el segundo detecta que la
implementación entendió mal el requerimiento.

### II. La IA vive en su propio módulo

Toda llamada a modelos de IA vive aislada en un módulo dedicado y nunca dentro de la lógica de
negocio.

- La interpretación y clasificación de mensajes (RF-39) y el OCR de comprobantes (RF-66) se
  invocan **exclusivamente** a través de ese módulo.
- Las funcionalidades de negocio dependen de una abstracción escrita en el lenguaje del
  dominio (por ejemplo, `IInterpretadorDeMensajes`), nunca de SDKs, clientes HTTP, prompts,
  nombres de modelo ni tipos del proveedor.
- Prompts, selección de modelo, reintentos, parseo y validación de la respuesta viven dentro
  del módulo. Fuera de él no aparece ni una línea de eso.
- El negocio DEBE poder testearse sin red, contra dobles de la abstracción. El módulo tiene
  sus propios tests de contrato.
- La indisponibilidad del proveedor se absorbe en el borde del módulo y se traduce a un
  resultado del dominio; nunca puede hacer perder un mensaje ni bloquear la operación
  (RNF-04, RNF-05).

**Fundamento:** el proveedor, el modelo y los prompts van a cambiar muchas veces; las reglas
de pedidos y cobranzas, no. Mezclarlos ata el negocio a un vendor y vuelve los tests lentos,
caros y no deterministas.

### III. La comunicación con el cliente vive en su propio módulo

Toda la lógica de comunicación con el cliente vive aislada en un módulo dedicado y nunca
dentro de la lógica de negocio.

- Alcance: WhatsApp Cloud API (RF-34 a RF-49) y el correo electrónico saliente y entrante
  (RF-65, RF-75, RF-76). Todo canal futuro entra por el mismo lugar.
- El negocio expresa una **intención del dominio** ("enviar el recordatorio de abono", "enviar
  el comprobante") contra una abstracción. No arma payloads, no conoce webhooks, plantillas,
  tokens, formatos de adjunto ni códigos de error del transporte.
- Plantillas, redacción de los mensajes, reintentos y encolado (RNF-05) viven en el módulo.
- El módulo es también el punto de entrada de lo que llega: persiste el mensaje entrante antes
  de cualquier interpretación (RNF-04) y recién después lo entrega al negocio.
- El negocio DEBE poder testearse sin red, contra dobles de la abstracción. El módulo tiene
  sus propios tests de contrato.

**Fundamento:** el canal es un detalle de infraestructura que cambia por decisión de Meta o
del proveedor de correo. Además, el sistema nunca responde ni registra por sí solo (RF-40):
tener un único lugar por donde sale todo mensaje es lo que hace verificable esa promesa.

### IV. Cero secretos en el repositorio

Ninguna credencial se escribe en el código.

- Alcance: certificados y claves de ARCA, tokens de WhatsApp, credenciales de la casilla de
  correo, cadenas de conexión, claves de proveedores de IA, claves de firma de sesión.
- PROHIBIDO en cualquier archivo versionado: código, `appsettings.json`, `docker-compose.yml`,
  tests, fixtures, seeds, documentación y mensajes de commit.
- Las credenciales entran **sólo** por variables de entorno y configuración por instancia
  (RNF-10, RNF-11). El `.env` real queda fuera de git; `.env.example` lista las claves con
  valores de ejemplo, nunca reales.
- La configuración por instancia se valida al arrancar: una instancia mal configurada falla de
  entrada, no al emitir la primera factura.
- Las credenciales no se exponen por la API ni por los logs. Las clases que las representan
  redactan su `ToString()` y no se imprimen campo por campo.
- Un secreto commiteado se considera comprometido: se **rota**. Borrar el commit no alcanza.

**Fundamento:** RNF-10 lo exige, pero además cada instancia es de una empresa distinta con sus
propios datos fiscales: una credencial filtrada permite emitir comprobantes a nombre de un
tercero.

## Restricciones Técnicas

- **Stack:** .NET 10 / C# 14 en el backend, React + Vite (Node 22) en el frontend, PostgreSQL
  17 como base, Docker Compose para el despliegue. Una instancia y una base independientes por
  empresa.
- **Vertical slice:** cada caso de uso vive en su carpeta bajo `src/Api/Funcionalidades/<Área>/`
  con su endpoint, su manejador y sus tipos juntos. Sin MediatR ni repositorios genéricos;
  EF Core se usa directo. Los módulos de los principios II y III son la excepción deliberada:
  son módulos transversales, no slices.
- **Nombres del dominio en español**, como el PRD.
- **Datos económicos:** toda entidad con datos económicos implementa `IAuditable` y genera su
  clave en memoria (`Guid.CreateVersion7()`). La auditoría la escribe el interceptor; ninguna
  funcionalidad agrega filas a `auditoria` a mano (RNF-08).
- **No destructividad:** clientes, ventas, comprobantes, cobranzas y auditoría no se borran
  físicamente. Sólo baja lógica, anulación o ajuste con motivo (RNF-09, RF-04).
- **Autorización explícita:** todo endpoint declara `RequireAuthorization(Politicas.X)`. Sólo
  `/api/health` queda abierto.
- `AGENTS.md` desarrolla estas convenciones en detalle y es de lectura obligatoria. Ante una
  contradicción, manda esta constitución.

## Flujo de Trabajo y Puertas de Calidad

- **Una rama por unidad de trabajo, creada ANTES de tocar nada**, con formato
  `tipo/descripcion-corta`. Nunca se modifica el repositorio estando en `main`.
- **Puerta de diseño:** el `Constitution Check` del plan se evalúa antes de la fase de
  investigación y se vuelve a evaluar después del diseño. Una violación se resuelve
  cambiando el diseño; si de verdad no hay alternativa, se justifica en
  `Complexity Tracking` con la alternativa más simple que se descartó y por qué.
- **Puerta de implementación:** las tareas de test de una historia se escriben y se ven fallar
  antes de las tareas de implementación de esa misma historia (Principio I).
- **Puerta de merge:** ambas suites en verde, sin secretos agregados, sin llamadas a IA ni a
  canales de comunicación fuera de sus módulos.
- Pushear y mergear son cosas distintas: `/push` sube la rama actual y nada más.

## Gobernanza

Esta constitución prevalece sobre cualquier otra práctica, convención o preferencia. Ante un
conflicto con `AGENTS.md`, con una plantilla de Spec Kit o con un plan ya aprobado, gana la
constitución y se corrige el otro artefacto.

**Enmiendas.** Toda enmienda se hace sobre este archivo, en su propia rama, y debe indicar:
qué principio cambia, por qué, y qué artefactos dependientes se actualizan en el mismo cambio.
No se enmienda la constitución para desbloquear una tarea en curso: primero se entrega la
tarea cumpliendo el principio, o se detiene la tarea.

**Versionado semántico.**

- **MAJOR:** se elimina o se redefine un principio de forma incompatible con lo anterior.
- **MINOR:** se agrega un principio o una sección, o se amplía materialmente una guía.
- **PATCH:** aclaraciones, redacción, correcciones que no cambian el significado.

**Cumplimiento.** Todo pull request verifica el cumplimiento de los cuatro principios. Las
revisiones automáticas (`/speckit-analyze`, `/speckit-converge`) tratan las violaciones de
constitución como CRÍTICAS: se corrige el artefacto en falta, nunca se reinterpreta el
principio. La complejidad se justifica o se elimina.

**Version**: 1.0.0 | **Ratified**: 2026-07-29 | **Last Amended**: 2026-07-29
