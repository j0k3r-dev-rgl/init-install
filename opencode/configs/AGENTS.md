## Stack Tecnológico

- **Backend**: Java 25, Spring Boot 7, Spring 4
- **Frontend**: React con React Router 7
- **Base de Datos**: MongoDB
- **Arquitectura**: Puertos y Adaptadores (Hexagonal)
- **Patrones**: Programación orientada a interfaces con inyección de dependencias de Spring

## Protocolo de Memoria — Engram

### Cuándo Guardar (mandatorio)

Guardar con `mem_save` INMEDIATAMENTE después de:
- Bug fix completado
- Decisión de arquitectura o diseño
- Descubrimiento no obvio sobre el codebase
- Cambio de configuración o entorno
- Patrón establecido (naming, estructura, convención)
- Preferencia o restricción del usuario aprendida

Formato para `mem_save`:
- **title**: Verbo + qué — corto, buscable (ej: "Fixed N+1 query in UserList", "Chose Zustand over Redux")
- **type**: bugfix | decision | architecture | discovery | pattern | config | preference
- **scope**: `project` (default) | `personal`
- **topic_key** (opcional, recomendado para decisiones evolutivas): key estable como `architecture/auth-model`
- **content**:
  **What**: Una oración — qué se hizo
  **Why**: Qué lo motivó (request del usuario, bug, performance, etc.)
  **Where**: Archivos o paths afectados
  **Learned**: Gotchas, edge cases, cosas que sorprendieron (omitir si none)

Reglas de topic:
- Diferentes topics no deben sobrescribirse entre sí
- Reusar el mismo `topic_key` para actualizar un topic evolutivo
- Si no estás seguro del key, llamar a `mem_suggest_topic_key` primero
- Usar `mem_update` cuando tenés el ID exacto de observación para corregir

### Cuándo Buscar Memoria

Cuando el usuario pregunta recordar algo — cualquier variación de "remember", "recall", "qué hicimos", o referencias a trabajo pasado:
1. Primero llamar a `mem_context` — verifica historial de sesión reciente (rápido, barato)
2. Si no se encuentra, llamar a `mem_search` con keywords relevantes (FTS5 full-text search)
3. Si encontrás un match, usar `mem_get_observation` para el contenido completo

También buscar memoria PROACTIVAMENTE cuando:
- Empezás a trabajar en algo que pudo haber sido hecho antes
- El usuario menciona un topic sin contexto — verificar si sesiones pasadas lo cubrieron
- El primer mensaje del usuario referencia el proyecto, feature, o problema — llamar `mem_search` con keywords

### Protocolo de Cierre de Sesión (mandatorio)

Antes de terminar una sesión o decir "done" / "listo" / "that's it", DEVES:
1. Llamar a `mem_session_summary` con esta estructura:

## Goal
[Qué estuvimos trabajando en esta sesión]

## Instructions
[Preferencias o restricciones descubiertas — omitir si none]

## Discoveries
- [Hallazgos técnicos, gotchas, aprendizajes no obvios]

## Accomplished
- [Items completados con detalles clave]

## Next Steps
- [Qué queda por hacer — para la próxima sesión]

## Relevant Files
- path/to/file — [qué hace o qué cambió]

Esto NO es opcional. Si lo saltás, la próxima sesión empieza a ciegas.

### Después de Compaction

Si ves un mensaje sobre compaction o reset de contexto:
1. LLAMAR INMEDIATAMENTE a `mem_session_summary` con el contenido del summary compactado
2. Luego llamar a `mem_context` para recuperar contexto adicional de sesiones previas
3. Solo DESPUÉS continuar trabajando

No saltees el paso 1. Sin esto, todo lo hecho antes de compaction se pierde.

## Reglas de Operación

- Cada proyecto tiene su propio AGENTS.md específico con contexto del proyecto
- Antes de implementar: verificar contexto con AGENTS.md del proyecto
- Si falta información: PREGUNTAR al usuario, nunca asumir
- Si hay inconsistencias: PREGUNTAR al usuario antes de actuar
