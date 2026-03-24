return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "" },
      topdelete    = { text = "" },
      changedelete = { text = "▎" },
      untracked    = { text = "▎" },
    },
    signs_staged = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "" },
      topdelete    = { text = "" },
      changedelete = { text = "▎" },
    },
    signs_staged_enable = true,
    signcolumn          = true,
    numhl               = true,  -- resalta el numero de linea con el color del cambio
    linehl              = false,
    word_diff           = false,
    attach_to_untracked = true,
    current_line_blame  = false,
    current_line_blame_opts = {
      virt_text     = true,
      virt_text_pos = "eol",
      delay         = 800,
    },
    current_line_blame_formatter = "  <author>, <author_time:%d/%m/%Y> · <summary>",
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local map = function(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, silent = true, desc = desc })
      end

      -- Navegar entre hunks
      map("n", "]h", function() gs.nav_hunk("next") end, "Siguiente hunk")
      map("n", "[h", function() gs.nav_hunk("prev") end, "Hunk anterior")

      -- Acciones sobre hunks
      map("n", "<leader>hs", gs.stage_hunk,                          "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk,                          "Reset hunk")
      map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
      map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
      map("n", "<leader>hS", gs.stage_buffer,                        "Stage buffer")
      map("n", "<leader>hR", gs.reset_buffer,                        "Reset buffer")
      map("n", "<leader>hp", gs.preview_hunk,                        "Preview hunk")
      map("n", "<leader>hi", gs.preview_hunk_inline,                 "Preview hunk inline")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame linea")
      map("n", "<leader>hB", gs.toggle_current_line_blame,           "Toggle blame inline")
      map("n", "<leader>hd", gs.diffthis,                            "Diff vs index")
      map("n", "<leader>hD", function() gs.diffthis("~") end,        "Diff vs ultimo commit")
    end,
  },
}
