return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<S-l>",     "<cmd>BufferLineCycleNext<cr>",      desc = "Siguiente buffer" },
    { "<S-h>",     "<cmd>BufferLineCyclePrev<cr>",      desc = "Buffer anterior" },
    { "<leader>bx","<cmd>bdelete<cr>",                  desc = "Cerrar buffer" },
    { "<leader>bo","<cmd>BufferLineCloseOthers<cr>",    desc = "Cerrar otros buffers" },
    { "<leader>br","<cmd>BufferLineCloseRight<cr>",     desc = "Cerrar buffers a la derecha" },
    { "<leader>bl","<cmd>BufferLineCloseLeft<cr>",      desc = "Cerrar buffers a la izquierda" },
  },
  opts = {
    options = {
      mode = "buffers",
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      left_mouse_command = "buffer %d",
      indicator = { style = "icon", icon = "▎" },
      buffer_close_icon = "󰅖",
      modified_icon = "●",
      close_icon = "",
      show_buffer_close_icons = true,
      show_close_icon = false,
      separator_style = "slant",
      always_show_bufferline = true,
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      -- Offset para que no se superponga con neo-tree
        offsets = {
        {
          filetype  = "NvimTree",
          text      = "Explorador",
          text_align = "center",
          separator = true,
        },
      },
    },
  },
}
