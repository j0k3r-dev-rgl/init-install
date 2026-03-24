local function load_env_file(filepath)
  local env = vim.fn.environ()
  local f = io.open(filepath, "r")
  if f then
    for line in f:lines() do
      if not line:match("^%s*#") and not line:match("^%s*$") and line:match("=") then
        local key, value = line:match("^%s*([^=]+)%s*=%s*(.*)")
        if key and value then
          key   = key:gsub("%s+", "")
          value = value:match('^"(.*)"$') or value:match("^'(.*)'$") or value
          value = value:gsub("^%s+", ""):gsub("%s+$", "")
          env[key] = value
        end
      end
    end
    f:close()
  end
  return env
end

local PROJECTS = {
  back = {
    name    = "back: ArApplication (Spring Boot)",
    cwd     = "/home/j0k3r/sias/app/back",
    cmd     = "./mvnw",
    options = {
      { label = "Run",     args = { "spring-boot:run" },              env = true },
      { label = "Clean",   args = { "clean" },                        env = false },
      { label = "Install", args = { "clean", "install", "-DskipTests" }, env = false },
      { label = "Package", args = { "clean", "package", "-DskipTests" }, env = false },
      { label = "Test",    args = { "test" },                         env = false },
      { label = "Compile", args = { "compile" },                      env = false },
    },
  },
  back_files = {
    name    = "back_files: ImageService (Spring Boot)",
    cwd     = "/home/j0k3r/sias/app/back_files",
    cmd     = "./mvnw",
    options = {
      { label = "Run",     args = { "spring-boot:run" },              env = true },
      { label = "Clean",   args = { "clean" },                        env = false },
      { label = "Install", args = { "clean", "install", "-DskipTests" }, env = false },
      { label = "Package", args = { "clean", "package", "-DskipTests" }, env = false },
      { label = "Test",    args = { "test" },                         env = false },
      { label = "Compile", args = { "compile" },                      env = false },
    },
  },
  front = {
    name    = "front: React Router 7",
    cwd     = "/home/j0k3r/sias/app/front",
    cmd     = "bun",
    options = {
      { label = "Dev",       args = { "run", "dev" },       env = true },
      { label = "Build",     args = { "run", "build" },     env = true },
      { label = "Preview",   args = { "run", "start" },     env = true },
      { label = "Typecheck", args = { "run", "typecheck" }, env = false },
      { label = "Install",   args = { "install" },          env = false },
    },
  },
}

local function run_task(project_key, option)
  local overseer = require("overseer")
  local project  = PROJECTS[project_key]
  local env      = option.env and load_env_file(project.cwd .. "/.env") or vim.fn.environ()

  local task = overseer.new_task({
    name = project.name .. " - " .. option.label,
    cmd  = project.cmd,
    args = option.args,
    cwd  = project.cwd,
    env  = env,
    components = {
      { "on_exit_set_status" },
      { "on_complete_notify" },
      "default",
    },
  })

  task:start()
  overseer.open({ enter = false })
end

local function show_project_menu(project_key)
  local project = PROJECTS[project_key]
  local labels  = vim.tbl_map(function(o) return o.label end, project.options)

  vim.ui.select(labels, {
    prompt = project.name .. " - Selecciona tarea:",
  }, function(choice)
    if not choice then return end
    for _, option in ipairs(project.options) do
      if option.label == choice then
        run_task(project_key, option)
        return
      end
    end
  end)
end

local function show_main_menu()
  local projects = {
    "back     - ArApplication (Spring Boot)",
    "back_files - ImageService (Spring Boot)",
    "front    - React Router 7 (bun)",
  }
  vim.ui.select(projects, { prompt = "Selecciona proyecto:" }, function(choice)
    if not choice then return end
    if choice:match("^back_files") then
      show_project_menu("back_files")
    elseif choice:match("^back") then
      show_project_menu("back")
    elseif choice:match("^front") then
      show_project_menu("front")
    end
  end)
end

return {
  "stevearc/overseer.nvim",
  dependencies = { "folke/which-key.nvim" },
  cmd  = { "OverseerToggle", "OverseerOpen" },
  keys = {
    { "<leader>mm", show_main_menu,                            desc = "Menu principal" },
    { "<leader>mj", function() show_project_menu("back") end,       desc = "Menu back" },
    { "<leader>mi", function() show_project_menu("back_files") end, desc = "Menu back_files" },
    { "<leader>mr", function() show_project_menu("front") end,      desc = "Menu front (React)" },
    { "<leader>mt", "<cmd>OverseerToggle<cr>",                 desc = "Panel de tareas" },
    { "<leader>ms", function()
        local tasks = require("overseer").list_tasks({ recent_first = true })
        if tasks[1] then require("overseer").run_action(tasks[1], "stop")
        else vim.notify("No hay tareas activas", vim.log.levels.WARN) end
      end, desc = "Detener tarea activa" },
    { "<leader>mc", function()
        for _, task in ipairs(require("overseer").list_tasks()) do
          if task.status == "SUCCESS" or task.status == "FAILURE" then
            task:dispose()
          end
        end
        vim.notify("Tareas limpiadas", vim.log.levels.INFO)
      end, desc = "Limpiar tareas" },
  },
  config = function()
    require("overseer").setup({
      templates = { "builtin" },
      strategy = {
        "terminal",
        direction    = "horizontal",
        quit_on_exit = "never",
      },
      task_list = {
        direction      = "bottom",
        min_height     = 15,
        max_height     = 20,
        default_detail = 1,
        bindings = {
          ["<CR>"] = "RunAction",
          ["o"]    = "OpenOutput",
          ["q"]    = "Close",
          ["s"]    = "Stop",
          ["r"]    = "Restart",
        },
      },
    })

    require("which-key").add({
      { "<leader>m", group = "Lanzador / Servicios" },
    })
  end,
}
