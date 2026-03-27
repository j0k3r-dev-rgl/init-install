return {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
        require("tokyonight").setup({
            style           = "night",
            transparent     = true,
            terminal_colors = true,
            styles = {
                comments    = { italic = true },
                keywords    = { italic = true },
                functions   = {},
                variables   = {},
                sidebars    = "transparent",
                floats      = "transparent",
            },
            sidebars        = { "nvim-tree", "toggleterm", "qf", "help" },
            dim_inactive    = false,
            lualine_bold    = true,
            on_highlights   = function(hl, c)

                -- =============================================
                -- TREESITTER
                -- =============================================

                -- Tipos
                hl["@type"]                     = { fg = c.yellow }
                hl["@type.builtin"]             = { fg = c.cyan }        -- void, int, boolean (Java)
                hl["@type.qualifier"]           = { fg = c.purple, italic = true } -- public/private como qualifier
                hl["@constructor"]              = { fg = c.yellow }

                -- Keywords
                hl["@keyword"]                  = { fg = c.purple, italic = true }
                hl["@keyword.import"]           = { fg = c.cyan,   italic = true }
                hl["@keyword.modifier"]         = { fg = c.purple, italic = true } -- public/private/static/final
                hl["@keyword.operator"]         = { fg = c.purple }                -- instanceof, typeof
                hl["@keyword.return"]           = { fg = c.red,    italic = true }
                hl["@keyword.exception"]        = { fg = c.red }                   -- throw/catch/finally

                -- Variables
                hl["@variable"]                 = { fg = c.fg }
                hl["@variable.builtin"]         = { fg = c.red }          -- this, self, super
                hl["@variable.member"]          = { fg = c.blue1 }        -- campos de clase
                hl["@property"]                 = { fg = c.blue1 }
                hl["@parameter"]                = { fg = c.orange }

                -- Funciones
                hl["@function"]                 = { fg = c.blue }
                hl["@function.builtin"]         = { fg = c.cyan }
                hl["@function.method"]          = { fg = c.blue }
                hl["@function.method.call"]     = { fg = c.blue }
                hl["@method"]                   = { fg = c.blue }
                hl["@method.call"]              = { fg = c.blue }

                -- Literales
                hl["@string"]                   = { fg = c.green }
                hl["@string.special.url"]       = { fg = c.cyan, underline = true }
                hl["@number"]                   = { fg = c.orange }
                hl["@boolean"]                  = { fg = c.orange, bold = true }
                hl["@comment"]                  = { fg = c.comment, italic = true }

                -- JSX / TSX
                hl["@tag"]                      = { fg = c.red }          -- <div>, <Component>
                hl["@tag.builtin"]              = { fg = c.red }          -- tags HTML nativos
                hl["@tag.attribute"]            = { fg = c.yellow }       -- className, href, lang
                hl["@tag.delimiter"]            = { fg = c.blue5 }        -- < > /

                -- Java / annotations
                hl["@attribute"]                = { fg = c.yellow, bold = true } -- Java annotations
                hl["@annotation"]               = { fg = c.yellow, bold = true }
                hl["@namespace"]                = { fg = c.blue2 }        -- packages

                -- =============================================
                -- LSP SEMANTIC TOKENS
                -- Tienen prioridad sobre treesitter, hay que
                -- definirlos explicitamente
                -- =============================================

                -- Clases, interfaces, enums
                hl["@lsp.type.class"]           = { fg = c.yellow }
                hl["@lsp.type.interface"]       = { fg = c.yellow }
                hl["@lsp.type.enum"]            = { fg = c.yellow }
                hl["@lsp.type.enumMember"]      = { fg = c.orange }
                hl["@lsp.type.struct"]          = { fg = c.yellow }
                hl["@lsp.type.typeParameter"]   = { fg = c.yellow }       -- generics <T>

                -- Funciones y metodos
                hl["@lsp.type.function"]        = { fg = c.blue }
                hl["@lsp.type.method"]          = { fg = c.blue }

                -- Variables y propiedades
                hl["@lsp.type.variable"]        = { fg = c.fg }
                hl["@lsp.type.parameter"]       = { fg = c.orange }
                hl["@lsp.type.property"]        = { fg = c.blue1 }

                -- Keywords via LSP
                hl["@lsp.type.keyword"]         = { fg = c.purple, italic = true }
                hl["@lsp.type.modifier"]        = { fg = c.purple, italic = true }

                -- Namespace / modules
                hl["@lsp.type.namespace"]       = { fg = c.blue2 }

                -- Dejar que treesitter maneje estos (evita que LSP los pise)
                hl["@lsp.type.type"]            = {}  -- treesitter lo maneja mejor
                hl["@lsp.type.string"]          = {}  -- treesitter lo maneja mejor
                hl["@lsp.type.number"]          = {}  -- treesitter lo maneja mejor
                hl["@lsp.type.comment"]         = {}  -- treesitter lo maneja mejor

                -- Modificadores semanticos (typemod)
                hl["@lsp.typemod.variable.readonly"]       = { fg = c.orange }   -- const
                hl["@lsp.typemod.variable.defaultLibrary"] = { fg = c.cyan }     -- built-ins globales
                hl["@lsp.typemod.function.defaultLibrary"] = { fg = c.cyan }     -- console, Math, etc
                hl["@lsp.typemod.class.defaultLibrary"]    = { fg = c.cyan }
            end,
        })
        vim.cmd("colorscheme tokyonight-night")
    end,
}
