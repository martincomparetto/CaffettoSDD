# Plan de Implementación: Fase 1 — Fuente de verdad única y captura de pedidos

**Rama**: `feat/captura-de-pedidos` | **Fecha**: 2026-07-29 | **Spec**: [spec.md](./spec.md)

**Entrada**: especificación en `specs/001-captura-de-pedidos/spec.md`

## Resumen

Fase 1 reemplaza el Excel por una fuente de verdad única: catálogo con listas de precios
calculadas, pedidos precargados desde el abono, entregas que congelan precio y costo al generar
la venta, una bandeja de WhatsApp que persiste todo antes de interpretarlo, y el recordatorio
mensual del abono. 66 requerimientos funcionales, 17 criterios de éxito.

El enfoque técnico es una API .NET 10 con vertical slices sobre EF Core y PostgreSQL 17, servida
bajo `/api`, y una SPA React + Vite mobile-first. Dos módulos transversales aíslan lo que la
constitución exige aislar: `src/Api/Ia/` para la interpretación de mensajes y
`src/Api/Comunicaciones/` para el canal de WhatsApp. Todo lo demás es un slice por caso de uso.

## Contexto Técnico

**Lenguaje/Versión**: C# 14 sobre .NET 10 (backend); TypeScript sobre React 19 + Vite, Node 22 (frontend)

**Dependencias principales**: ASP.NET Core Minimal APIs, EF Core 10 + Npgsql, ASP.NET Core Identity (hashing y cookie de sesión), SDK oficial `Anthropic` de NuGet, TanStack Query, xUnit + Testcontainers, Vitest + Testing Library

**Almacenamiento**: PostgreSQL 17, una base por empresa. Media de WhatsApp (audio, imagen, documentos) en un volumen del contenedor, con la ruta en la base

**Testing**: `dotnet test` desde `src/` (xUnit + Testcontainers, requiere Docker); `npm run test` desde `src/Web` (Vitest)

**Plataforma objetivo**: contenedores Linux orquestados con Docker Compose; una instancia y una base independientes por empresa

**Tipo de proyecto**: aplicación web — backend `src/Api`, frontend `src/Web`

**Objetivos de rendimiento**: pantallas de operación diaria bajo 3 s en el percentil 95 con 150 clientes, 150 pedidos mensuales y 3 años de historia *(SC-005)*

**Restricciones**: operable en 360 px sin scroll horizontal; registrar un pedido en menos de 30 s; confirmar una sugerencia en 1 toque; RPO y RTO de 1 hora; 0 credenciales en el repositorio *(SC-003, SC-011, SC-013, SC-015)*

**Escala/Alcance**: 4 usuarios concurrentes, ~150 clientes, ~150 pedidos mensuales, 5 historias de usuario, 66 requerimientos funcionales

## Constitution Check

*Fuente: `.specify/memory/constitution.md` v1.0.0. Evaluado antes de la Fase 0 y revalidado
después de la Fase 1 (ver **Revalidación** más abajo).*

- [x] **I. Test-First**: el desglose por historia ordena los tests antes de la implementación, y
      cada criterio de aceptación del spec tiene su prueba antes de que exista el endpoint.
      Testcontainers levanta PostgreSQL real, así que la prueba en rojo es genuina y no un doble
      del ORM. `quickstart.md` documenta el ciclo rojo-verde-refactor por historia.
- [x] **II. IA aislada**: toda llamada al modelo vive en `src/Api/Ia/`. Los slices dependen de
      `IInterpretadorDeMensajes`, que devuelve tipos del dominio (`InterpretacionDeMensaje`).
      Ningún slice referencia el paquete `Anthropic`, ni prompts, ni nombres de modelo. El
      contrato del módulo está en `contracts/interpretacion.md`.
- [x] **III. Comunicación aislada**: WhatsApp entra y sale sólo por `src/Api/Comunicaciones/`.
      Los slices expresan intención (`EnviarRecordatorioDeAbono`, `ResponderConversacion`) contra
      `ICanalDeMensajeria`. El webhook entrante persiste el mensaje antes de tocar la IA
      *(FR-034)* y recién después encola la interpretación.
- [x] **IV. Cero secretos**: todas las credenciales entran por variables de entorno enlazadas en
      `src/Api/Arranque/`, validadas al arrancar. `.env` fuera de git, `.env.example` sin valores
      reales. Los tests usan Testcontainers y dobles del canal: no necesitan credenciales.
- [x] **Restricciones técnicas**: un slice por caso de uso bajo `src/Api/Funcionalidades/<Área>/`,
      nombres del dominio en español, `IAuditable` + `Guid.CreateVersion7()` en toda entidad
      económica, cero borrado físico, y `RequireAuthorization(Politicas.X)` en todos los
      endpoints salvo `/api/health`.

**Excepción declarada por la propia constitución**: `Ia/` y `Comunicaciones/` no son vertical
slices sino módulos transversales. La sección «Restricciones Técnicas» de la constitución los
contempla explícitamente, así que no constituyen una violación y no entran en Complexity Tracking.

## Estructura del Proyecto

### Documentación de esta funcionalidad

```text
specs/001-captura-de-pedidos/
├── spec.md              # Especificación (ya existente)
├── plan.md              # Este archivo
├── research.md          # Fase 0: decisiones técnicas resueltas
├── data-model.md        # Fase 1: entidades, relaciones, transiciones
├── quickstart.md        # Fase 1: guía de validación ejecutable
├── contracts/           # Fase 1: contratos de interfaz
│   ├── api.md               # Endpoints HTTP bajo /api
│   ├── webhook-whatsapp.md  # Contrato de entrada del canal
│   └── interpretacion.md    # Contrato del módulo de IA
├── checklists/          # Checklists de calidad de requerimientos
└── tasks.md             # Fase 2: lo genera /speckit-tasks, no este comando
```

### Código fuente (raíz del repositorio)

```text
src/
├── Directory.Packages.props        # Versiones NuGet centralizadas
├── Caffetto.sln
├── Api/
│   ├── Arranque/                   # Configuración por instancia, validación al arrancar
│   ├── Autenticacion/              # Politicas.cs, cookie de sesión, 401 vs 403
│   ├── Datos/                      # CaffettoDbContext, InterceptorDeAuditoria, migraciones
│   ├── Ia/                         # PRINCIPIO II — único lugar que llama al modelo
│   │   ├── IInterpretadorDeMensajes.cs
│   │   ├── InterpretadorClaude.cs
│   │   ├── Prompts/
│   │   └── Modelo/                 # InterpretacionDeMensaje y tipos de resultado
│   ├── Comunicaciones/             # PRINCIPIO III — único lugar que habla con WhatsApp
│   │   ├── ICanalDeMensajeria.cs
│   │   ├── CanalWhatsApp.cs
│   │   ├── Entrante/               # Webhook, persistencia previa, deduplicación
│   │   └── Saliente/               # Cola, reintentos 24 h, plantillas
│   ├── Funcionalidades/            # Un slice por caso de uso
│   │   ├── Articulos/
│   │   ├── Costos/
│   │   ├── ListasDePrecios/
│   │   ├── Clientes/
│   │   ├── Abonos/
│   │   ├── Pedidos/
│   │   ├── Entregas/
│   │   ├── Ventas/
│   │   ├── Bandeja/
│   │   ├── Recordatorios/
│   │   ├── Usuarios/
│   │   └── Auditoria/
│   └── Api.csproj
├── Api.Tests/
│   ├── Integracion/                # Testcontainers: PostgreSQL real por colección de tests
│   ├── Dobles/                     # Dobles de IInterpretadorDeMensajes e ICanalDeMensajeria
│   └── Api.Tests.csproj
└── Web/
    ├── src/
    │   ├── funcionalidades/        # Espeja los slices del backend
    │   ├── comun/                  # Cliente HTTP, formato de moneda, manejo de 401/403
    │   └── main.tsx
    ├── vite.config.ts              # Proxy /api → localhost:8080 en desarrollo
    └── package.json
docker-compose.yml
.env.example
```

**Decisión de estructura**: aplicación web con backend y frontend separados, según manda
`AGENTS.md`. Dentro de `src/Api/`, los casos de uso son vertical slices y los dos módulos que la
constitución exige aislar viven fuera de `Funcionalidades/` para que la dependencia sea imposible
de invertir por accidente: un slice puede referenciar `Ia/` y `Comunicaciones/`, nunca al revés.

## Revalidación del Constitution Check (post-diseño)

Después de producir `research.md`, `data-model.md`, `contracts/` y `quickstart.md`, los cinco
controles siguen en verde y el diseño no introdujo violaciones:

- El contrato de `IInterpretadorDeMensajes` devuelve `InterpretacionDeMensaje`, un tipo del
  dominio en español, sin nada del SDK. El slice de la bandeja nunca ve un `MessageCreateParams`.
- El contrato del webhook deja explícito el orden: persistir, deduplicar, responder 200 y recién
  después encolar la interpretación. RNF-04 queda satisfecho por construcción.
- Ningún endpoint del contrato queda sin política declarada; `/api/health` es el único abierto.
- Las entidades económicas de `data-model.md` implementan `IAuditable` y generan su clave con
  `Guid.CreateVersion7()`; ninguna admite borrado físico.
- Las decisiones R-01 y R-12 de `research.md` mantienen toda credencial fuera del repositorio y
  hacen fallar el arranque si falta alguna.

## Complexity Tracking

Sin violaciones que justificar. La única desviación del patrón vertical slice —los módulos
`Ia/` y `Comunicaciones/`— está prevista y autorizada por la propia constitución.
