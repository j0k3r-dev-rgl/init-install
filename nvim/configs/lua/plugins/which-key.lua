return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    delay = 300,
    win = {
      no_overlap = true,
      padding = { 1, 2 },
      title = true,
      title_pos = "center",
    },
    layout = {
      width = { min = 20, max = 40 },
      spacing = 3,
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    spec = {
      -- Grupos para organizar el menu
      { "<leader>f", group = "Buscar" },
      { "<leader>j", group = "Java" },
      { "<leader>d", group = "Diagnosticos" },
      { "<leader>c", group = "Codigo" },
      { "<leader>r", group = "Renombrar" },
      { "<leader>b", group = "Buffers" },
      { "<leader>w", group = "Sesiones" },
      { "<leader>d", group = "Debug" },
      { "<leader>t", group = "Terminal / Agentes" },
    },
  },
}
