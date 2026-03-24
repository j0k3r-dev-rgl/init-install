return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    { "<leader>ft", "<cmd>TodoTelescope<cr>",  desc = "Buscar TODOs" },
    { "]t", function() require("todo-comments").jump_next() end, desc = "Siguiente TODO" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "TODO anterior" },
  },
  opts = {
    signs = true,
    keywords = {
      FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint",    alt = { "INFO" } },
      TEST = { icon = "⏩", color = "test",   alt = { "TESTING", "PASSED", "FAILED" } },
    },
    highlight = {
      before        = "",
      keyword       = "wide",
      after         = "fg",
      pattern       = [[.*<(KEYWORDS)\s*:]],
      comments_only = true,
    },
  },
}
