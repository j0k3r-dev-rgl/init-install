-- Configuracion de jdtls para Java 26
-- Se ejecuta automaticamente al abrir cualquier archivo .java

local jdtls = require("jdtls")
local mason_path = vim.fn.stdpath("data") .. "/mason"

-- Path al jdtls instalado por Mason
local jdtls_path = mason_path .. "/packages/jdtls"
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- Detectar OS para config path
local config_dir
if vim.fn.has("mac") == 1 then
  config_dir = jdtls_path .. "/config_mac"
elseif vim.fn.has("win32") == 1 then
  config_dir = jdtls_path .. "/config_win"
else
  config_dir = jdtls_path .. "/config_linux"
end

-- Workspace separado por proyecto para evitar conflictos
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- Detectar Java instalado en el sistema
local java_home = os.getenv("JAVA_HOME") or "/usr/lib/jvm/java-26-openjdk"
local java_bin = java_home .. "/bin/java"

-- Fallback: buscar java en PATH
if vim.fn.executable(java_bin) == 0 then
  java_bin = "java"
end

-- Lombok jar (incluido en el paquete jdtls de Mason)
local lombok_jar = jdtls_path .. "/lombok.jar"

local config = {
  name = "jdtls",

  cmd = {
    java_bin,
    "-javaagent:" .. lombok_jar,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "-Xmx4g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher_jar,
    "-configuration", config_dir,
    "-data", workspace_dir,
  },

  root_dir = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" }),

  settings = {
    java = {
      -- Soporte Java 25 (version preview si es necesario)
      configuration = {
        runtimes = {
          {
            name = "JavaSE-26",
            path = java_home,
            default = true,
          },
        },
        updateBuildConfiguration = "automatic",
      },

      -- Compilacion con Java 25
      compile = {
        nullAnalysis = { mode = "automatic" },
      },

      -- Hints inline
      inlayHints = {
        parameterNames = { enabled = "all" },
      },

      -- Completado
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.Assume.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
        },
        importOrder = {
          "java",
          "javax",
          "jakarta",
          "org",
          "com",
        },
        filteredTypes = {
          "com.sun.*",
          "sun.*",
          "jdk.*",
        },
      },

      -- Formato
      format = {
        enabled = true,
        settings = {
          url = "",
          profile = "",
        },
      },

      -- Maven y Gradle
      maven = { downloadSources = true },
      gradle = { enabled = true },

      -- Referencias y codigo
      references = { includeDecompiledSources = true },
      contentProvider = { preferred = "fernflower" },

      -- Sources
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },

      -- Firma de metodos
      signatureHelp = { enabled = true },

      -- Implementaciones
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = false },
    },
  },

  init_options = {
    bundles = {},
  },

  on_attach = function(client, bufnr)
    -- Keymaps generales de LSP
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Ir a definicion")
    map("n", "gD", vim.lsp.buf.declaration, "Ir a declaracion")
    map("n", "gr", vim.lsp.buf.references, "Referencias")
    map("n", "gi", vim.lsp.buf.implementation, "Implementacion")
    map("n", "K", vim.lsp.buf.hover, "Documentacion")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Renombrar")
    map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Formatear")
    map("n", "[d", vim.diagnostic.goto_prev, "Diagnostico anterior")
    map("n", "]d", vim.diagnostic.goto_next, "Diagnostico siguiente")

    -- Keymaps especificos de Java
    map("n", "<leader>jd", vim.lsp.buf.definition,                              "Ir a definicion")
    map("n", "<leader>ji", vim.lsp.buf.implementation,                          "Ir a implementacion")
    map("n", "<leader>ju", function()
      require("telescope.builtin").lsp_references({ show_line = true, include_declaration = false })
    end, "Ver usos")
    map("n", "<leader>jo", function() require("jdtls").organize_imports() end,  "Organizar imports")
    map("n", "<leader>jv", function() require("jdtls").extract_variable() end,  "Extraer variable")
    map("v", "<leader>jv", function() require("jdtls").extract_variable(true) end, "Extraer variable")
    map("n", "<leader>jc", function() require("jdtls").extract_constant() end,  "Extraer constante")
    map("v", "<leader>jm", function() require("jdtls").extract_method(true) end,"Extraer metodo")
    map("n", "<leader>jr", "<cmd>JdtSetRuntime<cr>",                            "Cambiar runtime Java")

    -- Activar DAP solo cuando jdtls termine de indexar el proyecto
    jdtls.setup_dap({ hotcodereplace = "auto" })

    vim.api.nvim_create_autocmd("User", {
      pattern = "JdtlsReady",
      once = true,
      callback = function()
        require("jdtls.dap").setup_dap_main_class_configs()
      end,
    })
  end,
}

-- Iniciar o re-attach el servidor
jdtls.start_or_attach(config)
