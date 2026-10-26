# ADR-001: Monolito modular

## Estado
Aceptada

## Fecha
2026-10-26

## Contexto
Orbit necesita una arquitectura que permita desarrollo rápido, despliegue sencillo y evolución futura sin la complejidad operativa de microservicios desde el inicio.

## Decisión
Adoptamos un **monolito modular en Go** con un proceso worker separado. API HTTP y worker comparten módulos de dominio y acceso a datos. Los límites de dominio se mantienen mediante paquetes internos, no mediante servicios distribuidos.

## Consecuencias

### Positivas
- Despliegue simple: un binario para la API, otro para el worker.
- Transacciones locales sin coordinación distribuida.
- Refactoring más sencillo mientras se descubren los límites de dominio.
- Menor complejidad operativa (no se requiere service mesh, discovery, etc.).

### Negativas
- Escalado horizontal limitado al proceso completo (aceptable para el MVP).
- Necesidad de disciplina en los límites de paquetes para evitar acoplamiento.

## Alternativas consideradas
- **Microservicios**: descartado por complejidad operativa prematura.
- **Monolito sin worker**: descartado porque las tareas asíncronas (outbox, automatizaciones, correo) requieren un proceso separado para no bloquear peticiones HTTP.
