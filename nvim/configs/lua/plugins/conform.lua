return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd   = { "ConformInfo" },
  keys  = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true }) end,
      desc = "Formatear archivo",
    },
  },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        javascript      = { "biome-check" },
        javascriptreact = { "biome-check" },
        typescript      = { "biome-check" },
        typescriptreact = { "biome-check" },
        json            = { "biome-check" },
        css             = { "biome-check" },
        java            = { lsp_format = "prefer" },
        lua             = { lsp_format = "prefer" },
      },

      format_on_save = function(bufnr)
        local ignore_fts = { "NvimTree", "toggleterm", "help", "lazy" }
        for _, ft in ipairs(ignore_fts) do
          if vim.bo[bufnr].filetype == ft then return nil end
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,

      notify_on_error      = true,
      notify_no_formatters = false,

      formatters = {
        ["biome-check"] = {
          command = vim.fn.stdpath("data") .. "/mason/bin/biome",
          cwd = require("conform.util").root_file({
            "biome.json",
            "biome.jsonc",
            "package.json",
          }),
          require_cwd = false,
        },
      },
    })
  end,
}
