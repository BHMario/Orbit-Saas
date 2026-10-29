# ADR-007: Archivado y retención de datos

## Estado
Aceptada

## Fecha
2026-10-26

## Contexto
Los usuarios necesitan poder "eliminar" proyectos, tareas y otros recursos, pero el borrado irreversible puede causar pérdida de datos, romper referencias históricas y dificultar la auditoría.

## Decisión
Adoptamos **archivado (soft delete) como mecanismo principal** en la primera versión:

- Los recursos de trabajo (proyectos, tareas, reglas de automatización) usan `archived_at TIMESTAMPTZ NULL`.
- Los recursos de cuenta (usuarios) usan `deleted_at TIMESTAMPTZ NULL`.
- Los datos archivados permanecen consultables según permisos pero no aparecen en listas activas por defecto.
- No se ofrece borrado irreversible en el MVP para recursos de trabajo.
- Si se añade borrado en el futuro, requerirá confirmación explícita y política de retención documentada.

### Reglas de archivado
- Archivar un proyecto requiere confirmación.
- Archivar una tarea la retira del tablero activo pero mantiene historial y comentarios.
- No se archiva en cascada sin intención explícita.
- Los recursos archivados se pueden filtrar en vistas cuando el usuario lo solicite.

### Retención
- Los registros de auditoría no se eliminan desde la UI ordinaria.
- Sesiones expiradas se limpian periódicamente.
- Eventos de outbox procesados se limpian periódicamente.
- La política de retención completa se definirá antes de producción pública.

## Consecuencias

### Positivas
- No se pierden datos accidentalmente.
- El historial de actividad permanece íntegro.
- Las referencias (comentarios, asignaciones) no quedan rotas.
- Compatible con requisitos de auditoría y cumplimiento.

### Negativas
- La base de datos crece más que con borrado físico.
- Todas las consultas deben considerar el campo `archived_at`/`deleted_at`.
- Puede confundir a usuarios si no queda claro qué significa "archivar".

## Alternativas consideradas
- **Borrado físico (hard delete):** descartado por riesgo de pérdida de datos y rotura de integridad referencial.
- **Papelera con periodo de gracia:** viable como evolución futura, pero añade complejidad sin beneficio claro en el MVP.

## Decisiones abiertas
- Periodo de retención exacto para datos archivados antes de borrado definitivo.
- Proceso de exportación/eliminación completa para cumplimiento RGPD.
