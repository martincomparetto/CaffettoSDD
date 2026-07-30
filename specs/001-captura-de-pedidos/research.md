# Fase 0 — Investigación y Decisiones Técnicas

**Funcionalidad**: Fase 1 — Fuente de verdad única y captura de pedidos
**Fecha**: 2026-07-29

Cada decisión resuelve una incógnita del Contexto Técnico o un hueco que los checklists de
calidad marcaron sobre el spec. Ninguna queda como NEEDS CLARIFICATION.

---

## R-01 — Autenticación y sesión

**Decisión**: cookie de sesión de ASP.NET Core con `PasswordHasher<T>` de Identity para el
hashing (PBKDF2, parámetros por defecto del framework). Cookie `HttpOnly`, `SameSite=Strict`,
`Secure`; expiración deslizante de 8 horas con vencimiento absoluto de 12. La sesión se invalida
al dar de baja al usuario o cambiarle el rol mediante un `SecurityStamp` revalidado en cada
petición.

**Fundamento**: el front y la API comparten origen (Vite en desarrollo, nginx en producción), así
que no hay CORS ni necesidad de un bearer token en `localStorage` — la cookie es más segura y más
simple. La expiración de 8 horas cubre una jornada sin obligar a reingresar a media mañana, que
es exactamente la fricción que haría al equipo desconfiar del sistema. El `SecurityStamp` cierra
el hueco que marcó `seguridad.md` CHK013: la sesión abierta de un usuario dado de baja.

**Alternativas consideradas**: JWT en cabecera (agrega revocación manual y almacenamiento en el
cliente sin ganar nada al ser mismo origen); Identity completo con sus tablas y endpoints (trae
confirmación de e-mail, 2FA y recuperación por correo que el PRD no pide en Fase 1).

---

## R-02 — Modelo de IA para la interpretación de mensajes

**Decisión**: `claude-opus-5` a través del SDK oficial `Anthropic` de NuGet, invocado
exclusivamente desde `src/Api/Ia/InterpretadorClaude.cs`. Se usa **structured output**
(`OutputConfig.Format` con un `JsonOutputFormat`) para que la clasificación vuelva como JSON
validado contra un esquema, no como texto a parsear. Adaptive thinking queda en su valor por
defecto.

**Fundamento**: la salida estructurada elimina la clase entera de fallos de parseo que un
clasificador basado en texto libre arrastra, y el esquema es el contrato del módulo. La elección
del modelo está aislada por el Principio II: cambiarlo es editar una constante dentro de `Ia/`,
sin tocar un solo slice. Se elige el modelo más capaz porque una clasificación errónea cuesta un
pedido perdido — el riesgo central del PRD — y el volumen es bajo: ~150 clientes generan cientos
de mensajes al mes, no millones.

**Alternativas consideradas**: un modelo más económico para clasificar (baja el costo pero sube
la tasa de sugerencias erróneas justo donde el negocio menos lo tolera; queda disponible como
ajuste posterior de una línea si el costo real lo justifica); reglas y expresiones regulares
sobre el texto (frágil ante cómo escribe realmente la gente por WhatsApp, y sin salida para el
caso ambiguo).

---

## R-03 — Zona horaria

**Decisión**: `America/Argentina/Buenos_Aires` como zona horaria de negocio, fija por instancia y
configurable por variable de entorno. Todo instante se persiste en UTC (`timestamptz`) y se
convierte a la zona de negocio para resolver el día de aviso *(FR-047)*, el último día del mes
*(FR-048)* y el corte del período del tablero *(FR-026)*. El acceso al reloj va por
`TimeProvider`, nunca por `DateTime.Now`.

**Fundamento**: sin esto, «el día 5» y «el último día del mes» son ambiguos, que es el hueco que
`captura.md` CHK013 marcó como uno de los tres riesgos silenciosos para la promesa O1. Argentina
no aplica horario de verano desde 2009, así que la conversión es estable. `TimeProvider` es lo
que hace testeable el recordatorio: el test adelanta el reloj en vez de esperar al día 5.

**Alternativas consideradas**: UTC puro (el aviso del día 5 saldría a las 21:00 del día 4 en
verano boreal — inaceptable para el cliente); zona por cliente (el PRD tiene una sola empresa por
instancia y todos sus clientes son locales).

---

## R-04 — Precisión decimal y redondeo

**Decisión**: `decimal` en C# y `numeric` en PostgreSQL. Costos, precios unitarios, importes y
porcentajes de utilidad en `numeric(18,2)`; cantidades en `numeric(18,3)`. El redondeo es al
centavo con `MidpointRounding.AwayFromZero`. Se centraliza en un tipo `Dinero` y un tipo
`Cantidad` para que la regla no se reimplemente en cada slice.

**Fundamento**: implementa FR-016a literalmente. `decimal`/`numeric` evitan el error binario de
punto flotante, que en importes facturables no es negociable. Centralizar el redondeo es lo que
hace verificable SC-016 con un test, en lugar de auditar cada multiplicación.

**Alternativas consideradas**: enteros en centavos (evita todo redondeo pero complica las
cantidades por kilogramo con 3 decimales y ensucia cada lectura); `double` (descartado de entrada
por el error de representación).

---

## R-05 — Concurrencia optimista

**Decisión**: el `xmin` de PostgreSQL como token de concurrencia de EF Core
(`UseXminAsConcurrencyToken`) en todas las entidades editables. Un `DbUpdateConcurrencyException`
se traduce a **409 Conflict** con un cuerpo que indica que el registro cambió. La resolución de
una sugerencia usa un `UPDATE ... WHERE estado = 'pendiente'` condicional y devuelve 409 si
afectó cero filas.

**Fundamento**: implementa FR-055a y FR-041a sin agregar una columna de versión a cada tabla —
`xmin` ya existe en PostgreSQL. El chequeo condicional sobre el estado de la sugerencia es lo que
impide el pedido duplicado de la doble confirmación, y es atómico sin bloquear a nadie.

**Alternativas consideradas**: bloqueo pesimista con `SELECT FOR UPDATE` (traba al segundo
usuario, que es justo lo que la aclaración del 2026-07-29 descartó); columna `rowversion`
explícita (funciona, pero es ruido en cada entidad cuando el motor ya lo resuelve).

---

## R-06 — Auditoría automática

**Decisión**: un `SaveChangesInterceptor` de EF Core recorre el `ChangeTracker`, y por cada
entidad `IAuditable` añadida, modificada o dada de baja escribe una fila en `auditoria` con
usuario, fecha, acción, entidad, clave y valores anteriores serializados. Las propiedades
marcadas con `[NoAuditar]` se excluyen. El asiento se escribe **dentro del mismo `SaveChanges`**
que el cambio, lo que exige que la clave exista antes de guardar — de ahí
`Guid.CreateVersion7()` en memoria.

**Fundamento**: es lo que `AGENTS.md` ya manda, y es la única forma de garantizar SC-008 al 100%:
si la auditoría dependiera de que cada slice se acuerde de escribirla, el primer slice que se
olvide rompe el criterio. Un guardado rechazado por conflicto de concurrencia no deja asiento,
porque la transacción entera se revierte — que es el comportamiento correcto.

**Alternativas consideradas**: triggers en PostgreSQL (invisibles desde el código y difíciles de
testear con el usuario de aplicación); auditoría explícita por slice (viola la constitución).

---

## R-07 — Persistencia previa a la interpretación y deduplicación

**Decisión**: el webhook de WhatsApp persiste el mensaje y responde 200 **antes** de invocar la
IA. La interpretación corre después, en un `BackgroundService` que consume una cola en base. El
identificador externo del mensaje lleva un índice único: una reentrega del mismo mensaje choca
contra el índice y se descarta sin crear un duplicado.

**Fundamento**: RNF-04 exige que el 100% de los mensajes se persista antes de interpretarlos, y
FR-034 lo repite. Responder 200 rápido evita que Meta reintente por timeout. El índice único
resuelve el hueco de `captura.md` CHK005 y el diferido que había quedado de `/speckit-clarify`.

**Alternativas consideradas**: interpretar en la misma petición del webhook (una caída del modelo
haría fallar el webhook y Meta reintentaría, multiplicando mensajes); cola externa tipo Redis
(infraestructura extra para un volumen que PostgreSQL absorbe sin esfuerzo).

---

## R-08 — Cola de salida y reintentos de 24 h

**Decisión**: patrón outbox en la tabla `mensajes_salientes`, con estado, intentos, próximo
intento y motivo del último error. Un `BackgroundService` reintenta con retroceso exponencial
hasta cumplir 24 h desde el primer intento fallido, y después marca `error_definitivo`. La
bandeja lee esa tabla para el contador de FR-046a y ofrece el reintento manual.

**Fundamento**: implementa FR-046 y FR-046a con la misma tabla, así que el contador que ve el
usuario y la cola que reintenta no pueden desincronizarse. El outbox también hace que el envío
no se pierda si la aplicación se cae entre el `SaveChanges` del negocio y la llamada al canal.

**Alternativas consideradas**: reintentar en memoria con Polly (se pierde todo al reiniciar el
contenedor, y no hay forma de mostrar el contador de fallos); un job scheduler externo
(infraestructura extra para una necesidad que un `BackgroundService` cubre).

---

## R-09 — Programación del recordatorio mensual

**Decisión**: un `BackgroundService` despierta cada hora, calcula la fecha en la zona de negocio
*(R-03)* y busca los abonos vigentes cuyo día de aviso sea hoy —o cuyo día no exista en el mes y
hoy sea el último— sin recordatorio registrado para ese mes. La tabla `recordatorios_de_abono`
tiene un índice único por `(abono, año, mes)`: eso hace la operación idempotente aunque el
servicio se ejecute dos veces o el contenedor reinicie.

**Fundamento**: implementa FR-047, FR-048 y FR-050. La idempotencia por índice único es lo que
impide el peor resultado posible — mandarle el recordatorio dos veces al mismo cliente, que el
PRD identifica como riesgo de percepción de spam. Despertar cada hora, en vez de cada minuto,
alcanza de sobra para una granularidad diaria.

**Alternativas consideradas**: Hangfire o Quartz (dependencia y tablas propias para un único job
periódico); cron del sistema operativo llamando a un endpoint (mueve lógica de negocio al
orquestador y viola RNF-11, que exige que la diferencia entre instancias sea sólo configuración).

---

## R-10 — Listas de precios y artículos nuevos

**Decisión**: la lista de precios se materializa con una fila por artículo
(`articulo_en_lista_de_precios`), y el alta de un artículo inserta su fila en todas las listas
existentes con la utilidad por defecto, dentro de la misma transacción del alta. El precio de
venta se calcula al leer; no se persiste, salvo congelado en la línea de venta.

**Fundamento**: implementa FR-015a manteniendo la invariante de FR-015 —ninguna lista queda sin
precio para un artículo activo— de forma verificable con una consulta. Calcular el precio al leer
evita el problema de mantener sincronizados costo y precio ante cada actualización masiva.

**Alternativas consideradas**: resolver la utilidad por defecto al vuelo cuando falta la fila
(hace imposible detectar por consulta si una lista está incompleta, y esconde el estado); guardar
el precio calculado (obliga a recalcular todas las listas en cada actualización masiva de costos).

---

## R-11 — Almacenamiento de la media de WhatsApp

**Decisión**: audios, imágenes y documentos se descargan del canal y se guardan en un volumen
montado en el contenedor, bajo una ruta derivada del identificador del mensaje. La base guarda
la ruta, el tipo MIME y el tamaño. La retención es indefinida, igual que el resto del historial.

**Fundamento**: FR-039 obliga a persistir estos mensajes aunque no se interpreten, y el enlace
temporal que devuelve el canal caduca — si no se descarga, el comprobante desaparece. Un volumen
mantiene la base liviana y el respaldo simple; el volumen entra en el mismo procedimiento de
respaldo que cubre SC-013.

**Alternativas consideradas**: `bytea` en PostgreSQL (infla la base y encarece cada respaldo);
almacenamiento de objetos tipo S3 (dependencia externa que RNF-11 no contempla para una
instancia autocontenida).

---

## R-12 — Configuración por instancia y credenciales

**Decisión**: toda la configuración entra por variables de entorno, enlazada a tipos de opciones
en `src/Api/Arranque/` y validada con `ValidateOnStart()`. Una instancia con configuración
faltante o inválida **no arranca**. Las credenciales de servicios externos (canal de mensajería,
casilla de correo) viven sólo en el entorno del proceso: no se persisten en la base, no se
exponen por ningún endpoint y sus tipos redactan `ToString()`.

**Fundamento**: implementa FR-057, FR-058 y SC-015, y resuelve el hueco que `seguridad.md` CHK006
marcó contra RNF-10. RNF-10 pide credenciales cifradas y fuera del repositorio; al no persistirlas
en la base, el requisito de cifrado en reposo se traslada al gestor de secretos del anfitrión,
que es donde corresponde. Fallar al arrancar es lo que impide descubrir la credencial faltante
recién al intentar el primer envío.

**Alternativas consideradas**: credenciales cifradas en la base con Data Protection (agrega una
clave maestra que a su vez hay que custodiar, sin ganar nada mientras la configuración sea por
instancia); `appsettings.json` por entorno (`AGENTS.md` lo prohíbe explícitamente).

---

## R-13 — Frontend: datos, rutas y objetivo móvil

**Decisión**: React 19 con TanStack Query para el estado del servidor y React Router para las
rutas. Un cliente HTTP común traduce 401 a redirección al ingreso y 403 a un mensaje de permisos
—la distinción que exige FR-053—. Las pantallas se diseñan primero a 360 px. Vitest y Testing
Library para los tests, con MSW simulando la API.

**Fundamento**: TanStack Query resuelve caché, revalidación y estados de carga y error sin
inventar un store, que es lo que hace alcanzable el objetivo de 3 s percibidos. Centralizar el
manejo de 401 y 403 en el cliente HTTP es lo que hace que FR-053 se cumpla en todas las pantallas
y no sólo en las que alguien se acordó.

**Alternativas consideradas**: Redux Toolkit Query (más ceremonia de la que este tamaño justifica);
`fetch` a mano con `useEffect` (reimplementa caché y estados de error en cada pantalla, y es donde
se filtran los bugs de carga).

---

## Huecos del spec que estas decisiones cierran

| Hueco marcado en los checklists | Decisión |
|---|---|
| `captura.md` CHK005 — mensajes duplicados reentregados | R-07 |
| `captura.md` CHK013 — zona horaria sin definir | R-03 |
| `captura.md` CHK009 — almacenamiento y retención de la media | R-11 |
| `seguridad.md` CHK001 — duración de la sesión | R-01 |
| `seguridad.md` CHK006 — cifrado de credenciales frente a RNF-10 | R-12 |
| `seguridad.md` CHK007 — fallar al arrancar con configuración inválida | R-12 |
| `seguridad.md` CHK013 — sesión abierta de un usuario dado de baja | R-01 |
| `integridad-economica.md` CHK031 — actualización masiva concurrente | R-05 |
| Diferido de `/speckit-clarify` — límites de tasa del canal | R-08 (la cola serializa y reintenta) |

Los huecos de `integridad-economica.md` CHK002 y CHK003 —qué pasa con la venta cuando se corrige
una entrega ya confirmada— **siguen abiertos**: son una decisión de requerimiento, no técnica, y
no se resuelven en el plan. Ver la nota al cierre de `data-model.md`.
