return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts        = true,  -- usar treesitter para mejor deteccion
    ts_config       = {
      lua  = { "string" },
      java = { "string" },
    },
    disable_filetype = { "TelescopePrompt", "noice" },
    fast_wrap = {
      map      = "<M-e>",   -- Alt+e para envolver la palabra en pares
      chars    = { "{", "[", "(", '"', "'" },
      pattern  = [=[[%'%"%>%]%)%}%,]]=],
      offset   = 0,
      end_key  = "$",
      keys     = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma  = true,
      highlight    = "PmenuSel",
      highlight_grey = "LineNr",
    },
  },
}
