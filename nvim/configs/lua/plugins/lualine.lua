return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
  event = "VeryLazy",
  opts = {
    options = {
      theme                = "auto",
      globalstatus         = true, -- una sola barra para todas las ventanas
      component_separators = { left = "", right = "" },
      section_separators   = { left = "", right = "" },
      disabled_filetypes   = {
        statusline = { "NvimTree", "toggleterm" },
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch",
        {
          "diff",
          symbols = { added = " ", modified = " ", removed = " " },
          diff_color = {
            added    = { fg = "#e5c07b" },
            modified = { fg = "#00bfff" },
            removed  = { fg = "#e06c75" },
          },
        },
        {
          "diagnostics",
          sources  = { "nvim_lsp" },
          sections = { "error", "warn", "info", "hint" },
          symbols  = { error = " ", warn = " ", info = " ", hint = " " },
        },
      },
      lualine_c = {
        {
          "filename",
          path    = 1,
          symbols = { modified = " ●", readonly = " ", unnamed = "[Sin nombre]" },
        },
        -- Breadcrumbs: clase > metodo donde esta el cursor
        {
          function() return require("nvim-navic").get_location() end,
          cond  = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
          color = { fg = "#abb2bf" },
        },
      },
      lualine_x = {
        -- Componentes de Noice (se cargan solo si noice esta disponible)
        {
          function() return require("noice").api.status.command.get() end,
          cond  = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          color = { fg = "#ff9e64" },
        },
        {
          function() return require("noice").api.status.mode.get() end,
          cond  = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          color = { fg = "#ff9e64" },
        },
        -- LSP activo en el buffer
        {
          "lsp_status",
          icon    = "",
          symbols = {
            spinner   = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
            done      = "✓",
            separator = " ",
          },
        },
        "encoding",
        "fileformat",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    extensions = { "nvim-tree", "toggleterm", "lazy", "mason", "nvim-dap-ui" },
  },
}
