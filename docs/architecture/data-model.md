# Modelo de datos — Orbit

## Convenciones

- PostgreSQL con migraciones versionadas.
- UUID para identificadores públicos.
- `created_at`, `updated_at` en UTC (`TIMESTAMPTZ`).
- `organization_id` en las entidades multi-tenant.
- Claves foráneas e índices explícitos.
- Restricciones `CHECK`/`UNIQUE` para reforzar invariantes.
- Borrado lógico (`archived_at`, `deleted_at`) donde sea apropiado.
- No almacenar datos redundantes salvo razón de rendimiento documentada.
- `CITEXT` para campos que requieran comparación case-insensitive (email, slug).

---

## Tablas principales

### `users`

| Columna            | Tipo          | Restricciones                |
| ------------------ | ------------- | ---------------------------- |
| `id`               | `UUID`        | PK                           |
| `name`             | `TEXT`        | NOT NULL                     |
| `email`            | `CITEXT`      | NOT NULL, UNIQUE             |
| `password_hash`    | `TEXT`        | NOT NULL                     |
| `email_verified_at`| `TIMESTAMPTZ` | NULL                         |
| `avatar_url`       | `TEXT`        | NULL                         |
| `timezone`         | `TEXT`        | NOT NULL, DEFAULT `'UTC'`    |
| `created_at`       | `TIMESTAMPTZ` | NOT NULL                     |
| `updated_at`       | `TIMESTAMPTZ` | NOT NULL                     |
| `deleted_at`       | `TIMESTAMPTZ` | NULL                         |

### `sessions`

| Columna         | Tipo          | Restricciones                |
| --------------- | ------------- | ---------------------------- |
| `id`            | `UUID`        | PK                           |
| `user_id`       | `UUID`        | FK → `users`                 |
| `token_hash`    | `TEXT`        | NOT NULL, UNIQUE             |
| `expires_at`    | `TIMESTAMPTZ` | NOT NULL                     |
| `created_at`    | `TIMESTAMPTZ` | NOT NULL                     |
| `last_seen_at`  | `TIMESTAMPTZ` | NOT NULL                     |
| `ip_hash`       | `TEXT`        | NULL                         |
| `user_agent`    | `TEXT`        | NULL                         |

> Retención mínima de `ip_hash` y `user_agent` con política documentada.

### `password_reset_tokens`

| Columna      | Tipo          | Restricciones                |
| ------------ | ------------- | ---------------------------- |
| `id`         | `UUID`        | PK                           |
| `user_id`    | `UUID`        | FK → `users`                 |
| `token_hash` | `TEXT`        | NOT NULL, UNIQUE             |
| `expires_at` | `TIMESTAMPTZ` | NOT NULL                     |
| `used_at`    | `TIMESTAMPTZ` | NULL                         |
| `created_at` | `TIMESTAMPTZ` | NOT NULL                     |

### `organizations`

| Columna       | Tipo          | Restricciones                |
| ------------- | ------------- | ---------------------------- |
| `id`          | `UUID`        | PK                           |
| `name`        | `TEXT`        | NOT NULL                     |
| `slug`        | `CITEXT`      | NOT NULL, UNIQUE             |
| `timezone`    | `TEXT`        | NOT NULL, DEFAULT `'UTC'`    |
| `created_by`  | `UUID`        | FK → `users`                 |
| `created_at`  | `TIMESTAMPTZ` | NOT NULL                     |
| `updated_at`  | `TIMESTAMPTZ` | NOT NULL                     |
| `archived_at` | `TIMESTAMPTZ` | NULL                         |

### `memberships`

| Columna           | Tipo          | Restricciones                           |
| ----------------- | ------------- | --------------------------------------- |
| `id`              | `UUID`        | PK                                      |
| `organization_id` | `UUID`        | FK → `organizations`                    |
| `user_id`         | `UUID`        | FK → `users`                            |
| `role`            | `TEXT`        | CHECK IN (`owner`, `admin`, `member`, `viewer`) |
| `joined_at`       | `TIMESTAMPTZ` | NOT NULL                                |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                                |

- UNIQUE (`organization_id`, `user_id`)

### `invitations`

| Columna           | Tipo          | Restricciones                           |
| ----------------- | ------------- | --------------------------------------- |
| `id`              | `UUID`        | PK                                      |
| `organization_id` | `UUID`        | FK → `organizations`                    |
| `email`           | `CITEXT`      | NOT NULL                                |
| `role`            | `TEXT`        | CHECK IN (`admin`, `member`, `viewer`)  |
| `token_hash`      | `TEXT`        | NOT NULL, UNIQUE                        |
| `invited_by`      | `UUID`        | FK → `users`                            |
| `expires_at`      | `TIMESTAMPTZ` | NOT NULL                                |
| `accepted_at`     | `TIMESTAMPTZ` | NULL                                    |
| `revoked_at`      | `TIMESTAMPTZ` | NULL                                    |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                                |

> Prevención de duplicados pendientes por organización/correo mediante índice parcial o estrategia transaccional.

### `projects`

| Columna           | Tipo          | Restricciones                                              |
| ----------------- | ------------- | ---------------------------------------------------------- |
| `id`              | `UUID`        | PK                                                         |
| `organization_id` | `UUID`        | FK → `organizations`                                       |
| `name`            | `TEXT`        | NOT NULL                                                   |
| `description`     | `TEXT`        | NULL                                                       |
| `status`          | `TEXT`        | CHECK IN (`planned`, `active`, `on_hold`, `completed`, `archived`) |
| `color`           | `TEXT`        | NULL                                                       |
| `start_date`      | `DATE`        | NULL                                                       |
| `due_date`        | `DATE`        | NULL                                                       |
| `created_by`      | `UUID`        | FK → `users`                                               |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                                                   |
| `updated_at`      | `TIMESTAMPTZ` | NOT NULL                                                   |
| `archived_at`     | `TIMESTAMPTZ` | NULL                                                       |

- Índices por `organization_id`, `status`, `updated_at`.

### `tasks`

| Columna           | Tipo          | Restricciones                                              |
| ----------------- | ------------- | ---------------------------------------------------------- |
| `id`              | `UUID`        | PK                                                         |
| `organization_id` | `UUID`        | FK → `organizations`                                       |
| `project_id`      | `UUID`        | FK → `projects`                                            |
| `title`           | `TEXT`        | NOT NULL                                                   |
| `description`     | `TEXT`        | NULL                                                       |
| `status`          | `TEXT`        | CHECK IN (`backlog`, `todo`, `in_progress`, `in_review`, `done`) |
| `priority`        | `TEXT`        | CHECK IN (`low`, `medium`, `high`, `urgent`)               |
| `assignee_id`     | `UUID`        | NULL, FK → `users`                                         |
| `created_by`      | `UUID`        | FK → `users`                                               |
| `due_date`        | `DATE`        | NULL                                                       |
| `position`        | `NUMERIC`     | NOT NULL                                                   |
| `version`         | `BIGINT`      | NOT NULL, DEFAULT 1                                        |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                                                   |
| `updated_at`      | `TIMESTAMPTZ` | NOT NULL                                                   |
| `archived_at`     | `TIMESTAMPTZ` | NULL                                                       |

- Índices: `(organization_id, project_id, status, position)`, `assignee_id`, `due_date`.
- Restricciones de servicio: proyecto, tarea y responsable pertenecen a la misma organización.

### `comments`

| Columna           | Tipo          | Restricciones                |
| ----------------- | ------------- | ---------------------------- |
| `id`              | `UUID`        | PK                           |
| `organization_id` | `UUID`        | FK → `organizations`         |
| `task_id`         | `UUID`        | FK → `tasks`                 |
| `author_id`       | `UUID`        | FK → `users`                 |
| `body`            | `TEXT`        | NOT NULL                     |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                     |
| `updated_at`      | `TIMESTAMPTZ` | NOT NULL                     |
| `deleted_at`      | `TIMESTAMPTZ` | NULL                         |

### `activity_events`

| Columna           | Tipo          | Restricciones                |
| ----------------- | ------------- | ---------------------------- |
| `id`              | `UUID`        | PK                           |
| `organization_id` | `UUID`        | FK → `organizations`         |
| `actor_id`        | `UUID`        | NULL, FK → `users`           |
| `entity_type`     | `TEXT`        | NOT NULL                     |
| `entity_id`       | `UUID`        | NOT NULL                     |
| `event_type`      | `TEXT`        | NOT NULL                     |
| `payload`         | `JSONB`       | NOT NULL (allowlist de campos) |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                     |

- Índices: `(organization_id, created_at)`, `(entity_type, entity_id, created_at)`.

### `notifications`

| Columna           | Tipo          | Restricciones                |
| ----------------- | ------------- | ---------------------------- |
| `id`              | `UUID`        | PK                           |
| `organization_id` | `UUID`        | FK → `organizations`         |
| `user_id`         | `UUID`        | FK → `users`                 |
| `type`            | `TEXT`        | NOT NULL                     |
| `payload`         | `JSONB`       | NOT NULL (sin secretos)      |
| `read_at`         | `TIMESTAMPTZ` | NULL                         |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                     |

- Índice: `(user_id, created_at)` con filtro para no leídas.

### `automation_rules`

| Columna           | Tipo          | Restricciones                |
| ----------------- | ------------- | ---------------------------- |
| `id`              | `UUID`        | PK                           |
| `organization_id` | `UUID`        | FK → `organizations`         |
| `name`            | `TEXT`        | NOT NULL                     |
| `description`     | `TEXT`        | NULL                         |
| `trigger_type`    | `TEXT`        | NOT NULL                     |
| `conditions`      | `JSONB`       | NOT NULL                     |
| `actions`         | `JSONB`       | NOT NULL                     |
| `enabled`         | `BOOLEAN`     | NOT NULL, DEFAULT `false`    |
| `created_by`      | `UUID`        | FK → `users`                 |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                     |
| `updated_at`      | `TIMESTAMPTZ` | NOT NULL                     |
| `archived_at`     | `TIMESTAMPTZ` | NULL                         |

> Versión de esquema para `conditions`/`actions`.

### `automation_runs`

| Columna              | Tipo          | Restricciones                                              |
| -------------------- | ------------- | ---------------------------------------------------------- |
| `id`                 | `UUID`        | PK                                                         |
| `organization_id`    | `UUID`        | FK → `organizations`                                       |
| `rule_id`            | `UUID`        | FK → `automation_rules`                                    |
| `event_id`           | `UUID`        | NOT NULL                                                   |
| `status`             | `TEXT`        | CHECK IN (`queued`, `running`, `succeeded`, `failed`, `skipped`) |
| `attempts`           | `INT`         | NOT NULL, DEFAULT 0                                        |
| `started_at`         | `TIMESTAMPTZ` | NULL                                                       |
| `finished_at`        | `TIMESTAMPTZ` | NULL                                                       |
| `error_code`         | `TEXT`        | NULL                                                       |
| `error_message_safe` | `TEXT`        | NULL                                                       |
| `result`             | `JSONB`       | NOT NULL, DEFAULT `'{}'`                                   |

> Clave única idempotente basada en `(rule_id, event_id)` cuando la semántica lo permita.

### `outbox_events`

| Columna           | Tipo          | Restricciones                |
| ----------------- | ------------- | ---------------------------- |
| `id`              | `UUID`        | PK                           |
| `organization_id` | `UUID`        | NULL                         |
| `event_type`      | `TEXT`        | NOT NULL                     |
| `aggregate_type`  | `TEXT`        | NOT NULL                     |
| `aggregate_id`    | `UUID`        | NOT NULL                     |
| `payload`         | `JSONB`       | NOT NULL                     |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                     |
| `available_at`    | `TIMESTAMPTZ` | NOT NULL                     |
| `processed_at`    | `TIMESTAMPTZ` | NULL                         |
| `attempts`        | `INT`         | NOT NULL, DEFAULT 0          |
| `locked_at`       | `TIMESTAMPTZ` | NULL                         |
| `last_error`      | `TEXT`        | NULL (saneado)               |

- Índices para reclamar eventos pendientes (`processed_at IS NULL`, `available_at`, `locked_at`).

### `audit_logs`

| Columna           | Tipo          | Restricciones                |
| ----------------- | ------------- | ---------------------------- |
| `id`              | `UUID`        | PK                           |
| `organization_id` | `UUID`        | FK → `organizations`         |
| `actor_id`        | `UUID`        | NULL, FK → `users`           |
| `action`          | `TEXT`        | NOT NULL                     |
| `target_type`     | `TEXT`        | NOT NULL                     |
| `target_id`       | `UUID`        | NULL                         |
| `metadata`        | `JSONB`       | NOT NULL                     |
| `created_at`      | `TIMESTAMPTZ` | NOT NULL                     |

> Registros de auditoría no editables desde la UI ordinaria.

### `email_outbox` (opcional)

| Columna        | Tipo          | Restricciones                |
| -------------- | ------------- | ---------------------------- |
| `id`           | `UUID`        | PK                           |
| `recipient`    | `TEXT`        | NOT NULL                     |
| `template_key` | `TEXT`        | NOT NULL                     |
| `payload`      | `JSONB`       | NOT NULL (sin credenciales)  |
| `status`       | `TEXT`        | NOT NULL                     |
| `attempts`     | `INT`         | NOT NULL, DEFAULT 0          |
| `available_at` | `TIMESTAMPTZ` | NOT NULL                     |
| `sent_at`      | `TIMESTAMPTZ` | NULL                         |
| `last_error`   | `TEXT`        | NULL                         |

---

## Diagrama de relaciones

```
users ──────────┬──────────── sessions
                │
                ├──────────── password_reset_tokens
                │
                ├──── memberships ────── organizations
                │                            │
                │                            ├──── invitations
                │                            │
                │                            ├──── projects
                │                            │        │
                │                            │        └──── tasks
                │                            │               │
                │                            │               ├──── comments
                │                            │               │
                │                            │               └──── activity_events
                │                            │
                │                            ├──── notifications
                │                            │
                │                            ├──── automation_rules
                │                            │        │
                │                            │        └──── automation_runs
                │                            │
                │                            ├──── outbox_events
                │                            │
                │                            └──── audit_logs
```

## Integridad y multi-tenancy

- Todas las consultas de dominio reciben `organizationID` validado.
- No buscar un recurso solo por su ID sin filtrar por organización.
- Validar consistencia entre `task.organization_id`, `project.organization_id` y membresía del `assignee`.
- Tests explícitos: usuario de organización A no puede leer, actualizar, borrar, comentar, buscar ni recibir eventos de organización B.
- Índices compuestos corresponden a consultas reales y se miden.
