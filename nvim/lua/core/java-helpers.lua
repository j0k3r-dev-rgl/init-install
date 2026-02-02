local M = {}

function M.generate_lombok_config()
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace"
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local project_workspace = workspace_dir .. "/" .. project_name

    if vim.fn.isdirectory(project_workspace) == 0 then
        vim.fn.mkdir(project_workspace, "p")
    end

    local lombok_jar = "/usr/share/java/lombok/lombok.jar"

    if vim.fn.filereadable(lombok_jar) == 0 then
        vim.notify("Lombok JAR not found at " .. lombok_jar, vim.log.levels.ERROR)
        return
    end

    local lombok_config_path = project_workspace .. "/lombok.config"

    local cmd = string.format(
        "java -jar %s config -g --verbose > %s",
        lombok_jar,
        lombok_config_path
    )

    vim.fn.system(cmd)

    if vim.v.shell_error == 0 then
        vim.notify("Lombok config generated at: " .. lombok_config_path, vim.log.levels.INFO)
    else
        vim.notify("Failed to generate lombok.config", vim.log.levels.ERROR)
    end
end

function M.setup_lombok_for_current_project()
    local root_dir = vim.fn.getcwd()
    local lombok_config = root_dir .. "/lombok.config"

    if vim.fn.filereadable(lombok_config) == 1 then
        vim.notify("lombok.config already exists in project root", vim.log.levels.INFO)
        return
    end

    local lombok_jar = "/usr/share/java/lombok/lombok.jar"

    if vim.fn.filereadable(lombok_jar) == 0 then
        vim.notify("Lombok JAR not found at " .. lombok_jar, vim.log.levels.WARN)
        return
    end

    local cmd = string.format("java -jar %s config -g --verbose > %s", lombok_jar, lombok_config)

    vim.fn.system(cmd)

    if vim.v.shell_error == 0 then
        vim.notify("✓ lombok.config created in project root", vim.log.levels.INFO)
    else
        vim.notify("Failed to generate lombok.config", vim.log.levels.ERROR)
    end
end

function M.generate_class_template()
    -- Check if buffer is empty
    if vim.fn.line('$') > 1 or vim.fn.getline(1) ~= "" then
        return
    end

    local filename = vim.fn.expand("%:t:r")
    local file_path = vim.fn.expand("%:p:h")

    -- Try to detect package
    local package_name = ""
    
    -- Heuristic: look for src/main/java or src/test/java in the path
    local patterns = { "src/main/java/", "src/test/java/", "src/" }
    for _, pattern in ipairs(patterns) do
        local start_pos, end_pos = string.find(file_path, pattern, 1, true)
        if end_pos then
             local sub = string.sub(file_path, end_pos + 1)
             package_name = string.gsub(sub, "/", ".")
             break
        end
    end

    local type_options = { "class", "interface", "enum", "record", "annotation", "abstract class" }
    
    vim.schedule(function()
        vim.ui.select(type_options, {
            prompt = "Select Java type for " .. filename .. ":",
            format_item = function(item) return item end
        }, function(choice)
            if not choice then return end
            
            local content = {}
            if package_name ~= "" then
                table.insert(content, "package " .. package_name .. ";")
                table.insert(content, "")
            end
            
            local type_decl = choice
            local suffix = ""
            if choice == "annotation" then
                type_decl = "@interface"
            elseif choice == "record" then
                suffix = "()"
            end
            
            table.insert(content, "public " .. type_decl .. " " .. filename .. suffix .. " {")
            table.insert(content, "    ")
            table.insert(content, "}")
            
            vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
            
            -- Set cursor position
            local row = #content - 1
            vim.api.nvim_win_set_cursor(0, {row, 4})
        end)
    end)
end

vim.api.nvim_create_user_command("JavaGenerateLombokConfig", function()
    M.generate_lombok_config()
end, { desc = "Generate lombok.config for jdtls workspace" })

vim.api.nvim_create_user_command("JavaSetupLombok", function()
    M.setup_lombok_for_current_project()
end, { desc = "Generate lombok.config in project root" })

return M
