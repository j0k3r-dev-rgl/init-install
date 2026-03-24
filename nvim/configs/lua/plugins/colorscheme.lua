return {
  "webhooked/kanso.nvim",
  lazy     = false,
  priority = 1000,
  config   = function()
    require("kanso").setup({
      bold          = true,
      italics       = true,
      undercurl     = true,
      commentStyle  = { italic = true },
      keywordStyle  = { italic = true },
      transparent   = false,
      terminalColors = true,
      background    = {
        dark  = "zen",
        light = "pearl",
      },
    })
    vim.cmd("colorscheme kanso-zen")
  end,
}
