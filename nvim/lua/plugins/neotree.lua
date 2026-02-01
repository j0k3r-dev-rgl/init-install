return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                window = {
                    width = 30,
                    position = "right",
                    mappings = {
                        -- 1. DESACTIVAR conflictos de Neo-tree para liberar la 'o'
                        ["oc"] = "none",
                        ["od"] = "none",
                        ["og"] = "none",
                        ["om"] = "none",
                        ["on"] = "none",
                        ["os"] = "none",
                        ["ot"] = "none",

                        -- 2. TUS MAPEOS de navegación
                        ["o"] = function(state)
                            local line = vim.fn.line(".")
                            if line > 1 then
                                vim.api.nvim_win_set_cursor(0, { line - 1, 0 })
                            end
                        end,
                        ["l"] = function(state)
                            local line = vim.fn.line(".")
                            local last_line = vim.api.nvim_buf_line_count(0)
                            if line < last_line then
                                vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
                            end
                        end,
                        ["k"] = "close_node",
                        ["ñ"] = "open",
                        ["<space>"] = "none",
                        ["<cr>"] = "open_with_window_picker",
                    },
                },
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = false,
                    },
                    hijack_netrw_behavior = "open_current",
                    filtered_items = {
                        hide_dotfiles = false,
                        hide_gitignored = false,
                        hide_hidden = false,
                    },
                },
                event_handlers = {
                    {
                        event = "file_opened",
                        handler = function()
                            require("neo-tree.command").execute({ action = "close" })
                        end
                    },
                },
            })
        end,
    }
}
