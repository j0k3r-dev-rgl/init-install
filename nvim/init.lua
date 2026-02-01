require("core.nodejs").setup({ silent = true })
require("core.options")
require("core.keymaps")
require("core.lazy")
require("core.java-helpers")
require("core.java-check")
require("core.runners")
require("config.dbee-visual").setup() -- Configuración visual para nvim-dbee
vim.g.skip_ts_context_commentstring_module = true
vim.opt.termguicolors = true
-- Activar highlighting de treesitter automáticamente para todos los archivos
vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function()
        pcall(vim.treesitter.start) -- pcall para evitar errores si no hay parser
    end,
})

-- Configuración de diagnósticos
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        spacing = 4,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})
