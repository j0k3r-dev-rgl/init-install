return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    -- Ctrl+D para seleccionar siguiente ocurrencia (igual que VSCode)
    vim.g.VM_maps = {
      ["Find Under"]         = "<C-d>",
      ["Find Subword Under"] = "<C-d>",
      ["Select All"]         = "<C-S-l>",
      ["Add Cursor Down"]    = "<C-S-Down>",
      ["Add Cursor Up"]      = "<C-S-Up>",
      ["Skip Region"]        = "<C-x>",
      ["Remove Region"]      = "<C-S-x>",
    }
    vim.g.VM_theme = "ocean"
  end,
}
