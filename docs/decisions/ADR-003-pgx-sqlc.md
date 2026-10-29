# ADR-003: pgx + sqlc

## Estado
Aceptada

## Fecha
2026-10-26

## Contexto
Necesitamos una estrategia de acceso a datos para PostgreSQL en Go que sea segura, tipada y mantenible. Las opciones incluyen ORMs (GORM, Ent), query builders (squirrel) y generadores de código desde SQL (sqlc).

## Decisión
Adoptamos **`pgx`** como driver PostgreSQL y **`sqlc`** para generar código Go tipado a partir de consultas SQL explícitas.

- Las consultas se escriben en archivos `.sql` en `db/queries/`.
- `sqlc` genera structs y funciones Go tipadas.
- Las transacciones se gestionan explícitamente con `pgx`.
- No se edita el código generado manualmente.

## Consecuencias

### Positivas
- SQL visible, versionado y revisable.
- Tipos generados que evitan errores de mapeo en tiempo de ejecución.
- Rendimiento directo sin capas de abstracción intermedias.
- Compatible con todas las funcionalidades de PostgreSQL sin limitaciones de ORM.
- Detección de errores SQL en tiempo de generación.

### Negativas
- Requiere ejecutar `sqlc generate` tras cambiar consultas.
- Consultas dinámicas (filtros opcionales) requieren más trabajo manual.
- Menos "mágico" que un ORM; se necesita escribir cada consulta.

## Alternativas consideradas
- **GORM:** descartado por queries implícitas, dificultad para optimizar y comportamiento inesperado con relaciones.
- **Ent:** descartado por ser un framework de esquema completo que puede limitar el control sobre SQL.
- **squirrel:** viable como complemento para queries dinámicas, pero no resuelve tipado de resultados.
