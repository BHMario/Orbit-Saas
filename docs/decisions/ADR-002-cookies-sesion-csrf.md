# ADR-002: Cookies de sesión y CSRF

## Estado
Aceptada

## Fecha
2026-10-26

## Contexto
La aplicación necesita autenticación persistente para una SPA que se comunica con una API en el mismo dominio (o subdominio). Las opciones principales son JWT almacenado en el navegador o sesiones de servidor con cookies.

## Decisión
Adoptamos **sesiones de servidor con cookies seguras**:
- Cookie con flags `HttpOnly`, `Secure` (en producción) y `SameSite=Lax`.
- Token de sesión almacenado como hash en la tabla `sessions`.
- Protección CSRF mediante token y validación de `Origin`/`Referer` en operaciones mutables.
- Expiración configurable y renovable.

## Consecuencias

### Positivas
- El token de sesión no es accesible desde JavaScript, reduciendo el impacto de XSS.
- Sesiones invalidables inmediatamente desde el servidor.
- No se requiere lógica de refresh token en el frontend.
- CSRF mitigable con patrones bien conocidos.

### Negativas
- Requiere almacenamiento en servidor (tabla `sessions`).
- Necesita limpieza periódica de sesiones expiradas.
- CSRF requiere implementación activa.

## Alternativas consideradas
- **JWT en localStorage:** descartado por exposición a XSS y dificultad de invalidación inmediata.
- **JWT en cookie HttpOnly:** viable pero añade complejidad de refresh sin beneficio claro para un monolito.
