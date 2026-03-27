return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    -- La nueva API (branch main) ya no usa nvim-treesitter.configs
    -- El highlight es nativo de Neovim, este plugin solo provee queries y el instalador
    require("nvim-treesitter").setup({
      -- Directorio donde se instalan parsers y queries
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Instala los parsers necesarios (async, no bloquea el inicio)
    require("nvim-treesitter").install({
      -- === Java / Spring ===
      "java",
      "xml",           -- pom.xml, application.xml, Spring beans
      "yaml",          -- application.yml, application-*.yml
      "properties",    -- application.properties
      "groovy",        -- Gradle build files (build.gradle)
      "sql",           -- JPQL, consultas nativas
      "http",          -- archivos .http (Spring rest client / IntelliJ HTTP)
      "graphql",       -- Spring GraphQL

      -- === React / React Router 7 ===
      "javascript",
      "typescript",
      "tsx",
      -- jsx no tiene parser separado, está incluido en javascript+tsx
      "html",
      "css",
      "scss",          -- estilos
      "json",
      -- "jsonc",      -- falla descarga desde nvim-treesitter, usar json
      "json5",         -- json5 (algunos configs)
      "jsdoc",         -- comentarios JSDoc en JS/TS
      "regex",         -- expresiones regulares en JS/TS
      "styled",        -- styled-components / css-in-js

      -- === Config y Tooling ===
      "toml",          -- configs (Cargo, pyproject, etc)
      "ini",           -- archivos .ini
      "editorconfig",  -- .editorconfig
      "dockerfile",    -- Dockerfile
      "bash",          -- scripts .sh

      -- === Git ===
      "diff",          -- diffs y patches
      "gitcommit",     -- mensajes de commit
      "gitignore",     -- .gitignore
      "git_config",    -- .gitconfig
      "gitattributes", -- .gitattributes

      -- === Editor / Lua (Neovim config) ===
      "lua",
      "luadoc",        -- comentarios LuaDoc
      "vim",
      "vimdoc",
      "query",         -- Tree-sitter queries

      -- === Markdown ===
      "markdown",
      "markdown_inline",

      -- === Utilidades ===
      "comment",       -- comentarios TODO/FIXME/NOTE
      "csv",           -- archivos CSV
    })

    -- Habilita highlight de treesitter para los filetypes usados
    -- En la nueva API esto se hace via autocmd (el plugin ya no lo hace automático)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "java", "xml", "yaml", "sql", "http", "graphql",
        "javascript", "typescript", "tsx", "html", "css", "scss",
        "json", "json5", "jsdoc", "regex",
        "toml", "ini", "editorconfig", "dockerfile", "bash",
        "diff", "gitcommit", "gitignore", "git_config", "gitattributes",
        "lua", "vim", "vimdoc", "query",
        "markdown", "markdown_inline",
        "csv",
      },
      callback = function(ev)
        -- Protección: no habilitar en archivos muy grandes (evita freeze)
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
        if ok and stats and stats.size > 500 * 1024 then
          return
        end
        pcall(vim.treesitter.start)
      end,
    })

    -- Indent de treesitter (nativo en nueva API)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "java", "javascript", "typescript", "tsx", "html", "css",
        "lua", "bash", "yaml", "json", "markdown",
      },
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
