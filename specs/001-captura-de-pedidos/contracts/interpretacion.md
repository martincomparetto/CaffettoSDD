# Contrato del Módulo de IA

**Módulo**: `src/Api/Ia/` — **Principio II de la constitución**. Es el único lugar del sistema que
llama a un modelo. Ningún slice de `Funcionalidades/` referencia el paquete `Anthropic`, ni ve un
prompt, ni conoce el nombre del modelo.

## Interfaz que consume el negocio

```csharp
namespace Caffetto.Api.Ia;

public interface IInterpretadorDeMensajes
{
    Task<InterpretacionDeMensaje> InterpretarAsync(
        TextoAInterpretar texto,
        CatalogoParaInterpretar catalogo,
        CancellationToken ct);
}

/// Texto plano del mensaje entrante. El módulo no conoce la entidad Mensaje.
public sealed record TextoAInterpretar(string Contenido);

/// Artículos activos con su nombre y unidad, para que el intérprete
/// proponga cantidades sobre artículos que existen.
public sealed record CatalogoParaInterpretar(IReadOnlyList<ArticuloParaInterpretar> Articulos);

public sealed record ArticuloParaInterpretar(Guid Id, string Nombre, UnidadDeMedida Unidad);
```

## Tipo de resultado

```csharp
public abstract record InterpretacionDeMensaje
{
    /// El mensaje pide productos. Lineas puede venir vacía si se entendió
    /// que es un pedido pero no qué artículos.
    public sealed record EsPedido(IReadOnlyList<LineaSugerida> Lineas) : InterpretacionDeMensaje;

    /// El mensaje informa un pago. En Fase 1 sólo se clasifica; las cobranzas son Fase 3.
    public sealed record EsComprobanteDePago : InterpretacionDeMensaje;

    /// Pregunta o mensaje social. NO entra en la cola de pendientes (FR-045).
    public sealed record EsConsulta : InterpretacionDeMensaje;

    /// Ninguna de las anteriores. Tampoco entra en la cola (FR-045).
    public sealed record EsOtro : InterpretacionDeMensaje;

    /// El intérprete no pudo decidir, o el servicio no respondió.
    /// El mensaje queda pendiente de clasificar y visible en la bandeja (AC-79, FR-046a).
    public sealed record NoSePudoInterpretar(string Motivo) : InterpretacionDeMensaje;
}

public sealed record LineaSugerida(Guid ArticuloId, decimal Cantidad);
```

`NoSePudoInterpretar` **no es una excepción**: es un resultado del dominio. El módulo absorbe en
su borde toda falla del proveedor —timeout, 429, 5xx, respuesta que no valida contra el esquema— y
la traduce a este caso *(Principio II, RNF-05)*. El slice de la bandeja nunca ve un error HTTP.

## Cómo se implementa dentro del módulo

Sólo `InterpretadorClaude` conoce estos detalles:

- **Modelo**: `claude-opus-5` *(R-02)*. Es una constante del módulo; cambiarla no toca ningún slice.
- **Salida estructurada**: `OutputConfig.Format` con un `JsonOutputFormat` cuyo esquema refleja
  exactamente los casos de `InterpretacionDeMensaje`. La respuesta se valida contra el esquema
  antes de mapearse; si no valida, es `NoSePudoInterpretar`.
- **Prompt**: en `Ia/Prompts/`, versionado con el código. El catálogo entra como contexto para que
  las líneas sugeridas referencien artículos existentes.
- **Credencial**: `ANTHROPIC_API_KEY` desde el entorno, enlazada y validada al arrancar *(R-12)*.
  Nunca en el repositorio ni en `appsettings.json`.
- **Reintentos**: los del SDK, acotados. Agotados, devuelve `NoSePudoInterpretar`.

## Reglas que el negocio aplica sobre el resultado

Estas viven en el slice `Bandeja`, no en el módulo:

| Resultado | Clasificación del mensaje | ¿Genera sugerencia? | ¿Entra en la cola? |
|---|---|---|---|
| `EsPedido` | `pedido` | sí | sí — se resuelve confirmando o descartando la sugerencia *(FR-041)* |
| `EsComprobanteDePago` | `pago` | no en Fase 1 | sí — se resuelve marcándolo como resuelto *(FR-041c)* |
| `EsConsulta` | `consulta` | no | no *(FR-045)* |
| `EsOtro` | `otro` | no | no *(FR-045)* |
| `NoSePudoInterpretar` | `pendiente_de_clasificar` | no | sí — se resuelve reclasificándolo o marcándolo como resuelto *(FR-041b, FR-041c)* |

Una clasificación corregida a mano por un usuario **no vuelve a interpretarse**: el mensaje queda
marcado como clasificado a mano y el worker lo saltea *(FR-041b)*.

Los mensajes que no son de texto ni llegan al intérprete: el webhook los deja en
`pendiente_de_clasificar` directamente *(FR-039)*.

## Doble para tests

`Api.Tests/Dobles/InterpretadorFalso` implementa `IInterpretadorDeMensajes` devolviendo el
`InterpretacionDeMensaje` que el test configure, incluido `NoSePudoInterpretar` para el escenario
del intérprete caído. **Ningún test del negocio llama al modelo real**: son deterministas,
gratuitos y corren sin red *(Principio I y Principio II)*.

El módulo tiene además sus propios tests de contrato, que verifican el mapeo de la respuesta del
proveedor a `InterpretacionDeMensaje` contra respuestas grabadas — incluidas las malformadas.
