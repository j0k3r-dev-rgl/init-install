-- Deshabilitar netrw (requerido por nvim-tree)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e",   "<cmd>NvimTreeToggle<cr>",   desc = "Toggle explorador" },
    { "<C-A-Right>", "<cmd>vertical resize -5<cr>", desc = "Achicar explorador" },
    { "<C-A-Left>",  "<cmd>vertical resize +5<cr>", desc = "Agrandar explorador" },
  },
  config = function()
    local api = require("nvim-tree.api")



    -- Colores git
    local function set_git_colors()
      vim.api.nvim_set_hl(0, "NvimTreeGitDirtyIcon",    { fg = "#00bfff" })
      vim.api.nvim_set_hl(0, "NvimTreeGitStagedIcon",   { fg = "#00bfff" })
      vim.api.nvim_set_hl(0, "NvimTreeGitNewIcon",      { fg = "#e5c07b" })
      vim.api.nvim_set_hl(0, "NvimTreeGitDeletedIcon",  { fg = "#e06c75" })
      vim.api.nvim_set_hl(0, "NvimTreeGitRenamedIcon",  { fg = "#d19a66" })
      vim.api.nvim_set_hl(0, "NvimTreeGitMergeIcon",    { fg = "#ff6b6b" })
      vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon",  { fg = "#5c6370" })
      -- Nombres de archivos por estado
      vim.api.nvim_set_hl(0, "NvimTreeFileDirty",       { fg = "#00bfff" })
      vim.api.nvim_set_hl(0, "NvimTreeFileStaged",      { fg = "#00bfff" })
      vim.api.nvim_set_hl(0, "NvimTreeFileNew",         { fg = "#e5c07b" })
      vim.api.nvim_set_hl(0, "NvimTreeFileDeleted",     { fg = "#e06c75" })
      vim.api.nvim_set_hl(0, "NvimTreeFileRenamed",     { fg = "#d19a66" })
      vim.api.nvim_set_hl(0, "NvimTreeFileMerge",       { fg = "#ff6b6b" })
      vim.api.nvim_set_hl(0, "NvimTreeFileIgnored",     { fg = "#5c6370" })
    end

    local function set_folder_colors()
      vim.api.nvim_set_hl(0, "NvimTreeFolderName",       { fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName",  { fg = "#ffffff", bold = true })
      vim.api.nvim_set_hl(0, "NvimTreeFolderIcon",       { fg = "#ffffff" })
    end

    set_git_colors()
    set_folder_colors()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = function()
      set_git_colors()
      set_folder_colors()
    end})

    -- on_attach: keymaps dentro del explorador
    local function on_attach(bufnr)
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- Cargar todos los keymaps por defecto
      api.config.mappings.default_on_attach(bufnr)

      -- Raiz original al abrir nvim (se guarda una vez)
      local startup_root = vim.fn.getcwd()

      -- l: abrir archivo o carpeta, bloqueando salir de la raiz inicial
      local function smart_open()
        local node = api.tree.get_node_under_cursor()

        -- Bloquear el nodo ".." que sube al padre
        if node.name == ".." then
          return
        end

        -- Bloquear si el nodo apunta fuera de la raiz inicial
        if node.absolute_path and not vim.startswith(node.absolute_path, startup_root) then
          return
        end

        if node.nodes ~= nil then
          api.node.open.edit()
        else
          api.node.open.edit()
          api.tree.close()
        end
      end

      -- h: cerrar directorio expandido o ir al padre si ya esta cerrado
      local function smart_close()
        local node = api.tree.get_node_under_cursor()
        if node.nodes ~= nil and node.open then
          -- Es un directorio abierto: colapsar
          api.node.open.edit()
        else
          -- Ya cerrado o es un archivo: ir al directorio padre
          api.node.navigate.parent_close()
        end
      end

      vim.keymap.set("n", "l",     smart_open,                     opts("Abrir"))
      vim.keymap.set("n", "<CR>",  smart_open,                     opts("Abrir"))
      vim.keymap.set("n", "h",     api.node.navigate.parent_close, opts("Cerrar directorio"))
      vim.keymap.set("n", "H",     api.tree.collapse_all,          opts("Colapsar todo"))
      vim.keymap.set("n", "z",     api.tree.collapse_all,          opts("Colapsar todo"))
      vim.keymap.set("n", "Z",     api.tree.expand_all,            opts("Expandir todo"))

      -- Bloquear todos los keymaps que cambian la raiz
      local noop = function() end
      vim.keymap.set("n", "-",        noop, opts("Bloqueado: subir raiz"))
      vim.keymap.set("n", "<C-]>",    noop, opts("Bloqueado: cambiar raiz"))
      vim.keymap.set("n", "<2-RightMouse>", noop, opts("Bloqueado: cambiar raiz"))

      -- Ctrl+k: scroll global (sobreescribe el info de nvim-tree)
      vim.keymap.set("n", "<C-k>", function()
        require("neoscroll").scroll(-15, { move_cursor = true, duration = 150 })
      end, opts("Scroll arriba"))
      vim.keymap.set("n", "<C-j>", function()
        require("neoscroll").scroll(15, { move_cursor = true, duration = 150 })
      end, opts("Scroll abajo"))
    end

    require("nvim-tree").setup({
      -- Deshabilitar netrw
      disable_netrw = true,
      hijack_netrw  = true,

      -- Posicion a la derecha
      view = {
        side  = "right",
        width = 35,
      },

      -- Renderer: group_empty colapsa carpetas con 1 solo hijo de forma nativa
      renderer = {
        group_empty       = true,   -- com/example/app → com/example/app en un nodo
        highlight_git     = true,
        highlight_opened_files = "name",
        icons = {
          git_placement = "after",
          glyphs = {
            git = {
              unstaged  = "",   -- lápiz (Nerd Font)
              staged    = "",   -- check
              unmerged  = "",   -- merge
              renamed   = "",   -- flecha
              untracked = "",   -- signo más
              deleted   = "",   -- basura
              ignored   = "",   -- círculo prohibido
            },
          },
        },
      },

      -- Git
      git = {
        enable  = true,
        ignore  = false,   -- mostrar archivos ignorados (en gris)
        timeout = 400,
      },

      -- Filtros
      filters = {
        dotfiles = false,  -- mostrar archivos ocultos
        custom   = {},
      },

      -- Cerrar al abrir un archivo
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },

      -- Nunca cambiar la raiz automaticamente
      sync_root_with_cwd  = false,
      respect_buf_cwd     = false,
      prefer_startup_root = true,

      -- Seguir el archivo actual pero SIN cambiar la raiz
      update_focused_file = {
        enable      = true,
        update_root = {
          enable    = false,  -- nunca actualizar la raiz
          ignore_list = {},
        },
      },

      diagnostics = { enable = false },

      on_attach = on_attach,
    })
  end,
}
