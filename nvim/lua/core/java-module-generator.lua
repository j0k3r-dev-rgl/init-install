local M = {}

function M.create_java_module()
    -- 1. Prompt for module name
    local module_name_input = vim.fn.input("Enter module name (e.g., users): ")
    if not module_name_input or module_name_input:gsub("%s+", "") == "" then
        vim.notify("Module name cannot be empty. Aborting.", vim.log.levels.WARN)
        return
    end

    -- Normalize names
    -- Package/Dir name: lowercase (e.g., "users")
    local lower_module_name = module_name_input:lower()
    -- Class prefix: Capitalized (e.g., "Users")
    local capitalized_module_name = lower_module_name:sub(1, 1):upper() .. lower_module_name:sub(2)

    -- Base path relative to project root
    local base_path = "src/main/java/com/sistemasias/ar/modules/" .. lower_module_name .. "/"

    -- Base package declaration prefix (Note: "package " keyword added)
    local base_package = "package com.sistemasias.ar.modules." .. lower_module_name

    local directories = {
        "domain/entities",
        "domain/value_objects",
        "domain/repositories",
        "domain/services",
        "domain/exceptions",
        "application/use_cases/command",
        "application/use_cases/query",
        "application/ports/input",
        "application/ports/output",
        "application/dto",
        "infrastructure/persistence/models",
        "infrastructure/persistence/repositories",
        "infrastructure/persistence/mappers",
        "infrastructure/web/graphql",
        "infrastructure/web/graphql/mappers",
        "infrastructure/web/rest",
        "infrastructure/web/rest/mappers",
        "infrastructure/security",
    }

    local files = {
        -- Domain
        ["domain/entities/" .. capitalized_module_name .. ".java"] =
            base_package ..
            ".domain.entities;\n\npublic class " ..
            capitalized_module_name .. " {\n    \n}\n",

        ["domain/repositories/" .. capitalized_module_name .. "Repository.java"] =
            base_package ..
            ".domain.repositories;\n\npublic interface " ..
            capitalized_module_name .. "Repository {\n    \n}\n",

        ["domain/services/" .. capitalized_module_name .. "DomainService.java"] =
            base_package ..
            ".domain.services;\n\npublic class " ..
            capitalized_module_name .. "DomainService {\n    \n}\n",

        -- Application Use Cases Command
        ["application/use_cases/command/Create" .. capitalized_module_name .. "UseCase.java"] =
            base_package ..
            ".application.use_cases.command;\n\npublic class Create" ..
            capitalized_module_name ..
            "UseCase {\n   \n}\n",

        ["application/use_cases/command/Update" .. capitalized_module_name .. "UseCase.java"] =
            base_package ..
            ".application.use_cases.command;\n\npublic class Update" ..
            capitalized_module_name ..
            "UseCase {\n   \n}\n",

        ["application/use_cases/command/Delete" .. capitalized_module_name .. "UseCase.java"] =
            base_package ..
            ".application.use_cases.command;\n\npublic class Delete" ..
            capitalized_module_name ..
            "UseCase {\n   \n}\n",

        -- Application Use Cases Query
        ["application/use_cases/query/Get" .. capitalized_module_name .. "ByIdUseCase.java"] =
            base_package ..
            ".application.use_cases.query;\n\npublic class Get" ..
            capitalized_module_name ..
            "ByIdUseCase {\n \n}\n",

        ["application/use_cases/query/Get" .. capitalized_module_name .. "sByDependencyUseCase.java"] =
            base_package ..
            ".application.use_cases.query;\n\npublic class Get" ..
            capitalized_module_name ..
            "sByDependencyUseCase {\n   \n}\n",

        ["application/use_cases/query/GetMyData" .. capitalized_module_name .. "UseCase.java"] =
            base_package ..
            ".application.use_cases.query;\n\npublic class GetMyData" ..
            capitalized_module_name ..
            "UseCase {\n    \n}\n",

        -- Application Ports Input
        ["application/ports/input/Get" .. capitalized_module_name .. "ByIdPort.java"] =
            base_package ..
            ".application.ports.input;\n\npublic interface Get" ..
            capitalized_module_name ..
            "ByIdPort {\n    \n}\n",

        ["application/ports/input/Create" .. capitalized_module_name .. "Port.java"] =
            base_package ..
            ".application.ports.input;\n\npublic interface Create" ..
            capitalized_module_name ..
            "Port {\n    \n}\n",

        -- Application Ports Output
        ["application/ports/output/" .. capitalized_module_name .. "RepositoryPort.java"] =
            base_package ..
            ".application.ports.output;\n\npublic interface " ..
            capitalized_module_name ..
            "RepositoryPort {\n    \n}\n",

        ["application/ports/output/EmailServicePort.java"] =
            base_package ..
            ".application.ports.output;\n\npublic interface EmailServicePort {\n    \n}\n",

        ["application/ports/output/JwtServicePort.java"] =
            base_package ..
            ".application.ports.output;\n\npublic interface JwtServicePort {\n   \n}\n",

        -- Application DTO
        ["application/dto/Create" .. capitalized_module_name .. "Command.java"] =
            base_package ..
            ".application.dto;\n\npublic class Create" ..
            capitalized_module_name .. "Command {\n    \n}\n",

        ["application/dto/" .. capitalized_module_name .. "Query.java"] =
            base_package ..
            ".application.dto;\n\npublic class " ..
            capitalized_module_name .. "Query {\n    \n}\n",

        -- Infrastructure Persistence
        ["infrastructure/persistence/models/" .. capitalized_module_name .. "PersistenceModel.java"] =
            base_package ..
            ".infrastructure.persistence.models;\n\npublic class " ..
            capitalized_module_name .. "PersistenceModel {\n    \n}\n",

        ["infrastructure/persistence/repositories/SpringData" .. capitalized_module_name .. "Repository.java"] =
            base_package ..
            ".infrastructure.persistence.repositories;\n\npublic interface SpringData" ..
            capitalized_module_name .. "Repository {\n    \n}\n",

        ["infrastructure/persistence/repositories/Mongo" .. capitalized_module_name .. "RepositoryAdapter.java"] =
            base_package .. ".infrastructure.persistence.repositories;\n\n" ..
            "import " ..
            base_package:gsub("package ", "") ..
            ".domain.repositories." .. capitalized_module_name .. "Repository;\n\n" ..
            "public class Mongo" ..
            capitalized_module_name ..
            "RepositoryAdapter implements " ..
            capitalized_module_name ..
            "Repository {\n    \n}\n",

        ["infrastructure/persistence/mappers/" .. capitalized_module_name .. "PersistenceMapper.java"] =
            base_package ..
            ".infrastructure.persistence.mappers;\n\npublic class " ..
            capitalized_module_name .. "PersistenceMapper {\n    \n}\n",

        -- Infrastructure Web GraphQL
        ["infrastructure/web/graphql/" .. capitalized_module_name .. "GraphQLController.java"] =
            base_package ..
            ".infrastructure.web.graphql;\n\npublic class " ..
            capitalized_module_name .. "GraphQLController {\n    \n}\n",

        ["infrastructure/web/graphql/mappers/" .. capitalized_module_name .. "GraphQLMapper.java"] =
            base_package ..
            ".infrastructure.web.graphql.mappers;\n\npublic class " ..
            capitalized_module_name .. "GraphQLMapper {\n    \n}\n",

        -- Infrastructure Web REST
        ["infrastructure/web/rest/" .. capitalized_module_name .. "RestController.java"] =
            base_package ..
            ".infrastructure.web.rest;\n\npublic class " ..
            capitalized_module_name .. "RestController {\n    \n}\n",

        ["infrastructure/web/rest/mappers/" .. capitalized_module_name .. "RestMapper.java"] =
            base_package ..
            ".infrastructure.web.rest.mappers;\n\npublic class " ..
            capitalized_module_name .. "RestMapper {\n    \n}\n",

        -- Infrastructure Security
        ["infrastructure/security/JwtServiceAdapter.java"] =
            base_package ..
            ".infrastructure.security;\n\npublic class JwtServiceAdapter {\n    \n}\n",
    }

    vim.notify("Creating Java module structure for: " .. capitalized_module_name .. " at " .. base_path,
        vim.log.levels.INFO)

    -- Create directories
    for _, dir in ipairs(directories) do
        local full_path = base_path .. dir
        -- Use vim.fn.mkdir for better portability and safety
        local ok = pcall(vim.fn.mkdir, full_path, "p")
        if not ok then
            vim.notify("Failed to create directory: " .. full_path, vim.log.levels.ERROR)
            return
        end
    end

    -- Create files with content
    for file_relative_path, content in pairs(files) do
        local full_path = base_path .. file_relative_path
        local f = io.open(full_path, "w")
        if f then
            f:write(content)
            f:close()
        else
            vim.notify("Failed to create file: " .. full_path, vim.log.levels.ERROR)
            return
        end
    end

    vim.notify("Java module '" .. capitalized_module_name .. "' created successfully!", vim.log.levels.INFO)
end

return M
