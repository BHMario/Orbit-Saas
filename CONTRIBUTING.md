# Contribuir a Orbit

## Convenciones de commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>(<ámbito>): <descripción breve>

[cuerpo opcional]

[pie opcional]
```

### Tipos permitidos

| Tipo       | Uso                                           |
| ---------- | --------------------------------------------- |
| `feat`     | Nueva funcionalidad                           |
| `fix`      | Corrección de bug                             |
| `docs`     | Solo documentación                            |
| `chore`    | Tareas de mantenimiento sin cambio funcional  |
| `test`     | Añadir o corregir tests                       |
| `refactor` | Cambio de código sin cambiar comportamiento   |
| `perf`     | Mejora de rendimiento                         |
| `ci`       | Cambios en CI/CD                              |
| `build`    | Cambios en el sistema de build                |
| `security` | Mejoras de seguridad                          |
| `release`  | Preparación de release                        |

### Ámbitos frecuentes

`repo`, `api`, `ui`, `db`, `auth`, `orgs`, `tasks`, `projects`, `automation`, `worker`, `realtime`, `security`, `tooling`, `dev`

## Flujo de trabajo

1. Crear una rama desde `main` con nombre descriptivo.
2. Implementar cambios con commits atómicos.
3. Asegurar que `make lint`, `make test` y `make build` pasan.
4. Crear PR con descripción del cambio, criterios de aceptación y testing realizado.

## Formato de código

### Go
- `gofmt` obligatorio.
- `go vet` sin errores.
- `golangci-lint` cuando se incorpore.

### Frontend
- ESLint + Prettier configurados.
- `tsc --noEmit` sin errores.

## Reglas generales

- No incluir secretos, tokens ni datos personales en el repositorio.
- No modificar migraciones ya aplicadas; crear nuevas.
- Mantener el proyecto compilable/ejecutable tras cada commit.
- Actualizar documentación cuando cambie el comportamiento.
- Registrar decisiones relevantes en `docs/decisions/`.
- Priorizar claridad y mantenibilidad sobre abstracción prematura.
