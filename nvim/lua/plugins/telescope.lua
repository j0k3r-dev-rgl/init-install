return {
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = { 
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local actions = require('telescope.actions')
      require('telescope').setup({
        defaults = {
          -- Configuración mínima y segura
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
          mappings = {
            n = {
              ["o"] = actions.move_selection_previous,
              ["l"] = actions.move_selection_next,
              ["k"] = actions.close, -- Izquierda (k) cierra
              ["ñ"] = actions.select_default, -- Derecha (ñ) selecciona/abre
            },
          },
        },
      })
    end
  }
}
