-- ============================================================================
-- CONFIGURACIÓN CENTRALIZADA DE ATAJOS DE TECLADO
-- Todos los atajos de nvim organizados por categoría
-- ============================================================================

vim.g.mapleader = " "
local keymap = vim.keymap

-- ============================================================================
-- 1. NAVEGACIÓN BÁSICA VIM (Modo Normal y Visual)
-- ============================================================================
-- Mapeos personalizados: arriba (o), abajo (l), izq (k), der (ñ)

-- Modo Normal
keymap.set("n", "o", "k", { remap = false, silent = true, desc = "Mover arriba" })
keymap.set("n", "l", "j", { remap = false, desc = "Mover abajo" })
keymap.set("n", "k", "h", { remap = false, desc = "Mover izquierda" })
keymap.set("n", "ñ", "l", { remap = false, desc = "Mover derecha" })

-- Modo Visual
keymap.set("v", "o", "k", { remap = false, silent = true, desc = "Mover arriba (visual)" })
keymap.set("v", "l", "j", { remap = false, desc = "Mover abajo (visual)" })
keymap.set("v", "k", "h", { remap = false, desc = "Mover izquierda (visual)" })
keymap.set("v", "ñ", "l", { remap = false, desc = "Mover derecha (visual)" })

-- ============================================================================
-- 2. INSERCIÓN DE TEXTO
-- ============================================================================
keymap.set("n", "i", "i", { remap = false, desc = "Insertar en posición actual" })
keymap.set("n", "p", "a", { remap = false, desc = "Insertar a la derecha del cursor" })
keymap.set("n", "P", "A", { remap = false, desc = "Insertar al final de la línea" })
keymap.set("n", "O", "O", { remap = false, desc = "Insertar línea arriba" })
keymap.set("n", "L", "o", { remap = false, desc = "Insertar línea abajo" })

-- ============================================================================
-- 3. ARCHIVOS Y EDICIÓN BÁSICA
-- ============================================================================
keymap.set("n", "e", "<cmd>Neotree toggle<cr>", { remap = false, desc = "Abrir/Cerrar explorador de archivos" })
keymap.set("n", "w", ":w<CR>", { remap = false, desc = "Guardar archivo" })
keymap.set("n", "q", ":bdelete<CR>", { remap = false, desc = "Cerrar buffer actual" })
keymap.set("n", "z", "u", { remap = false, desc = "Deshacer cambios" })
keymap.set("n", "Z", "<C-r>", { remap = false, desc = "Rehacer cambios" })
keymap.set("n", "Q", ":qa!<CR>", { remap = false, desc = "Cerrar todo y salir de Neovim" })

-- ============================================================================
-- 3.1. CORTAR, COPIAR Y PEGAR
-- ============================================================================
-- x abre el menú para cortar (funciona como d - delete)
keymap.set("n", "x", "d", { remap = false, desc = "Menú de cortar (x + movimiento, o xx para línea)" })
keymap.set("n", "xx", "dd", { remap = false, desc = "Cortar línea completa" })
keymap.set("v", "x", "d", { remap = false, desc = "Cortar selección visual" })

-- c abre el menú para copiar (funciona como y - yank)
keymap.set("n", "c", "y", { remap = false, desc = "Menú de copiar (c + movimiento, o cc para línea)" })
keymap.set("n", "cc", "yy", { remap = false, desc = "Copiar línea completa" })
keymap.set("v", "c", "y", { remap = false, desc = "Copiar selección visual" })

-- v para pegar después del cursor, V para pegar antes
keymap.set("n", "v", "p", { remap = false, desc = "Pegar después del cursor" })
keymap.set("n", "V", "P", { remap = false, desc = "Pegar antes del cursor" })
keymap.set("v", "v", "p", { remap = false, desc = "Pegar en selección visual" })
keymap.set("v", "V", "P", { remap = false, desc = "Pegar antes en selección visual" })

-- ============================================================================
-- 3.2. IDENTACIÓN
-- ============================================================================
-- > para identar a la derecha, < para identar a la izquierda
keymap.set("n", ">", ">>", { remap = false, desc = "Identar línea a la derecha" })
keymap.set("n", "<", "<<", { remap = false, desc = "Identar línea a la izquierda" })
keymap.set("v", ">", ">gv", { remap = false, desc = "Identar selección a la derecha" })
keymap.set("v", "<", "<gv", { remap = false, desc = "Identar selección a la izquierda" })

-- ============================================================================
-- 4. MOVIMIENTO ENTRE VENTANAS
-- ============================================================================
keymap.set("n", "<C-k>", "<C-w>h", { remap = false, desc = "Ir a ventana izquierda" })
keymap.set("n", "<C-l>", "<C-w>j", { remap = false, desc = "Ir a ventana abajo" })
keymap.set("n", "<C-ñ>", "<C-w>l", { remap = false, desc = "Ir a ventana derecha" })
keymap.set("n", "<C-o>", "<C-w>k", { remap = false, desc = "Ir a ventana arriba" })

-- ============================================================================
-- 5. NAVEGACIÓN ENTRE BUFFERS (Archivos Abiertos)
-- ============================================================================
keymap.set("n", "<M-k>", "<cmd>BufferLineCyclePrev<cr>", { remap = false, desc = "Buffer anterior" })
keymap.set("n", "<M-ñ>", "<cmd>BufferLineCycleNext<cr>", { remap = false, desc = "Buffer siguiente" })
keymap.set("n", "<leader>x", "<cmd>bdelete<cr>", { remap = false, desc = "Cerrar buffer actual" })

-- Saltos directos a buffers específicos
keymap.set("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", { remap = false, desc = "Ir a buffer 1" })
keymap.set("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", { remap = false, desc = "Ir a buffer 2" })
keymap.set("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", { remap = false, desc = "Ir a buffer 3" })
keymap.set("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", { remap = false, desc = "Ir a buffer 4" })
keymap.set("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", { remap = false, desc = "Ir a buffer 5" })
keymap.set("n", "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", { remap = false, desc = "Ir a buffer 6" })
keymap.set("n", "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", { remap = false, desc = "Ir a buffer 7" })
keymap.set("n", "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", { remap = false, desc = "Ir a buffer 8" })
keymap.set("n", "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", { remap = false, desc = "Ir a buffer 9" })

-- ============================================================================
-- 6. NAVEGACIÓN DE EXTREMOS DE LÍNEA
-- ============================================================================
-- Modo Normal
keymap.set("n", "j", "^", { remap = false, desc = "Ir al inicio de la línea" })
keymap.set("n", "{", "$", { remap = false, desc = "Ir al final de la línea" })

-- Modo Visual
keymap.set("v", "j", "^", { remap = false, desc = "Ir al inicio de la línea (visual)" })
keymap.set("v", "{", "$", { remap = false, desc = "Ir al final de la línea (visual)" })

-- ============================================================================
-- 7. SELECCIÓN VISUAL (Sistema con 's' como prefijo)
-- ============================================================================
-- s → Entrar al modo visual (carácter por carácter)
-- sw → Seleccionar palabra
-- sl → Seleccionar línea completa
-- se → Seleccionar desde cursor hasta el final de línea
-- ss → Seleccionar desde cursor hasta el inicio de línea

keymap.set("n", "s", "v", { remap = false, desc = "Entrar al modo visual" })
keymap.set("n", "sw", "viw", { remap = false, desc = "Seleccionar palabra" })
keymap.set("n", "sl", "V", { remap = false, desc = "Seleccionar línea completa" })
keymap.set("n", "se", "v$", { remap = false, desc = "Seleccionar hasta el final de línea" })
keymap.set("n", "ss", "v^", { remap = false, desc = "Seleccionar hasta el inicio de línea" })

-- Mantener compatibilidad con atajos anteriores
keymap.set("n", "K", "v^", { remap = false, desc = "Seleccionar hasta el inicio de línea" })
keymap.set("n", "Ñ", "v$", { remap = false, desc = "Seleccionar hasta el final de línea" })

-- Ctrl+d para seleccionar la palabra donde está el cursor (viw)
keymap.set("n", "<C-d>", "viw", { remap = false, desc = "Seleccionar palabra completa bajo cursor" })

-- ============================================================================
-- 8. SCROLL Y CENTRADO
-- ============================================================================
-- Scroll 1/4 de página (en lugar de 1/2)
keymap.set("n", "<M-l>", function()
    local lines = math.floor(vim.api.nvim_win_get_height(0) / 4)
    vim.cmd("normal! " .. lines .. "jzz")
end, { remap = false, desc = "Scroll down 1/4 de página y centrar" })

keymap.set("n", "<M-o>", function()
    local lines = math.floor(vim.api.nvim_win_get_height(0) / 4)
    vim.cmd("normal! " .. lines .. "kzz")
end, { remap = false, desc = "Scroll up 1/4 de página y centrar" })

-- ============================================================================
-- 9. TERMINAL (ToggleTerm)
-- ============================================================================
-- Leader + t para abrir/cerrar terminal horizontal (ID 1)
keymap.set('n', '<leader>t', '<cmd>1ToggleTerm direction=horizontal<cr>',
    { remap = false, desc = "Toggle terminal horizontal" })

-- Leader + T para abrir/cerrar terminal flotante (ID 2)
keymap.set('n', '<leader>T', '<cmd>2ToggleTerm direction=float<cr>', { remap = false, desc = "Toggle terminal flotante" })

-- En modo terminal:
keymap.set('t', '<esc>', [[<C-\><C-n>]], { remap = false, desc = "Salir del modo insert en terminal" })
keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { remap = false, desc = "Terminal: ir a ventana izquierda" })
keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { remap = false, desc = "Terminal: ir a ventana abajo" })
keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { remap = false, desc = "Terminal: ir a ventana arriba" })
keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { remap = false, desc = "Terminal: ir a ventana derecha" })

keymap.set('n', '<leader>gg', function()
    require("core.lazygit-toggle").toggle()
end, { remap = false, desc = "Git: LazyGit toggle" })

keymap.set('n', '<leader>ga', function()
    require("core.git-commands").add()
end, { remap = false, desc = "Git: Add archivos" })

keymap.set('n', '<leader>gc', function()
    require("core.git-commands").commit()
end, { remap = false, desc = "Git: Commit" })

keymap.set('n', '<leader>gp', function()
    require("core.git-commands").pull()
end, { remap = false, desc = "Git: Pull" })

keymap.set('n', '<leader>gP', function()
    require("core.git-commands").push()
end, { remap = false, desc = "Git: Push" })

keymap.set('n', '<leader>gb', function()
    require("core.git-commands").new_branch()
end, { remap = false, desc = "Git: Nueva rama" })

keymap.set('n', '<leader>go', function()
    require("core.git-commands").checkout()
end, { remap = false, desc = "Git: Checkout rama" })

keymap.set('n', '<leader>gs', function()
    require("core.git-commands").status()
end, { remap = false, desc = "Git: Status" })

keymap.set('n', '<leader>gr', function()
    require("core.git-commands").restore()
end, { remap = false, desc = "Git: Restore (deshacer cambios)" })

keymap.set('n', '<leader>gC', function()
    require("core.git-commands").commit_and_push()
end, { remap = false, desc = "Git: Add + Commit + Push" })

-- ============================================================================
-- OPENCODE MENU (Leader + a)
-- ============================================================================
-- Leader + a + a → Abrir/cerrar panel de opencode
keymap.set('n', '<leader>aa', function()
    require("core.opencode-panel").toggle()
end, { remap = false, desc = "Abrir/cerrar OpenCode" })

-- Leader + a + g → Abrir/cerrar panel de gemini
keymap.set('n', '<leader>ag', function()
    require("core.gemini-panel").toggle()
end, { remap = false, desc = "Abrir/cerrar Gemini" })

-- Leader + a + c → Consultar sobre lo seleccionado
keymap.set('v', '<leader>ac', function()
    require("core.opencode-panel").ask_about_selection()
end, { remap = false, desc = "Consultar sobre selección" })

-- Leader + a + s → Consultar sobre el buffer activo
keymap.set('n', '<leader>as', function()
    require("core.opencode-panel").ask_about_buffer()
end, { remap = false, desc = "Consultar sobre buffer activo" })

-- ============================================================================
-- 10. TELESCOPE (Búsqueda de Archivos y Texto)
-- ============================================================================
-- Buscador rápido de archivos (space + space)
keymap.set('n', '<leader><leader>', '<cmd>Telescope find_files<cr>', { desc = "Buscar archivos (rápido)" })

-- Buscador de palabras entre todos los archivos (space + b)
keymap.set('n', '<leader>b', '<cmd>Telescope live_grep<cr>', { desc = "Buscar palabras en archivos" })

-- Atajos adicionales de Telescope
keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = "Buscar archivos" })
keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "Buscar texto (grep)" })
keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "Ver buffers abiertos" })
keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = "Buscar en ayuda" })
keymap.set('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', { desc = "Símbolos del documento" })
keymap.set('n', '<leader>fw', '<cmd>Telescope lsp_workspace_symbols<cr>', { desc = "Símbolos del workspace" })
keymap.set('n', '<leader>fr', '<cmd>Telescope lsp_references<cr>', { desc = "Referencias LSP" })
keymap.set('n', '<leader>fi', '<cmd>Telescope lsp_implementations<cr>', { desc = "Implementaciones LSP" })

-- ============================================================================
-- 11. TROUBLE (Lista de Errores y Diagnósticos)
-- ============================================================================
keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",
    { remap = false, desc = "Trouble: Todos los errores" })
keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    { remap = false, desc = "Trouble: Errores del archivo" })
keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",
    { remap = false, desc = "Trouble: Símbolos" })
keymap.set("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
    { remap = false, desc = "Trouble: Info LSP" })

-- ============================================================================
-- 12. LSP - NAVEGACIÓN DE CÓDIGO (Todos los lenguajes)
-- ============================================================================
keymap.set('n', 'gd', vim.lsp.buf.definition, { remap = false, desc = "LSP: Ir a definición" })
keymap.set('n', 'gD', vim.lsp.buf.declaration, { remap = false, desc = "LSP: Ir a declaración" })
keymap.set('n', 'gi', vim.lsp.buf.implementation, { remap = false, desc = "LSP: Ir a implementación" })
keymap.set('n', 'gr', vim.lsp.buf.references, { remap = false, desc = "LSP: Ver referencias" })
keymap.set('n', 'gt', vim.lsp.buf.type_definition, { remap = false, desc = "LSP: Ir a definición de tipo" })
keymap.set('n', 'K', vim.lsp.buf.hover, { remap = false, desc = "LSP: Mostrar documentación (hover)" })

-- ============================================================================
-- 13. LSP - REFACTORING Y ACCIONES
-- ============================================================================
keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { remap = false, desc = "LSP: Renombrar símbolo" })
keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { remap = false, desc = "LSP: Acciones de código" })
keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format({ async = true })
end, { remap = false, desc = "LSP: Formatear código" })

-- ============================================================================
-- 14. LSP - DIAGNÓSTICOS Y ERRORES
-- ============================================================================
keymap.set('n', '[d', vim.diagnostic.goto_prev, { remap = false, desc = "Diagnóstico anterior" })
keymap.set('n', ']d', vim.diagnostic.goto_next, { remap = false, desc = "Siguiente diagnóstico" })
keymap.set('n', '<leader>e', vim.diagnostic.open_float, { remap = false, desc = "Mostrar diagnóstico flotante" })
keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { remap = false, desc = "Lista de diagnósticos" })
keymap.set('n', '<C-.>', vim.diagnostic.open_float, { remap = false, desc = "Ver error en línea actual" })

-- ============================================================================
-- 15. JAVA - REFACTORING Y TESTING (Solo en archivos .java)
-- ============================================================================
-- Estos atajos se activan automáticamente en archivos Java vía ftplugin/java.lua
-- <leader>jo → Organizar imports
-- <leader>jv → Extraer variable (normal y visual)
-- <leader>jc → Extraer constante (normal y visual)
-- <leader>jm → Extraer método (visual)
-- <leader>tc → Ejecutar test de clase
-- <leader>tm → Ejecutar test del método actual

-- <leader>jc → Crear módulo Java
keymap.set('n', '<leader>jc', function()
    require("core.java-module-generator").create_java_module()
end, { remap = false, desc = "Java: Crear módulo (DDD)" })

-- <leader>jl → Insertar etiquetas lombok
keymap.set('n', '<leader>jl', function()
    if vim.bo.filetype == "java" then
        require("core.lombok-utils").insert_lombok_annotations()
    else
        vim.notify("Este atajo de teclado solo funciona en archivos Java.", vim.log.levels.WARN)
    end
end, { remap = false, desc = "Java: Insertar etiquetas lombok" })

-- <leader>jm → Insertar anotación @Document de Spring Data MongoDB
keymap.set('n', '<leader>jm', function()
    if vim.bo.filetype == "java" then
        require("core.spring-data-utils").insert_spring_document_annotation()
    else
        vim.notify("Este atajo de teclado solo funciona en archivos Java.", vim.log.levels.WARN)
    end
end, { remap = false, desc = "Java: Insertar @Document de Spring Data MongoDB" })

-- <leader>ji → Importar clase bajo el cursor
keymap.set('n', '<leader>ji', function()
    if vim.bo.filetype == "java" then
        require("core.java-import-utils").add_import_under_cursor()
    else
        vim.notify("Este atajo de teclado solo funciona en archivos Java.", vim.log.levels.WARN)
    end
end, { remap = false, desc = "Java: Importar clase bajo cursor" })



-- ============================================================================
-- 16. ARRANQUE DE APLICACIONES (Menú <leader>s)
-- ============================================================================
-- Requiere lua/core/runners.lua

-- Spring Boot
keymap.set('n', '<leader>ss', '<cmd>SpringBootRun<CR>', { remap = false, desc = "Spring Boot: Ejecutar" })
keymap.set('n', '<leader>sS', '<cmd>SpringBootStop<CR>', { remap = false, desc = "Spring Boot: Detener" })

keymap.set('n', '<leader>sr', '<cmd>ReactRouterRun<CR>', { remap = false, desc = "React Router 7: Ejecutar" })
keymap.set('n', '<leader>sR', '<cmd>ReactRouterStop<CR>', { remap = false, desc = "React Router 7: Detener" })

-- ============================================================================
-- 17. DOCKER (Menú <leader>k)
-- ============================================================================
-- Leader + k + u → Docker Compose Up (levantar contenedores)
keymap.set('n', '<leader>ku', function()
    require("core.docker-commands").compose_up()
end, { remap = false, desc = "Docker: Levantar contenedores (up)" })

-- Leader + k + d → Docker Compose Down (detener contenedores)
keymap.set('n', '<leader>kd', function()
    require("core.docker-commands").compose_down()
end, { remap = false, desc = "Docker: Detener contenedores (down)" })

-- Leader + k + l → Docker Compose Logs (ver logs)
keymap.set('n', '<leader>kl', function()
    require("core.docker-commands").compose_logs()
end, { remap = false, desc = "Docker: Ver logs" })

-- Leader + k + s → Docker Compose PS (ver estado)
keymap.set('n', '<leader>ks', function()
    require("core.docker-commands").compose_ps()
end, { remap = false, desc = "Docker: Ver estado de contenedores" })

-- ============================================================================
-- 18. DEBUGGER (DAP) - Todos los lenguajes
-- ============================================================================
keymap.set("n", "<F5>", function() require('dap').continue() end, { remap = false, desc = "Debug: Iniciar/Continuar" })
keymap.set("n", "<F10>", function() require('dap').step_over() end,
    { remap = false, desc = "Debug: Paso sobre (Step Over)" })
keymap.set("n", "<F11>", function() require('dap').step_into() end,
    { remap = false, desc = "Debug: Paso dentro (Step Into)" })
keymap.set("n", "<F12>", function() require('dap').step_out() end,
    { remap = false, desc = "Debug: Paso fuera (Step Out)" })
keymap.set("n", "<leader>db", function() require('dap').toggle_breakpoint() end,
    { remap = false, desc = "Debug: Toggle breakpoint" })
keymap.set("n", "<leader>dB", function()
    require('dap').set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { remap = false, desc = "Debug: Breakpoint condicional" })
keymap.set("n", "<leader>dr", function() require('dap').repl.open() end, { remap = false, desc = "Debug: Abrir REPL" })
keymap.set("n", "<leader>dl", function() require('dap').run_last() end,
    { remap = false, desc = "Debug: Ejecutar último" })
keymap.set("n", "<leader>du", function() require('dapui').toggle() end, { remap = false, desc = "Debug: Toggle UI" })

-- ============================================================================
-- 19. ZOOM DUAL (Kitty + Neovim)
-- ============================================================================
local zoom = require('core.zoom')

-- Zoom de fuente (Terminal-Side via Kitty)
keymap.set('n', '<leader>z+', zoom.zoom_in, { remap = false, desc = "Zoom: Aumentar fuente" })
keymap.set('n', '<leader>z-', zoom.zoom_out, { remap = false, desc = "Zoom: Disminuir fuente" })
keymap.set('n', '<leader>z=', zoom.zoom_in, { remap = false, desc = "Zoom: Aumentar fuente" })
keymap.set('n', '<leader>z0', zoom.reset_font_size, { remap = false, desc = "Zoom: Resetear fuente" })

-- Zoom de ventana (Neovim-Side)
keymap.set('n', '<C-w>m', zoom.toggle_maximize, { remap = false, desc = "Zoom: Maximizar/Restaurar ventana" })
keymap.set('n', '<C-w>M', zoom.restore, { remap = false, desc = "Zoom: Restaurar ventana" })

-- Modo Focus (Combinado)
keymap.set('n', '<leader>zf', zoom.focus_mode, { remap = false, desc = "Zoom: Activar modo focus" })
keymap.set('n', '<leader>zF', zoom.exit_focus_mode, { remap = false, desc = "Zoom: Desactivar modo focus" })

-- ============================================================================
-- 20. BASE DE DATOS (nvim-dbee)
-- ============================================================================
-- <leader>D   → Abrir/Cerrar nvim-dbee (Shift+D para evitar conflicto con debugger)
-- <leader>dq  → Ejecutar query
--
-- Dentro del Drawer (barra lateral):
-- o/l         → Navegar arriba/abajo (respeta tu layout)
-- k/ñ         → Navegar izquierda/derecha
-- ñ           → Expandir/colapsar nodos
-- <CR>        → Abrir/activar conexión o scratchpad
-- r           → Refrescar
-- cw          → Renombrar/editar
-- dd          → Eliminar
--
-- Dentro del Editor de Queries:
-- <leader>rr  → Ejecutar archivo completo
-- <leader>rs  → Ejecutar selección (modo visual)

-- ============================================================================
-- 21. AYUDA DE KEYMAPS
-- ============================================================================
-- <leader>? → Mostrar ventana flotante con todos los atajos
keymap.set('n', '<leader>?', function()
    require('core.keymaps-help').show()
end, { remap = false, desc = "Mostrar guía de atajos de teclado" })

-- ============================================================================
-- 22. AUTOCOMPLETADO E IMPORTACIONES (blink.cmp)
-- ============================================================================
-- Los siguientes atajos son manejados directamente por el plugin blink.cmp
-- en lua/plugins/completions.lua y funcionan en MODO INSERTAR:
--
-- <C-Space>   → Abrir menú de autocompletado / Ver opciones de importación
-- <CR> (Enter)→ Confirmar selección (e insertar import automáticamente)
-- <Tab>       → Siguiente sugerencia
-- <S-Tab>     → Sugerencia anterior
--
-- Nota: En Modo Normal, <C-Space> no activa el menú. Debes entrar en modo
-- insertar (i, a, o) antes de usarlo.
keymap.set("n", "<C-Space>", "i<C-Space>", { remap = true, desc = "Entrar en Insert y Autocompletar" })

-- ============================================================================
-- RESUMEN DE PREFIJOS Y ATAJOS RÁPIDOS
-- ============================================================================
-- ATAJOS RÁPIDOS:
-- <leader><leader> → Buscar archivos (Telescope)
-- <leader>b        → Buscar palabras en archivos (Telescope grep)
-- <leader>?        → Mostrar ayuda de atajos de teclado
--
-- PREFIJOS:
-- <leader>g*  → Git (gg: lazygit, ga: add, gc: commit, gC: add+commit+push, gp: pull, gP: push, gb: nueva rama, go: checkout, gs: status, gr: restore)
-- <leader>a*  → OpenCode/Gemini (aa: abrir/cerrar OpenCode, ag: abrir/cerrar Gemini, ac: consultar selección, as: consultar buffer)
-- <leader>f*  → Telescope (búsqueda de archivos y texto)
-- <leader>x*  → Trouble (errores y diagnósticos)
-- <leader>j*  → Java refactoring
-- <leader>t*  → Testing (Java)
-- <leader>k*  → Docker (ku: up, kd: down, kl: logs, ks: status)
-- <leader>d*  → Debugger (DAP)
-- <leader>D   → Database (nvim-dbee)
-- <leader>z*  → Zoom y Focus mode
-- <leader>ca  → Code actions (LSP)
-- <leader>rn  → Rename (LSP)
-- <leader>r*  → Run queries (nvim-dbee)
-- <leader>1-9   → Saltar a buffer específico
-- <M-s/S>       → Spring Boot run/stop
-- <M-k/ñ>       → Navegar entre buffers (anterior/siguiente)
-- <M-o/l>       → Scroll up/down (desplazamiento en documento)
-- <C-k/l/o/ñ>   → Navegar entre ventanas (izq/abajo/arriba/der)
-- <F5-F12>      → Debugger controls
-- <leader>z+/-  → Zoom de fuente (Kitty)
-- <C-w>m/M      → Maximizar/Restaurar ventana
-- Ctrl+Shift+=/- → Zoom nativo de Kitty (fuera de Neovim)
-- gd/gD/gi/gr → LSP navigation
