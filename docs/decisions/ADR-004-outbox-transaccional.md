# ADR-004: Outbox transaccional

## Estado
Aceptada

## Fecha
2026-10-26

## Contexto
Orbit necesita publicar eventos de dominio (para automatizaciones, notificaciones, tiempo real y auditoría) de forma fiable. Si el evento se emite antes de confirmar la transacción de base de datos, un rollback dejaría un evento huérfano. Si se emite después y el proceso falla, el evento se pierde.

## Decisión
Adoptamos el **patrón transactional outbox**: en la misma transacción que modifica un recurso de negocio, se inserta un registro en la tabla `outbox_events`. Un worker separado reclama estos eventos y los procesa.

- La tabla `outbox_events` tiene campos para tipo, payload, estado, intentos y bloqueo.
- El worker usa `FOR UPDATE SKIP LOCKED` para reclamar registros sin colisiones.
- Los eventos se procesan de forma idempotente.
- Los errores transitorios se reintentan con backoff exponencial.

## Consecuencias

### Positivas
- Garantía de que un evento solo existe si la mutación fue confirmada.
- No se requiere un message broker externo (sin Kafka, RabbitMQ, etc.).
- Reintentos y recuperación ante fallos del worker.
- Toda la infraestructura en PostgreSQL, simplificando operaciones.

### Negativas
- Latencia entre la mutación y el procesamiento del evento (polling del worker).
- La tabla outbox crece y requiere limpieza periódica de eventos procesados.
- Más complejidad que emitir eventos en memoria (pero mucho más fiable).

## Alternativas consideradas
- **Emitir evento tras commit:** riesgo de pérdida si el proceso falla entre commit y emisión.
- **Message broker externo (Kafka, RabbitMQ):** innecesario para el volumen del MVP; añade complejidad operativa.
- **CDC (Change Data Capture):** sofisticado y dependiente de infraestructura; prematura para el MVP.
