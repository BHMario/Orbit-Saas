# Decisiones de arquitectura (ADRs)

Este directorio contiene las Architecture Decision Records del proyecto Orbit. Cada ADR documenta una decisión técnica significativa, su contexto, las alternativas consideradas y sus consecuencias.

## Índice

| ADR | Título | Estado |
| --- | ------ | ------ |
| [ADR-001](ADR-001-monolito-modular.md) | Monolito modular | Aceptada |
| [ADR-002](ADR-002-cookies-sesion-csrf.md) | Cookies de sesión y CSRF | Aceptada |
| [ADR-003](ADR-003-pgx-sqlc.md) | pgx + sqlc | Aceptada |
| [ADR-004](ADR-004-outbox-transaccional.md) | Outbox transaccional | Aceptada |
| [ADR-005](ADR-005-eventos-realtime.md) | Protocolo de eventos realtime | Aceptada |
| [ADR-006](ADR-006-dsl-automatizacion.md) | DSL de automatización | Aceptada |
| [ADR-007](ADR-007-archivado-retencion.md) | Archivado y retención de datos | Aceptada |

## Formato

Cada ADR sigue esta estructura:

- **Estado:** Propuesta / Aceptada / Reemplazada / Rechazada
- **Fecha:** cuándo se tomó la decisión
- **Contexto:** por qué surgió la necesidad
- **Decisión:** qué se decidió
- **Consecuencias:** positivas y negativas
- **Alternativas consideradas:** opciones evaluadas y por qué se descartaron

## Decisiones abiertas

Las siguientes decisiones se tomarán cuando haya más información:

- Proveedor de correo para producción.
- Proveedor de hosting.
- Si la búsqueda requiere PostgreSQL full-text o basta `ILIKE`.
- Biblioteca exacta de gráficos/drag-and-drop si cambian mantenimiento o accesibilidad.
- Estrategia de almacenamiento de avatares.
- Si se necesita un servicio externo de error tracking.
- Si WebSocket se ejecuta en el mismo proceso API o en un hub separado.
