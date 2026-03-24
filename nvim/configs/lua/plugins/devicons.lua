return {
  "nvim-tree/nvim-web-devicons",
  lazy     = false,
  priority = 1000,
  config   = function()
    require("nvim-web-devicons").setup({
      color_icons = true,
      default     = true,
      strict      = true,
    override_by_extension = {},
    })
  end,
}
