# AGENTS.md — Caffetto

## Propósito

Sistema de gestión de pedidos, facturación y cobranzas para una empresa de café de especialidad.
Reemplaza el Excel por una fuente de verdad única: captura pedidos y pagos desde WhatsApp, factura contra ARCA y lleva la cuenta corriente de cada cliente.

## Stack

- **Backend:** .NET 10 / C# 14
- **Frontend:** React + Vite (Node 22)
- **Base de datos:** PostgreSQL 17
- **Infra:** Docker Compose — una instancia y una DB independientes por empresa
- **Layout:** solución .NET en `src/Api`, frontend React en `src/Web`

## Cómo correr

- **Configurar la instancia** (una vez): `cp .env.example .env` y completar los valores. Sin `.env` no levanta.
- **Instalar** (deps del frontend, necesarias para sus tests): `npm install` dentro de `src/Web`
- **Levantar** todo (backend + frontend + DB): `docker compose up --build`. La API queda en `localhost:8080` y la app en `localhost:5173`.
- **Tests backend:** `dotnet test` (desde `src/`). Usan Testcontainers, así que necesitan el demonio de Docker corriendo.
- **Tests frontend:** `npm run test` dentro de `src/Web`

## Cómo trabajar

- **Una rama por unidad de trabajo, creada ANTES de tocar nada.** Un bloque o una funcionalidad entera van juntos en una rama; un ajuste sobre lo que se está haciendo continúa en la rama ya abierta, no abre una nueva. Formato del nombre: `tipo/descripcion-corta`, con los mismos tipos que usa `.claude/skills/conventional-commit/SKILL.md` — por ejemplo `feat/usuarios-y-roles` o `fix/cuit-invalido`.
- **Nunca modificar el repositorio estando en `main`.** El hook `.claude/hooks/exigir-rama.sh` lo impide: si frena, la respuesta correcta es crear la rama y repetir la edición, nunca buscar la forma de saltearlo.
- **`.claude/permitir-main` desactiva ese bloqueo, y es del usuario.** El agente no debe crearlo nunca por su cuenta.
- **Pushear y mergear son cosas distintas.** `/push` sube la rama actual y nada más; el merge se pide aparte o se resuelve por pull request.

## Convenciones

- **Vertical slice.** Cada caso de uso vive en su propia carpeta bajo `src/Api/Funcionalidades/<Área>/`, con su endpoint, su manejador y sus tipos juntos. Sin MediatR ni repositorios genéricos: EF Core se usa directo.
- **Nombres del dominio en español**, como el PRD. Las convenciones técnicas de cada plataforma se respetan igual.
- **La API se sirve bajo `/api`.** El front siempre le pega al mismo origen: Vite hace proxy en desarrollo y nginx en producción, así que no hay CORS en ningún entorno.
- **Versiones de paquetes NuGet centralizadas** en `src/Directory.Packages.props`; los `.csproj` referencian sin `Version`.
- **Toda entidad con datos económicos implementa `IAuditable`** y **genera su clave en memoria** (`Guid.CreateVersion7()`), nunca con identidad de la base. El interceptor escribe el asiento dentro del mismo `SaveChanges` que el cambio, y para eso necesita la clave antes de guardar. Si una propiedad no debe quedar copiada en la auditoría, se marca con `[NoAuditar]`.
- **La auditoría se escribe sola.** Ninguna funcionalidad agrega filas a `auditoria` a mano.
- **La configuración por instancia se enlaza en `src/Api/Arranque/`.** Los datos del emisor se validan al arrancar: una instancia mal configurada falla de entrada, no al emitir la primera factura.
- **Todo endpoint declara su autorización.** `RequireAuthorization(Politicas.X)` con las políticas de `src/Api/Autenticacion/Politicas.cs`; sin sesión responde 401 y con sesión insuficiente 403, porque la interfaz reacciona distinto a cada uno. Sólo `/api/health` queda abierto, que es lo que consulta el orquestador.

## Qué NO hacer

- **Cero credenciales en el repo.** Los certificados de ARCA y los tokens de WhatsApp van cifrados y por configuración por instancia; nunca se commitean al código (RNF-10). Tampoco van en `appsettings.json`: entran sólo por variables de entorno.
- **No exponer credenciales por la API ni por los logs.** Las clases de credenciales redactan su `ToString()`; no las imprimas campo por campo.
- **No borrar físicamente registros con historial económico.** Clientes, ventas, comprobantes, cobranzas y auditoría no se eliminan: solo baja lógica, anulación o ajuste con motivo (RNF-09, RF-04).
