return {
    {
        "saghen/blink.cmp",
        version = "*", -- Usa la última versión estable (requerido para descargas de binarios pre-compilados)
        dependencies = {
            "rafamadriz/friendly-snippets", -- Snippets estándar
            { "saghen/blink.compat", opts = {} }, -- Capa de compatibilidad para fuentes de nvim-cmp
        },
        opts = {
            keymap = {
                preset = "default",
                -- Mapeo explícito para Ctrl+Space: Mostrar menú y documentación
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
            },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },

            sources = {
                -- Fuentes habilitadas: LSP (imports), Codeium (IA), Snippets, Buffer, Path
                default = { "lsp", "codeium", "snippets", "buffer", "path" },
                providers = {
                    -- Configuración específica para Codeium usando blink.compat
                    codeium = {
                        name = "codeium",
                        module = "blink.compat.source",
                        score_offset = 100, -- Prioridad ajustada
                    },
                },
            },

            -- Configuración crítica para comportamiento de lista y documentación
            completion = {
                documentation = { 
                    auto_show = true, 
                    auto_show_delay_ms = 200 
                },
                list = {
                    -- 'auto_insert' es clave para que los imports funcionen al seleccionar
                    selection = { preselect = false, auto_insert = true }
                },
                menu = {
                    draw = {
                        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
                    },
                },
            },

            -- Habilita ayuda de firma de función (parámetros) mientras escribes
            signature = { enabled = true },
        },
        -- Necesario para extender la lista de fuentes correctamente
        opts_extend = { "sources.default" },
    },
}