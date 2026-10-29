# Arquitectura de Orbit

## Enfoque

Orbit sigue una arquitectura de **monolito modular** con un proceso worker separado. No se utilizan microservicios en el MVP. La API HTTP y el worker comparten módulos de dominio y acceso a datos, manteniendo los límites de dominio mediante paquetes Go internos.

## Componentes principales

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend  │────▶│   API (Go)   │────▶│  PostgreSQL  │
│  React/TS   │     │  net/http    │     │              │
│  Vite       │     │  chi router  │     │   pgx/sqlc   │
└─────────────┘     └──────┬───────┘     └──────────────┘
                           │                     ▲
                    WebSocket │              │
                           ▼                     │
                    ┌──────────────┐              │
                    │   Worker     │──────────────┘
                    │  (Go)       │
                    │  outbox     │
                    │  automation │
                    │  mail       │
                    └──────────────┘
```

### Frontend SPA

- **React + TypeScript** con `strict: true`.
- **Vite** para desarrollo y build.
- **Tailwind CSS + shadcn/ui** como base de componentes.
- **TanStack Query** para datos remotos, invalidación y caché.
- **React Hook Form + Zod** para formularios y validación.
- **React Router** para rutas.
- **Recharts** para gráficos del dashboard.
- **dnd-kit** para drag and drop accesible.
- Cliente API centralizado; tipos explícitos, sin `any`.

### API HTTP (Go)

- Servidor `net/http` con router `chi`.
- Prefijo `/api/v1` para todos los endpoints de negocio.
- JSON UTF-8 con fechas en ISO 8601/RFC 3339 UTC.
- IDs UUID generados en servidor.
- Respuesta y errores con formato consistente, incluyendo `request_id`.
- Middleware: request ID, CORS, cabeceras de seguridad, CSRF, rate limiting, timeouts, límites de payload.
- Logging estructurado con `slog`.
- Configuración validada al arranque; fallo rápido si falta una variable crítica.
- Health checks: `/health/live` y `/health/ready`.

### Base de datos (PostgreSQL)

- Fuente de verdad única.
- `pgx` como driver con pool de conexiones, límites y timeouts.
- `sqlc` para generar consultas tipadas desde SQL explícito.
- Migraciones versionadas y numeradas.
- UUID para identificadores públicos.
- `created_at`, `updated_at` en UTC en todas las tablas.
- `organization_id` en entidades multi-tenant.
- Claves foráneas, índices y restricciones `CHECK`/`UNIQUE` explícitas.
- Borrado lógico (`archived_at`, `deleted_at`) donde sea apropiado.

### Worker (Go)

- Proceso Go separado (`cmd/worker`).
- Reclama eventos del outbox transaccional con `FOR UPDATE SKIP LOCKED`.
- Ejecuta: automatizaciones, notificaciones, correo y trabajos programados.
- Reintentos con backoff exponencial y jitter; límite de intentos.
- Jobs idempotentes; recuperación tras reinicio.
- Shutdown ordenado con manejo de señales.

### Tiempo real (WebSocket)

- Conexión WebSocket autenticada con validación de organización.
- Eventos mínimos (tipo + ID), no objetos completos.
- Heartbeat y reconexión con backoff.
- No sustituye la API de lectura; los clientes resincronizan si pierden conexión.

### Correo

- Interfaz `Mailer` con implementación de consola en desarrollo.
- Proveedor real configurable por variable de entorno.
- Los fallos de correo no bloquean operaciones de negocio.

## Flujo de una mutación

1. El navegador envía una petición autenticada.
2. Middleware aplica request ID, límites de tamaño, logging y comprobaciones de seguridad.
3. Handler valida formato y DTO de entrada.
4. Servicio verifica organización, membresía, rol y reglas de dominio.
5. En una transacción PostgreSQL se modifica el recurso y se inserta un evento en `outbox_events`.
6. Se devuelve respuesta HTTP después del commit.
7. Worker reclama el evento de outbox y lo procesa de forma idempotente.
8. El worker ejecuta automatizaciones/notificaciones y publica el evento realtime cuando corresponda.
9. Los clientes autorizados actualizan su caché o vuelven a consultar el recurso.

> **Regla fundamental:** no se emite un evento externo antes de confirmar la transacción de base de datos.

## Multi-tenancy

- Toda consulta de dominio recibe `organizationID` validado como parámetro.
- No se busca un recurso solo por su ID para luego confiar en el cliente; siempre se filtra por `organization_id + id`.
- Consistencia entre `task.organization_id`, `project.organization_id` y membresía del `assignee`.
- Tests negativos explícitos: usuario de organización A no puede acceder a datos de organización B.

## Roles y autorización

| Rol       | Descripción                                                                 |
| --------- | --------------------------------------------------------------------------- |
| `owner`   | Administra la organización, miembros, configuración. Transferencia explícita. |
| `admin`   | Gestiona miembros, proyectos y ajustes. No transfiere propiedad.            |
| `member`  | Crea y modifica proyectos/tareas. No administra roles.                      |
| `viewer`  | Solo lectura de proyectos, tareas, comentarios y paneles.                   |

La autorización se aplica **en el servidor** en cada operación; ocultar un botón en el frontend no es autorización.

## Eventos de dominio

Los eventos de dominio se persisten en la tabla `outbox_events` dentro de la misma transacción que la mutación. El worker los reclama y procesa. Eventos iniciales previstos:

- `organization.created`, `membership.invited`, `membership.joined`, `membership.role_changed`
- `project.created`, `project.updated`, `project.archived`
- `task.created`, `task.updated`, `task.status_changed`, `task.assignee_changed`, `task.priority_changed`, `task.archived`
- `comment.created`
- `notification.created`
- `automation.run_started`, `automation.run_succeeded`, `automation.run_failed`

Cada evento incluye: `event_id`, `organization_id`, `occurred_at`, `actor_id` (opcional), `entity_type`, `entity_id` y un payload mínimo versionado.

## Automatizaciones

Las automatizaciones son reglas declarativas (JSON validado), no código ejecutable. Una regla define:

- **Trigger:** evento que la dispara (e.g., `task.status_changed`).
- **Conditions:** comprobaciones sobre el estado del recurso.
- **Actions:** acciones permitidas (cambiar estado, asignar, notificar, comentar).

Ejecución fiable: idempotencia por clave, reintentos con backoff, prevención de bucles por profundidad/límites, historial completo de ejecuciones.

## Decisiones registradas

Ver [docs/decisions/](../decisions/) para el registro completo de ADRs:

- [ADR-001: Monolito modular](../decisions/ADR-001-monolito-modular.md)
- [ADR-002: Cookies de sesión y CSRF](../decisions/ADR-002-cookies-sesion-csrf.md)
- [ADR-003: pgx + sqlc](../decisions/ADR-003-pgx-sqlc.md)
- [ADR-004: Outbox transaccional](../decisions/ADR-004-outbox-transaccional.md)
- [ADR-005: Protocolo de eventos realtime](../decisions/ADR-005-eventos-realtime.md)
- [ADR-006: DSL de automatización](../decisions/ADR-006-dsl-automatizacion.md)
- [ADR-007: Archivado y retención de datos](../decisions/ADR-007-archivado-retencion.md)

## Documentación relacionada

- [Alcance del MVP](mvp-scope.md)
- [Modelo de amenazas](threat-model.md)
- [Modelo de datos](data-model.md)
