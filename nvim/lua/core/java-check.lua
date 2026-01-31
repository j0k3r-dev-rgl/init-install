local M = {}

function M.check_jdtls_installation()
  local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
  local issues = {}
  
  vim.notify("Checking jdtls installation...", vim.log.levels.INFO)
  
  if vim.fn.isdirectory(jdtls_path) == 0 then
    table.insert(issues, "❌ jdtls directory not found at: " .. jdtls_path)
    table.insert(issues, "   Run :Mason and install jdtls")
  else
    vim.notify("✓ jdtls directory found", vim.log.levels.INFO)
    
    local system_os = "linux"
    if vim.fn.has("mac") == 1 then
      system_os = "mac"
    elseif vim.fn.has("win32") == 1 then
      system_os = "win"
    end
    
    local config_dir = jdtls_path .. "/config_" .. system_os
    if vim.fn.isdirectory(config_dir) == 0 then
      table.insert(issues, "❌ Config directory not found: " .. config_dir)
    else
      vim.notify("✓ Config directory found", vim.log.levels.INFO)
    end
    
    local plugins_dir = jdtls_path .. "/plugins/"
    if vim.fn.isdirectory(plugins_dir) == 0 then
      table.insert(issues, "❌ Plugins directory not found: " .. plugins_dir)
    else
      vim.notify("✓ Plugins directory found", vim.log.levels.INFO)
      
      local launcher_jar = vim.fn.glob(plugins_dir .. "org.eclipse.equinox.launcher_*.jar")
      if launcher_jar == "" then
        table.insert(issues, "❌ Launcher JAR not found in: " .. plugins_dir)
      else
        vim.notify("✓ Launcher JAR found: " .. launcher_jar, vim.log.levels.INFO)
      end
    end
    
    local lombok_jar = "/usr/share/java/lombok/lombok.jar"
    if vim.fn.filereadable(lombok_jar) == 0 then
      table.insert(issues, "⚠️  Lombok JAR not found: " .. lombok_jar)
      table.insert(issues, "   Lombok support may not work")
    else
      vim.notify("✓ Lombok JAR found", vim.log.levels.INFO)
    end
  end
  
  local java_debug_path = vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter"
  if vim.fn.isdirectory(java_debug_path) == 0 then
    table.insert(issues, "⚠️  java-debug-adapter not installed (optional for debugging)")
  else
    vim.notify("✓ java-debug-adapter found", vim.log.levels.INFO)
  end
  
  local java_test_path = vim.fn.stdpath("data") .. "/mason/packages/java-test"
  if vim.fn.isdirectory(java_test_path) == 0 then
    table.insert(issues, "⚠️  java-test not installed (optional for running tests)")
  else
    vim.notify("✓ java-test found", vim.log.levels.INFO)
  end
  
  if #issues > 0 then
    vim.notify("\n" .. table.concat(issues, "\n"), vim.log.levels.WARN)
    return false
  else
    vim.notify("\n✅ All jdtls components are installed correctly!", vim.log.levels.INFO)
    return true
  end
end

vim.api.nvim_create_user_command("JavaCheckInstallation", function()
  M.check_jdtls_installation()
end, { desc = "Check jdtls installation status" })

return M
