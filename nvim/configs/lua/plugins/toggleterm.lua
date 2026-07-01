return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tt", desc = "Terminal flotante" },
    { "<leader>tv", desc = "Terminal vertical" },
    { "<leader>th", desc = "Terminal horizontal" },
    { "<leader>ta", desc = "Agente OpenCode" },
    { "<leader>tc", desc = "Agente Claude" },
    { "<C-\\>",     desc = "Toggle terminal" },
  },
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.30)
        end
      end,
      open_mapping    = [[<C-\>]],
      hide_numbers    = true,
      shade_terminals = false,
      start_in_insert = true,
      insert_mappings = true,
      persist_size    = false,
      persist_mode    = true,
      direction       = "float",
      close_on_exit   = true,
      shell           = vim.o.shell,
      auto_scroll     = true,
      float_opts = {
        border   = "curved",
        width    = math.floor(vim.o.columns * 0.85),
        height   = math.floor(vim.o.lines * 0.85),
        winblend = 3,
      },
    })

    -- Salir del modo terminal con doble Esc (para no interferir con agentes)
    -- Los agentes usan Esc internamente para cancelar tareas
    vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Salir modo terminal" })
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { desc = "Mover izquierda" })
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { desc = "Mover abajo" })
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { desc = "Mover arriba" })
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { desc = "Mover derecha" })

    -- Redimensionar terminal con Ctrl+Alt+flechas (funciona en modo terminal y normal)
    vim.keymap.set("t", "<C-A-Right>", [[<Cmd>vertical resize +5<CR>]], { desc = "Agrandar terminal" })
    vim.keymap.set("t", "<C-A-Left>",  [[<Cmd>vertical resize -5<CR>]], { desc = "Achicar terminal" })
    vim.keymap.set("n", "<C-A-Right>", [[<Cmd>vertical resize +5<CR>]], { desc = "Agrandar terminal" })
    vim.keymap.set("n", "<C-A-Left>",  [[<Cmd>vertical resize -5<CR>]], { desc = "Achicar terminal" })

    local Terminal = require("toggleterm.terminal").Terminal

    -- Terminal flotante general
    local float_term = Terminal:new({ direction = "float", hidden = true })
    vim.keymap.set("n", "<leader>tt", function() float_term:toggle() end, { desc = "Terminal flotante" })

    -- Terminal vertical (a la izquierda)
    local vertical_term = Terminal:new({
      direction = "vertical",
      hidden    = true,
      on_open   = function() vim.cmd("wincmd H") end,
    })
    vim.keymap.set("n", "<leader>tv", function() vertical_term:toggle() end, { desc = "Terminal vertical" })

    -- Terminal horizontal (abajo)
    local horizontal_term = Terminal:new({ direction = "horizontal", hidden = true })
    vim.keymap.set("n", "<leader>th", function() horizontal_term:toggle() end, { desc = "Terminal horizontal" })

    -- Agente OpenCode (vertical, a la izquierda)
    local opencode = Terminal:new({
      cmd       = "opencode",
      direction = "vertical",
      hidden    = true,
      on_open   = function(term)
        vim.cmd("wincmd H")
        vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.30))
        vim.cmd("startinsert!")
      end,
    })
    vim.keymap.set("n", "<leader>ta", function() opencode:toggle() end, { desc = "Agente OpenCode" })

    -- Agente Claude Code (vertical, a la izquierda)
    local claude = Terminal:new({
      cmd       = "claude",
      direction = "vertical",
      hidden    = true,
      on_open   = function(term)
        vim.cmd("wincmd H")
        vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.30))
        vim.cmd("startinsert!")
      end,
    })
    vim.keymap.set("n", "<leader>tc", function() claude:toggle() end, { desc = "Agente Claude" })
  end,
}
