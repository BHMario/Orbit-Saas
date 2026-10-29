# Alcance del MVP — Orbit

## Incluido en el MVP

### Cuenta y autenticación
- Registro e inicio de sesión con correo y contraseña.
- Cookies de sesión seguras (`HttpOnly`, `Secure` en producción, `SameSite=Lax`).
- Hash de contraseñas con Argon2id.
- Cierre de sesión con invalidación en servidor.
- Verificación de correo mediante token de un solo uso.
- Recuperación de contraseña con token hasheado y caducidad.
- Protección contra abuso: rate limiting en login, registro, recuperación.
- Perfil: editar nombre y avatar (URL validada).

### Organizaciones y membresías
- Crear organización con nombre, slug único y zona horaria.
- Selector de organización para usuarios con múltiples organizaciones.
- Roles: `owner`, `admin`, `member`, `viewer`.
- Invitaciones por correo con token de un solo uso, caducidad y hash.
- Gestión de miembros: invitar, revocar, cambiar roles.
- Transferencia de propiedad explícita y transaccional.
- Aislamiento multi-tenant verificado en todas las consultas.

### Proyectos
- CRUD de proyectos con nombre, descripción, estado, color, fechas.
- Estados: `planned`, `active`, `on_hold`, `completed`, `archived`.
- Listado con filtros por estado, responsable y búsqueda.
- Archivado con confirmación (datos permanecen consultables).

### Tareas
- CRUD con título, descripción Markdown sanitizada, estado, prioridad, responsable, fechas.
- Estados: `backlog`, `todo`, `in_progress`, `in_review`, `done`.
- Prioridades: `low`, `medium`, `high`, `urgent`.
- Asignación a miembros de la misma organización.
- Movimiento entre columnas y reordenamiento transaccional.
- Concurrencia optimista con campo `version`.
- Filtros por estado, prioridad, responsable, fecha, texto.

### Tablero y vistas
- Tablero Kanban con columnas por estado y tarjetas.
- Drag and drop con alternativa accesible por teclado.
- Vista de lista con columnas y filtros equivalentes.
- Persistencia con actualización optimista reversible.

### Colaboración
- Comentarios en tareas con edición/eliminación propia.
- Registro de actividad para cambios significativos.
- Notificaciones internas (asignación, respuestas, reglas).
- Marcar leído/no leído, centro de notificaciones paginado.

### Dashboard
- Resumen: proyectos activos, tareas abiertas/vencidas/completadas.
- Actividad reciente, gráficos de tendencias y distribución.
- Filtros temporales con zona horaria coherente.
- Agregación en SQL, no en el navegador.

### Automatizaciones
- Reglas con trigger, condiciones y acciones (JSON declarativo).
- Triggers MVP: `task.created`, `task.status_changed`, `task.assignee_changed`, `task.due_date_approaching`.
- Acciones MVP: cambiar estado, asignar, cambiar prioridad, comentar, notificar.
- Ejecución asíncrona con worker, reintentos, idempotencia.
- Prevención de bucles, historial de ejecuciones.
- Constructor visual con vista previa legible.

### Búsqueda
- Búsqueda de proyectos y tareas dentro de la organización.
- Resultados agrupados por tipo con enlace al detalle.
- PostgreSQL (`ILIKE`/full-text según necesidad).

### Tiempo real
- WebSocket autenticado con eventos de actualización.
- Suscripción por organización con validación de permisos.
- Reconexión con backoff.

### Infraestructura
- Docker Compose para desarrollo.
- Migraciones versionadas.
- CI con formato, lint, tests y build.
- Diseño responsive (escritorio, tablet, móvil).

---

## Fuera del MVP (evolución futura)

- Aplicaciones móviles nativas.
- Facturación y suscripciones comerciales reales.
- SSO empresarial/SAML y SCIM.
- Invitados externos con permisos por proyecto.
- Aplicaciones de terceros y marketplace de integraciones.
- IA generativa para resúmenes y asistencia.
- Dependencias avanzadas entre tareas y planificación tipo Gantt.
- Archivos adjuntos con almacenamiento de objetos.
- Aplicación offline completa.
- Analítica avanzada y exportaciones personalizadas.
- Multi-región y alta disponibilidad empresarial.

---

## No objetivos

- No competir inicialmente con Jira, Linear o Asana en todas sus capacidades.
- No construir un microservicio por cada dominio.
- No introducir Kubernetes, Kafka o Redis sin necesidad demostrada.
- No depender de una API de IA para que las funciones centrales funcionen.
- No hacer del tiempo real una condición para guardar datos.

---

## Métricas orientativas

Son objetivos de diseño, no garantías de rendimiento:

| Métrica | Objetivo |
| ------- | -------- |
| Tiempo hasta primer proyecto | < 3 minutos |
| Carga de tablero (500 tareas) | < 2 segundos |
| API p95 (CRUD común) | < 400 ms |
| Endpoints con auth/authz | 100% |
| Consultas acotadas por `organization_id` | 100% |
| Idempotencia en reintentos de automatización | Garantizada |
| Flujos críticos con tests | Cubiertos |
