return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    { "<leader>wr", "<cmd>SessionRestore<cr>", desc = "Restaurar sesion" },
    { "<leader>ws", "<cmd>SessionSave<cr>",    desc = "Guardar sesion" },
  },
  opts = {
    auto_save    = true,   -- guardar al salir
    auto_restore = true,   -- restaurar al abrir nvim en el mismo directorio
    auto_create  = true,
    suppressed_dirs = { "~/", "/tmp" },
    -- Cerrar nvim-tree antes de guardar (evita conflictos)
    pre_save_cmds  = { "NvimTreeClose" },
    post_restore_cmds = {},
    session_lens = {
      load_on_setup = true,
      previewer     = false,
    },
  },
}
