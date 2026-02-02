require("core.java-helpers").generate_class_template()

local ok, jdtls = pcall(require, "jdtls")
if not ok then
    vim.notify("nvim-jdtls not installed", vim.log.levels.WARN)
    return
end

local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"

if vim.fn.isdirectory(jdtls_path) == 0 then
    vim.notify("jdtls not installed via Mason. Run :Mason and install jdtls", vim.log.levels.WARN)
    return
end

local system_os = "linux"
if vim.fn.has("mac") == 1 then
    system_os = "mac"
elseif vim.fn.has("win32") == 1 then
    system_os = "win"
end

local config_dir = jdtls_path .. "/config_" .. system_os
local plugins_dir = jdtls_path .. "/plugins/"
local launcher_jar = vim.fn.glob(plugins_dir .. "org.eclipse.equinox.launcher_*.jar")

if launcher_jar == "" then
    vim.notify("jdtls launcher jar not found. Reinstall jdtls via :Mason", vim.log.levels.ERROR)
    return
end

local lombok_path = "/usr/share/java/lombok/lombok.jar"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

local bundles = {}
local java_debug_path = vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter"
local java_test_path = vim.fn.stdpath("data") .. "/mason/packages/java-test"

if vim.fn.isdirectory(java_debug_path) == 1 then
    local java_debug_jar = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
    if java_debug_jar ~= "" then
        table.insert(bundles, java_debug_jar)
    end
end

if vim.fn.isdirectory(java_test_path) == 1 then
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n"))
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local config = {
    name = "jdtls",
    cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-javaagent:" .. lombok_path,
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", launcher_jar,
        "-configuration", config_dir,
        "-data", workspace_dir,
    },

    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),

    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    {
                        name = "JavaSE-25",
                        path = "/usr/lib/jvm/java-25-openjdk/",
                        default = true,
                    },
                },
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            format = {
                enabled = true,
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = {
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*",
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                useBlocks = true,
            },
            saveActions = {
                organizeImports = {
                    enabled = true
                }
            },

        },
    },

    flags = {
        allow_incremental_sync = true,
    },

    capabilities = capabilities,

    init_options = {
        bundles = bundles,
        extendedClientCapabilities = extendedClientCapabilities,
    },

    on_attach = function(client, bufnr)
        jdtls.setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()

        local opts = { buffer = bufnr, silent = true }

        vim.keymap.set("n", "ga", jdtls.organize_imports, opts)
    end,
}


jdtls.start_or_attach(config)

