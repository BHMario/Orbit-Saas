# Modelo de amenazas — Orbit

## Contexto

Orbit es una aplicación SaaS multi-tenant donde múltiples organizaciones comparten la misma infraestructura. La seguridad de los datos de cada organización es crítica.

---

## Amenazas prioritarias

### 1. Acceso a recursos de otra organización (IDOR multi-tenant)

**Descripción:** Un usuario autenticado cambia UUIDs en las peticiones para acceder a recursos de otra organización.

**Impacto:** Crítico — fuga de datos entre organizaciones.

**Controles:**
- Toda consulta filtra por `organization_id` validado contra la membresía del usuario.
- No se busca un recurso solo por su ID; siempre `organization_id + id`.
- Tests negativos explícitos en cada módulo.
- Respuesta `404` (no `403`) para evitar enumeración.

### 2. Escalada de permisos

**Descripción:** Un usuario envía un rol superior en el payload para auto-asignarse permisos.

**Impacto:** Alto — acceso administrativo no autorizado.

**Controles:**
- El rol se valida en el servidor contra la membresía actual.
- Solo `owner`/`admin` pueden modificar roles, con restricciones.
- No se confía en datos del cliente para autorización.

### 3. Robo o reutilización de cookies/tokens

**Descripción:** Cookies de sesión interceptadas o tokens de invitación/reset reutilizados.

**Impacto:** Alto — suplantación de identidad.

**Controles:**
- Cookies: `HttpOnly`, `Secure` en producción, `SameSite=Lax`.
- Tokens de reset/invitación: un solo uso, caducidad, almacenados como hash.
- Sesiones invalidables desde el servidor.

### 4. CSRF en acciones autenticadas

**Descripción:** Un sitio malicioso induce al navegador a enviar peticiones autenticadas.

**Impacto:** Alto — mutaciones no autorizadas.

**Controles:**
- Token CSRF para operaciones mutables.
- Validación de `Origin`/`Referer`.
- `SameSite=Lax` en cookies.

### 5. XSS a través de Markdown (descripciones y comentarios)

**Descripción:** Inyección de scripts maliciosos a través de campos que aceptan Markdown.

**Impacto:** Alto — robo de sesión, exfiltración de datos.

**Controles:**
- Sanitización de HTML renderizado desde Markdown.
- Content Security Policy restrictiva.
- No renderizar HTML arbitrario del usuario.

### 6. Abuso de endpoints (brute force, enumeración)

**Descripción:** Ataques automatizados contra login, invitaciones, búsqueda y registro.

**Impacto:** Medio — compromiso de cuentas, denegación de servicio.

**Controles:**
- Rate limiting configurable por IP/cuenta en endpoints sensibles.
- Mensajes genéricos que no revelen si un correo está registrado.
- Registro de eventos de seguridad sin datos sensibles.

### 7. Duplicación de automatizaciones por reintentos

**Descripción:** Un evento se procesa múltiples veces, duplicando acciones no idempotentes.

**Impacto:** Alto — datos inconsistentes, notificaciones duplicadas.

**Controles:**
- Clave idempotente por evento/regla.
- `FOR UPDATE SKIP LOCKED` para reclamar trabajos.
- Límite de intentos y registro de estado.
- Prevención de bucles por profundidad/conteo.

### 8. Filtración de secretos

**Descripción:** Tokens, contraseñas o datos sensibles expuestos en logs, respuestas de error o repositorio.

**Impacto:** Crítico — compromiso total.

**Controles:**
- Logs estructurados sin datos sensibles.
- Errores públicos sin stack traces ni información interna.
- Secretos solo por variables de entorno.
- `.gitignore` para `.env` y similares.
- Secret scanning en CI cuando esté disponible.

### 9. WebSocket transmitiendo eventos no autorizados

**Descripción:** Un usuario recibe eventos de otra organización a través del WebSocket.

**Impacto:** Alto — fuga de información en tiempo real.

**Controles:**
- Autenticación de la conexión WebSocket.
- Validación de organización/permisos antes de suscribir.
- Cierre de conexiones inválidas.
- Eventos mínimos (tipo + ID), sin objetos completos sensibles.

### 10. Manipulación de estados e invariantes

**Descripción:** Envío de valores inválidos para estados, posiciones o fechas que rompen reglas de negocio.

**Impacto:** Medio — datos inconsistentes.

**Controles:**
- Validación de entrada con listas permitidas y restricciones `CHECK`.
- Transiciones de estado validadas en el servicio.
- Concurrencia optimista con campo `version`.

### 11. Dependencias vulnerables

**Descripción:** Bibliotecas con vulnerabilidades conocidas incluidas en el proyecto.

**Impacto:** Variable — desde bajo hasta crítico.

**Controles:**
- Escaneo de dependencias en CI.
- Actualización periódica y revisión.
- Evitar versiones sin mantenimiento activo.

---

## Controles transversales

| Control | Implementación |
| ------- | -------------- |
| Autorización centralizada | Middleware/helper de contexto de organización y rol |
| Tests negativos por rol | En cada módulo de dominio |
| Cookies seguras | `HttpOnly`, `Secure`, `SameSite` |
| Tokens de un solo uso | Hash almacenado, caducidad, usado/revocado |
| Validación de entrada | Límites de tamaño, listas permitidas, parametrización SQL |
| Sanitización de contenido | Markdown → HTML sanitizado contra XSS |
| CORS allowlist | Orígenes explícitos, no `*` |
| CSP y cabeceras | Cabeceras de seguridad razonables |
| Rate limiting | Configurable por endpoint |
| Logging seguro | `request_id`, sin datos sensibles |
| Auditoría | Cambios de permisos, invitaciones, configuración |

---

## Riesgos residuales aceptados para el MVP

1. **No se implementa SSO/SAML** — usuarios se autentican solo con correo/contraseña.
2. **No hay WAF dedicado** — la protección se basa en validación y rate limiting en la aplicación.
3. **No hay cifrado de campos en BD** — se depende del cifrado en tránsito (TLS) y en reposo del proveedor de hosting.
4. **No hay MFA** — se contempla para evolución futura.
5. **Rate limiting en memoria** — aceptable para instancias únicas; requiere solución distribuida si se escala horizontalmente.

---

## Plan de respuesta a incidentes (básico)

1. Identificar y contener la brecha.
2. Rotar secretos afectados.
3. Revisar logs de auditoría.
4. Notificar a usuarios afectados si corresponde.
5. Documentar causa raíz y acciones correctivas.
6. Actualizar controles y tests.
