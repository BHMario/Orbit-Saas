# Orbit

**SaaS de gestión de proyectos y tareas para equipos.**

Orbit es una aplicación web para que pequeños equipos y empresas organicen proyectos, planifiquen trabajo, gestionen tareas mediante tableros, consulten métricas y automaticen acciones repetitivas.

---

## Visión

Reunir la gestión de proyectos en un espacio compartido, con actividad observable y automatizaciones sencillas. Una interfaz cuidada, rápida, accesible, coherente y segura.

## Stack tecnológico

| Capa            | Tecnología                                      |
| --------------- | ----------------------------------------------- |
| **Backend**     | Go · `net/http` · `chi` · `pgx` · `sqlc`       |
| **Frontend**    | React · TypeScript · Vite · Tailwind · shadcn/ui |
| **Base de datos** | PostgreSQL                                    |
| **Worker**      | Go (proceso separado)                           |
| **Tiempo real** | WebSocket                                       |
| **Desarrollo**  | Docker Compose                                  |

## Estructura del repositorio

```
orbit/
  cmd/
    api/           → Punto de entrada del servidor HTTP
    worker/        → Punto de entrada del worker de fondo
  internal/        → Módulos de dominio (auth, orgs, projects, tasks…)
  db/
    migrations/    → Migraciones SQL versionadas
    queries/       → Consultas SQL para sqlc
  frontend/
    src/           → Aplicación React + TypeScript
  tests/
    integration/   → Tests de integración
    e2e/           → Tests end-to-end
  docs/
    architecture/  → Documentación de arquitectura
    decisions/     → ADRs (Architecture Decision Records)
    api/           → Documentación de API
    runbooks/      → Guías operativas
  deploy/          → Configuración de despliegue
  scripts/         → Scripts de utilidad
  .github/
    workflows/     → Pipelines CI/CD
```

## Requisitos previos

- **Go**: `1.26+` (`go version`)
- **Node.js**: `22+` LTS (`node --version`)
- **npm**: `10+` (`npm --version`)
- **Docker & Docker Compose**: para servicios locales de desarrollo

## Comandos previstos

```bash
# Entorno de desarrollo
make dev-up          # Levanta PostgreSQL y servicios con Docker Compose
make dev-down        # Detiene los servicios

# Backend
make run-api         # Ejecuta el servidor API
make run-worker      # Ejecuta el worker
make build           # Compila binarios
make test            # Ejecuta tests
make lint            # Análisis estático
make fmt             # Formato de código

# Base de datos
make migrate-up      # Aplica migraciones pendientes
make migrate-down    # Revierte la última migración
make migrate-status  # Estado de migraciones
make sqlc-generate   # Genera código desde consultas SQL

# Frontend
make fe-dev          # Servidor de desarrollo frontend
make fe-build        # Build de producción
make fe-lint         # Lint de frontend
make fe-test         # Tests de frontend
```

## Inicio rápido

> ⚠️ Estas instrucciones estarán completas una vez se configure Docker Compose y las herramientas (commits C03-C04).

```bash
# 1. Clonar el repositorio
git clone <url> && cd orbit

# 2. Copiar y configurar variables de entorno
cp .env.example .env

# 3. Levantar servicios
make dev-up

# 4. Aplicar migraciones
make migrate-up

# 5. Ejecutar el backend
make run-api

# 6. En otra terminal, ejecutar el frontend
make fe-dev
```

## Documentación

- [Arquitectura](docs/architecture/README.md) — Componentes, flujos y principios de diseño
  - [Alcance del MVP](docs/architecture/mvp-scope.md) — Qué incluye y qué no el MVP
  - [Modelo de amenazas](docs/architecture/threat-model.md) — Amenazas prioritarias y controles
  - [Modelo de datos](docs/architecture/data-model.md) — Tablas, relaciones y convenciones
- [Decisiones técnicas (ADRs)](docs/decisions/README.md) — Registro de decisiones arquitectónicas
- [API](docs/api/) — Documentación de endpoints (por completar)
- [Guías operativas](docs/runbooks/) — Runbooks de operación (por completar)

## Contribuir

Consulta [CONTRIBUTING.md](CONTRIBUTING.md) para las convenciones de código, formato de commits y flujo de trabajo.

## Licencia

Por definir.