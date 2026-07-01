return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept      = "<M-l>",
          accept_word = "<C-Right>",
          accept_line = "<C-Down>",
          dismiss     = "<C-]>",
          next        = "<M-]>",
          prev        = "<M-[>",
        },
      },
      filetypes = {
        markdown = true,
        help     = false,
      },
    })

    -- Ocultar sugerencia inline de Copilot cuando blink-cmp abre su menu
    vim.api.nvim_create_autocmd("User", {
      pattern  = "BlinkCmpMenuOpen",
      callback = function() vim.b.copilot_suggestion_hidden = true end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern  = "BlinkCmpMenuClose",
      callback = function() vim.b.copilot_suggestion_hidden = false end,
    })
  end,
}
