# ADR-006: DSL de automatización

## Estado
Aceptada

## Fecha
2026-10-26

## Contexto
Orbit necesita un sistema de reglas que permita a los usuarios automatizar acciones repetitivas (e.g., "cuando una tarea pase a `done`, asignar prioridad `low`"). El sistema debe ser seguro, auditable y no permitir ejecución de código arbitrario.

## Decisión
Adoptamos un **DSL declarativo basado en JSON** con esquema versionado y validación estricta:

```json
{
  "version": 1,
  "trigger": { "type": "task.status_changed" },
  "conditions": [
    { "field": "task.priority", "operator": "equals", "value": "urgent" }
  ],
  "actions": [
    { "type": "task.assign", "value": "uuid-del-miembro" },
    { "type": "notification.create", "target": "assignee" }
  ]
}
```

### Triggers MVP
- `task.created`
- `task.status_changed`
- `task.assignee_changed`
- `task.due_date_approaching` (mediante worker programado)

### Condiciones MVP
- Estado es/no es
- Prioridad es/no es
- Responsable es/no es
- Proyecto es
- Fecha de vencimiento presente/ausente

### Acciones MVP
- Cambiar estado
- Asignar responsable
- Cambiar prioridad
- Añadir comentario del sistema
- Crear notificación

### Controles de seguridad
- Validación al guardar y al ejecutar.
- Las acciones operan dentro de la organización propietaria.
- Idempotencia por clave `(rule_id, event_id)`.
- Prevención de bucles: origen del evento, profundidad y límites de ejecución.
- Límites por organización: máximo de reglas, concurrencia y frecuencia.

## Consecuencias

### Positivas
- Seguro: no ejecuta código arbitrario.
- Auditable: cada ejecución queda registrada con resultado.
- Extensible: nuevos triggers, condiciones y acciones se añaden incrementalmente.
- Comprensible: el constructor visual genera una vista legible en lenguaje natural.

### Negativas
- Flexibilidad limitada comparada con código o scripts.
- Requiere constructor visual para ser accesible a usuarios no técnicos.
- Las condiciones complejas (AND/OR anidados) pueden necesitar evolución del esquema.

## Alternativas consideradas
- **Motor de reglas con código (JavaScript/Lua):** descartado por riesgos de seguridad y complejidad de sandboxing.
- **Webhooks salientes:** útiles como complemento futuro, pero no resuelven automatizaciones internas.
- **YAML en vez de JSON:** descartado por la dificultad de validación y edición en un builder visual.
