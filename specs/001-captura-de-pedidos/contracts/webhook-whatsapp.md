# Contrato del Canal de Mensajería (entrada y salida)

**Módulo**: `src/Api/Comunicaciones/` — **Principio III de la constitución**. Ningún slice de
`Funcionalidades/` habla con WhatsApp directamente.

## 1. Webhook de entrada

| Método | Ruta | Autorización |
|---|---|---|
| `GET` | `/api/comunicaciones/webhook` | Abierta, verificada por `hub.verify_token` |
| `POST` | `/api/comunicaciones/webhook` | Abierta, verificada por firma HMAC de la cabecera |

La ruta es abierta a la autenticación de la aplicación porque el emisor es el canal, no un
usuario, pero **no es pública sin verificación**: el `GET` responde el desafío de verificación
sólo si el token coincide con el configurado por instancia, y el `POST` rechaza con `401`
cualquier cuerpo cuya firma HMAC no valide contra el secreto de la aplicación *(R-12)*.

### Orden de procesamiento — no negociable

```
1. Validar la firma                      → 401 si no valida
2. Persistir el mensaje                  ← ANTES de cualquier interpretación (FR-034, RNF-04)
   · id_externo con índice único         → una reentrega choca y se descarta (R-07)
   · clasificacion = pendiente_de_clasificar
   · estado_de_interpretacion = pendiente
3. Vincular la conversación al cliente por teléfono (FR-035)
   · 0 clientes activos con ese número  → conversación sin vincular
   · 1 cliente                          → vinculada
   · 2 o más                            → SIN vincular; la bandeja ofrece elegir
4. Descargar la media si el tipo no es texto y guardarla en el volumen (R-11, FR-039)
5. Responder 200 al canal
6. Encolar la interpretación             ← recién ahora se toca el módulo de IA
```

Los pasos 2 a 4 van en una sola transacción. **Una caída del intérprete no puede impedir que el
paso 2 haya ocurrido** — eso es exactamente lo que verifica el escenario 7 de la Historia 3.

### Cuerpo de entrada (forma relevante)

El módulo traduce el cuerpo del canal a un `MensajeEntrante` del dominio y descarta el resto. Los
campos que consume son: identificador externo del mensaje, teléfono de origen, marca de tiempo,
tipo (`text` | `audio` | `image` | `document`), el texto cuando lo hay, y el identificador de
media cuando no.

**Respuestas**: `200` siempre que la firma valide y el mensaje se haya persistido —incluida la
reentrega duplicada, que se responde `200` sin crear nada—. `401` si la firma no valida. Nunca
`5xx` por un fallo de interpretación: eso ocurre después de responder.

---

## 2. Interfaz de salida

```csharp
namespace Caffetto.Api.Comunicaciones;

public interface ICanalDeMensajeria
{
    Task<ResultadoDeEnvio> EnviarRespuestaAsync(
        Conversacion conversacion, string texto, CancellationToken ct);

    Task<ResultadoDeEnvio> EnviarRecordatorioDeAbonoAsync(
        Conversacion conversacion, DetalleDeAbono abono, CancellationToken ct);
}

public abstract record ResultadoDeEnvio
{
    public sealed record Enviado(string IdExterno) : ResultadoDeEnvio;
    public sealed record FalloTemporal(string Motivo) : ResultadoDeEnvio;
    public sealed record FalloDefinitivo(string Motivo) : ResultadoDeEnvio;
}
```

Los slices **no llaman a esto directamente**: encolan en el outbox y el `BackgroundService` de
R-08 es quien invoca la interfaz. Así el envío sobrevive a un reinicio y el contador de errores
de la bandeja sale de la misma tabla que la cola *(FR-046, FR-046a)*.

`FalloTemporal` reintenta con retroceso exponencial hasta las 24 h; `FalloDefinitivo` (número
inválido, plantilla rechazada) marca `error_definitivo` de inmediato, sin agotar la ventana.

### Plantilla del recordatorio

El recordatorio mensual lo inicia la empresa, así que el canal exige una **plantilla aprobada**
previamente por Meta. El nombre de la plantilla y su idioma son configuración por instancia; el
detalle del abono se envía como parámetros. La aprobación es un prerrequisito externo y bloquea
el primer release *(Supuestos del spec)*.

---

## 3. Qué queda fuera del módulo

| Responsabilidad | Dónde vive |
|---|---|
| Interpretar y clasificar el mensaje | `src/Api/Ia/` *(Principio II)* |
| Decidir si un mensaje genera sugerencia | Slice `Bandeja` |
| Crear el pedido al confirmar | Slice `Pedidos` |
| Decidir a quién y cuándo recordar | Slice `Recordatorios` |

El módulo transporta y persiste. No interpreta y no decide.

---

## 4. Doble para tests

`Api.Tests/Dobles/CanalDeMensajeriaFalso` implementa `ICanalDeMensajeria` registrando los envíos
en memoria y devolviendo el `ResultadoDeEnvio` que el test le indique. Ningún test de las
historias 1 a 5 toca la red ni necesita credenciales *(Principio IV)*.
