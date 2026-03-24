return {
  "Exafunction/windsurf.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  config = function()
    require("codeium").setup({
      -- Usar virtual text (ghost text inline) en lugar de cmp source
      enable_cmp_source = false,
      virtual_text = {
        enabled                  = true,
        manual                   = false,
        default_filetype_enabled = true,
        idle_delay               = 75,
        virtual_text_priority    = 65535,
        map_keys                 = true,
        key_bindings = {
          accept      = "<Tab>",   -- aceptar sugerencia completa
          accept_word = "<C-Right>", -- aceptar solo la siguiente palabra
          accept_line = "<C-Down>",  -- aceptar solo la siguiente linea
          clear       = "<C-]>",   -- limpiar sugerencia
          next        = "<M-]>",   -- siguiente sugerencia
          prev        = "<M-[>",   -- sugerencia anterior
        },
      },
    })

    -- Mostrar estado de Codeium en lualine
    require("codeium.virtual_text").set_statusbar_refresh(function()
      local ok, lualine = pcall(require, "lualine")
      if ok then lualine.refresh() end
    end)
  end,
}
