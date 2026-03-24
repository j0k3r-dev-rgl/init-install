return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    cmdline = {
      enabled = true,
      view    = "cmdline_popup",  -- barra de comandos flotante centrada
      format  = {
        cmdline     = { icon = "" },
        search_down = { icon = " " },
        search_up   = { icon = " " },
        filter      = { icon = "$" },
        lua         = { icon = "" },
        help        = { icon = "" },
      },
    },
    messages = {
      enabled       = true,
      view          = "notify",
      view_error    = "notify",
      view_warn     = "notify",
      view_history  = "messages",
      view_search   = "virtualtext",
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
    },
    lsp = {
      progress = {
        enabled = true,
        view    = "mini",
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"]                = true,
      },
      hover     = { enabled = true },
      signature = { enabled = true },
    },
    presets = {
      bottom_search        = false, -- cmdline flotante para busqueda
      command_palette      = true,  -- cmdline y popupmenu juntos
      long_message_to_split = true, -- mensajes largos en split
      lsp_doc_border       = true,  -- borde en docs de LSP
    },
    routes = {
      -- Silenciar mensajes de escritura de archivo
      {
        filter = { event = "msg_show", kind = "", find = "written" },
        opts   = { skip = true },
      },
      -- Silenciar mensajes de busqueda
      {
        filter = { event = "msg_show", kind = "search_count" },
        opts   = { skip = true },
      },
      -- Silenciar notificaciones de nvim-tree
      {
        filter = { event = "notify", find = "NvimTree:" },
        opts   = { skip = true },
      },
    },
    views = {
      cmdline_popup = {
        position = { row = "45%", col = "50%" },
        size     = { width = 60, height = "auto" },
        border   = { style = "rounded" },
      },
      popupmenu = {
        relative = "editor",
        position = { row = "55%", col = "50%" },
        size     = { width = 60, height = 10 },
        border   = { style = "rounded" },
      },
    },
  },
}
