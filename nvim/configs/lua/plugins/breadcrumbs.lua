return {
  "SmiteshP/nvim-navic",
  lazy = true,
  dependencies = { "neovim/nvim-lspconfig" },
  init = function()
    vim.g.navic_silence = true

    -- Adjuntar navic al LSP al conectar
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("navic_attach", { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, event.buf)
        end
      end,
    })
  end,
  opts = {
    separator       = "  ",
    highlight       = true,
    depth_limit     = 5,
    icons = {
      File          = " ",
      Module        = " ",
      Namespace     = " ",
      Package       = " ",
      Class         = " ",
      Method        = " ",
      Property      = " ",
      Field         = " ",
      Constructor   = " ",
      Enum          = " ",
      Interface     = " ",
      Function      = " ",
      Variable      = " ",
      Constant      = " ",
      String        = " ",
      Number        = " ",
      Boolean       = " ",
      Array         = " ",
      Object        = " ",
      Key           = " ",
      Null          = " ",
      EnumMember    = " ",
      Struct        = " ",
      Event         = " ",
      Operator      = " ",
      TypeParameter = " ",
    },
  },
}
