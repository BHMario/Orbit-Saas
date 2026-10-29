# ADR-005: Protocolo de eventos realtime

## Estado
Aceptada

## Fecha
2026-10-26

## Contexto
Los usuarios necesitan ver actualizaciones en tiempo real (tareas movidas, nuevos comentarios, notificaciones) sin recargar la página. Las opciones incluyen WebSocket, SSE (Server-Sent Events) y polling.

## Decisión
Adoptamos **WebSocket** para comunicación en tiempo real:

- Conexión autenticada mediante la cookie de sesión existente.
- Suscripción por organización con validación de membresía.
- Eventos mínimos: `{ type, entity_type, entity_id }`, no objetos completos.
- Los clientes usan el evento como señal para refetch mediante la API REST (TanStack Query invalidation).
- Heartbeat periódico y reconexión con backoff exponencial del lado del cliente.
- La API REST sigue siendo la fuente de verdad; el WebSocket no sustituye lecturas.

## Consecuencias

### Positivas
- Actualizaciones inmediatas sin polling.
- Protocolo bidireccional disponible si se necesita en el futuro.
- Eventos ligeros que no duplican la lógica de la API.
- Compatible con la infraestructura actual (un proceso Go).

### Negativas
- Gestión de conexiones en el servidor (memoria, goroutines).
- Necesidad de manejar reconexión y sincronización de estado en el cliente.
- Requiere validación de origen (`Sec-WebSocket-Origin`) para prevenir cross-site WebSocket hijacking.

## Alternativas consideradas
- **SSE (Server-Sent Events):** unidireccional, adecuado pero con limitaciones en navegadores para múltiples conexiones; WebSocket es más flexible.
- **Long polling:** más sencillo pero ineficiente para actualizaciones frecuentes.
- **Servicio dedicado de realtime:** prematura para el MVP; se evaluará si la escala lo requiere.

## Decisiones abiertas
- Si el WebSocket se ejecuta en el mismo proceso API o en un hub separado se decidirá según la carga medida.
