return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    -- Keymaps
    keymap = {
      preset  = "default",
      ["<CR>"]  = { "accept", "fallback" },
      ["<Tab>"] = {
        "select_next",
        "snippet_forward",
        function(cmp)
          -- Si el menu esta visible pero nada seleccionado, igual deja tabular
          if not cmp.is_visible() then
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
              "n", false
            )
          end
        end,
      },
      ["<S-Tab>"]   = { "select_prev", "snippet_backward", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"]     = { "hide", "fallback" },
      ["<C-k>"]     = { "scroll_documentation_up", "fallback" },
      ["<C-j>"]     = { "scroll_documentation_down", "fallback" },
      ["<Up>"]      = { "select_prev", "fallback" },
      ["<Down>"]    = { "select_next", "fallback" },
    },

    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant       = "mono",
    },

    -- Fuentes de completado
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        lsp = {
          name         = "LSP",
          module       = "blink.cmp.sources.lsp",
          score_offset = 10,
          -- En JSX/TSX dar prioridad a emmet (elementos HTML) sobre vtsls
          transform_items = function(_, items)
            local ft = vim.bo.filetype
            if ft == "typescriptreact" or ft == "javascriptreact" then
              for _, item in ipairs(items) do
                -- Bajar prioridad de sugerencias que no son elementos HTML
                if item.client_name ~= "emmet_language_server" then
                  item.score_offset = (item.score_offset or 0) - 5
                end
              end
            end
            return items
          end,
        },
        snippets = {
          name   = "Snippets",
          module = "blink.cmp.sources.snippets",
          opts   = {
            friendly_snippets    = true,
            search_paths         = { vim.fn.stdpath("config") .. "/snippets" },
            global_snippets      = { "all" },
            extended_filetypes   = { typescriptreact = { "typescript" } },
          },
        },
        buffer = {
          name   = "Buffer",
          module = "blink.cmp.sources.buffer",
          score_offset = -5,
        },
      },
    },

    -- Completado
    completion = {
      accept = {
        auto_brackets = { enabled = true },
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
      menu = {
        border      = "rounded",
        scrollbar   = true,
        draw = {
          treesitter  = { "lsp" },
          columns     = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind", gap = 1 },
          },
        },
      },
      documentation = {
        auto_show         = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
      ghost_text = { enabled = false },
    },

    -- Signature help al escribir argumentos
    signature = {
      enabled = true,
      window  = { border = "rounded" },
    },

    -- Fuzzy matching
    fuzzy = { implementation = "lua" },
  },
}
