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

vim.api.nvim_create_user_command("JavaGenerateLombokConfig", function()
    M.generate_lombok_config()
end, { desc = "Generate lombok.config for jdtls workspace" })

vim.api.nvim_create_user_command("JavaSetupLombok", function()
    M.setup_lombok_for_current_project()
end, { desc = "Generate lombok.config in project root" })

return M
