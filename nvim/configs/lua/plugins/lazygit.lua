return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd  = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>",            desc = "LazyGit" },
    { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit archivo actual" },
    { "<leader>gl", "<cmd>LazyGitFilter<cr>",      desc = "LazyGit commits proyecto" },
    { "<leader>gc", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit commits archivo" },
  },
  config = function()
    vim.g.lazygit_floating_window_scaling_factor = 0.92
    vim.g.lazygit_floating_window_winblend       = 0

    -- Cargar extension de telescope
    require("telescope").load_extension("lazygit")

    -- Registrar grupo en which-key
    require("which-key").add({
      { "<leader>g", group = "Git" },
    })
  end,
}
