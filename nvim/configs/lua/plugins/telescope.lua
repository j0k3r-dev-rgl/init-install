return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "Buscar archivos" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",                 desc = "Buscar texto en proyecto" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "Buffers abiertos" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                  desc = "Archivos recientes" },
    { "<leader>fs", "<cmd>Telescope grep_string<cr>",               desc = "Buscar palabra bajo cursor" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>",               desc = "Diagnosticos LSP" },
    { "<leader>fc", "<cmd>Telescope commands<cr>",                  desc = "Comandos" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>",                   desc = "Keymaps" },
    { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buscar en archivo actual" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<esc>"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true, -- mostrar archivos ocultos
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        },
        live_grep = {
          additional_args = { "--hidden" },
        },
      },
    })

    -- Cargar extension fzf para busqueda mas rapida
    telescope.load_extension("fzf")
  end,
}
