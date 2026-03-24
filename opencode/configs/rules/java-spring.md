---
alwaysApply: true
---

## Arquitectura Modular — Aplicación e Infraestructura

### Estructura de un Módulo

```
modules/[nombre]/
├── application/
│   ├── ports/
│   │   ├── input/           # Interfaces hacia el exterior (casos de uso)
│   │   │   ├── Edit*.java   # Interfaces para operaciones de edición
│   │   │   ├── Get*.java    # Interfaces para operaciones de lectura
│   │   │   └── Root*.java   # Interfaces específicas de Root/admin
│   │   └── output/          # Interfaces hacia servicios externos
│   │       └── *Repository.java
│   └── use_cases/
│       ├── command/          # Casos de uso que modifican estado
│       │   └── *UseCase.java
│       └── query/           # Casos de uso que solo leen
│           └── *UseCase.java
│
└── infrastructure/
    ├── persistence/
    │   ├── dao/             # Implementaciones de puertos output
    │   │   └── *Adapter.java
    │   ├── dto/             # DTOs de infraestructura
    │   │   ├── *Request.java
    │   │   └── *Response.java
    │   └── models/          # Modelos de persistencia (MongoDB)
    │       └── *Model.java
    ├── web/
    │   ├── graphql/
    │   │   ├── filters/
    │   │   └── *Controller.java
    │   ├── http/
    │   │   ├── request/
    │   │   └── response/
    │   └── rest/
    │       └── *Controller.java
    └── [Nombre]Mapper.java   # Mapper general del módulo
```

### Convenciones de Nombres

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| Puerto input (lectura) | `Get*` | `GetMyUser.java`, `GetUserByLogin.java` |
| Puerto input (edición) | `Edit*` | `EditMyData.java`, `EditMyPassword.java` |
| Puerto input (root) | `Root*` | `RootCreateUser.java`, `RootEditUser.java` |
| Puerto output | `*Repository` | `GetUserRepository.java` |
| Use case command | `*UseCase` | `EditMyDataUseCase.java` |
| Use case query | `*UseCase` | `GetMyUserUseCase.java` |
| Adaptador DAO | `*Adapter` | `GetUserAdapter.java` |
| DTO request | `*Request` | `CreateUserRequest.java` |
| DTO response | `*Response` | `UserResponseDto.java` |
| Modelo persistence | `*Model` | `UserPersistenceModel.java` |
| Mapper | `[Nombre]Mapper` | `UserMapper.java` |

### Patrón de Agrupación por Acción

Seguir este patron para agrupar operaciones:

- **`Get*`**: Solo lectura
- **`Edit*`**: Modificación de datos existentes
- **`Root*`**: Operaciones de administrador (crear, editar, eliminar usuarios root)
- **`Create*`**: Solo dentro de Root (nuevos registros)

### Ejemplo de Flujo

```
1. Request entra por web (Controller)
   ↓
2. Controller llama a puerto input (interface en application/ports/input)
   ↓
3. UseCase implementa el puerto input
   ↓
4. UseCase usa puerto output (interface en application/ports/output)
   ↓
5. Adapter (en infrastructure/persistence/dao) implementa el puerto output y toda la lógica de persistencia
```

### Reglas del Módulo

1. **application solo conoce a application**: no importar de infrastructure
2. **Infrastructure implementa los puertos de application**
3. **Los DTOs viven en infrastructure**: los Controllers/web construyen los request/response
4. **El Mapper es general del módulo**: mappea entre dominio y DTOs/persistence models

### Lo que VA y lo que NO VA

✅ **VA en application**:
- Interfaces de puertos (input y output)
- Casos de uso (command y query)
- Lógica de orquestación

❌ **NO VA en application**:
- Implementaciones concretas
- Anotaciones Spring (`@Service`, `@Repository`)
- Referencias a MongoDB o bases de datos

✅ **VA en infrastructure**:
- Adaptadores que implementan puertos output
- Controllers web (REST, GraphQL)
- DTOs, modelos de persistencia
- Mappers

❌ **NO VA en infrastructure**:
- Lógica de negocio (va en application)
