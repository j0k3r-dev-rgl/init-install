return {
  "kylechui/nvim-surround",
  version = "*",
  event   = "VeryLazy",
  opts    = {},
  -- Keymaps por defecto (no necesitan config extra):
  -- ys{motion}{char} -- envolver: ysiw" -> "palabra", ysiw( -> (palabra)
  -- ds{char}         -- borrar: ds" quita las comillas
  -- cs{old}{new}     -- cambiar: cs"' cambia " por '
  -- En visual: S{char} -- envolver seleccion
  -- Ejemplos utiles:
  -- ysiwt           -- envolver en tag HTML: <tag>palabra</tag>
  -- yss)            -- envolver linea entera en ()
  -- dst             -- borrar tag HTML
  -- cst<div>        -- cambiar tag por <div>
}
