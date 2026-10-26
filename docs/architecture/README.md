# Arquitectura de Orbit

## Enfoque

Orbit sigue una arquitectura de **monolito modular** con un proceso worker separado. No se utilizan microservicios en el MVP.

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

## Principios

1. **PostgreSQL como fuente de verdad** — Toda la persistencia y eventos vía transactional outbox.
2. **SQL explícito** — `pgx` + `sqlc` para consultas tipadas y visibles.
3. **Sesiones con cookies seguras** — No JWT en localStorage.
4. **Automatizaciones declarativas** — Reglas JSON validadas, sin código arbitrario.
5. **Multi-tenant por organización** — Aislamiento verificado en cada consulta.
6. **Sin dependencias innecesarias** — No Redis, Kafka ni Kubernetes en el MVP.

## Flujo de una mutación

1. El navegador envía una petición autenticada.
2. Middleware aplica request ID, límites, logging y seguridad.
3. Handler valida formato y DTO de entrada.
4. Servicio verifica organización, membresía, rol y reglas de dominio.
5. En una transacción PostgreSQL se modifica el recurso y se inserta un evento en `outbox_events`.
6. Se devuelve respuesta HTTP después del commit.
7. Worker reclama el evento y lo procesa de forma idempotente.
8. El worker ejecuta automatizaciones/notificaciones y publica el evento realtime.
9. Los clientes actualizan su caché o vuelven a consultar.

## Decisiones registradas

Ver [docs/decisions/](../decisions/) para el registro completo de ADRs.
