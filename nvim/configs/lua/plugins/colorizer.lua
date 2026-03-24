return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  opts  = {
    filetypes = {
      "css",
      "scss",
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "lua",
    },
    user_default_options = {
      RGB      = true,   -- #RGB
      RRGGBB   = true,   -- #RRGGBB
      names    = false,  -- "red", "blue" etc (desactivado para no tener falsos positivos)
      RRGGBBAA = true,   -- #RRGGBBAA
      rgb_fn   = true,   -- rgb() y rgba()
      hsl_fn   = true,   -- hsl() y hsla()
      css      = true,   -- habilitar todas las opciones css
      mode     = "background", -- mostrar color como fondo del texto
      tailwind = true,  -- colores de tailwind
    },
  },
}
