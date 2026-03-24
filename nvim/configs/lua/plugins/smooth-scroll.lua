return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  config = function()
    local neoscroll = require("neoscroll")

    neoscroll.setup({
      mappings             = {},     -- sin mappings automaticos para evitar warnings
      hide_cursor          = false,
      stop_eof             = true,
      respect_scrolloff    = false,
      cursor_scrolls_alone = true,
      easing               = "sine",
    })

    -- Ctrl+j/k: scroll de 15 lineas con animacion suave
    vim.keymap.set("n", "<C-j>", function() neoscroll.scroll(15,  { move_cursor = true, duration = 150 }) end, { desc = "Bajar 15 lineas" })
    vim.keymap.set("n", "<C-k>", function() neoscroll.scroll(-15, { move_cursor = true, duration = 150 }) end, { desc = "Subir 15 lineas" })
  end,
}
