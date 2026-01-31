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
keymap.set("n", "o", "k", { desc = "Mover arriba" })
keymap.set("n", "l", "j", { desc = "Mover abajo" })
keymap.set("n", "k", "h", { desc = "Mover izquierda" })
keymap.set("n", "ñ", "l", { desc = "Mover derecha" })

-- Modo Visual
keymap.set("v", "o", "k", { desc = "Mover arriba (visual)" })
keymap.set("v", "l", "j", { desc = "Mover abajo (visual)" })
keymap.set("v", "k", "h", { desc = "Mover izquierda (visual)" })
keymap.set("v", "ñ", "l", { desc = "Mover derecha (visual)" })

-- ============================================================================
-- 2. INSERCIÓN DE TEXTO
-- ============================================================================
keymap.set("n", "i", "i", { desc = "Insertar en posición actual" })
keymap.set("n", "p", "a", { desc = "Insertar a la derecha del cursor" })
keymap.set("n", "P", "A", { desc = "Insertar al final de la línea" })
keymap.set("n", "O", "O", { desc = "Insertar línea arriba" })
keymap.set("n", "L", "o", { desc = "Insertar línea abajo" })

-- ============================================================================
-- 3. ARCHIVOS Y EDICIÓN BÁSICA
-- ============================================================================
keymap.set("n", "e", "<cmd>Neotree toggle<cr>", { desc = "Abrir/Cerrar explorador de archivos" })
keymap.set("n", "w", ":w<CR>", { desc = "Guardar archivo" })
keymap.set("n", "q", ":bdelete<CR>", { desc = "Cerrar buffer actual" })
keymap.set("n", "z", "u", { desc = "Deshacer cambios" })
keymap.set("n", "Z", "<C-r>", { desc = "Rehacer cambios" })
keymap.set("n", "Q", ":qa!<CR>", { desc = "Cerrar todo y salir de Neovim" })

-- ============================================================================
-- 3.1. CORTAR, COPIAR Y PEGAR
-- ============================================================================
-- x abre el menú para cortar (funciona como d - delete)
keymap.set("n", "x", "d", { desc = "Menú de cortar (x + movimiento, o xx para línea)" })
keymap.set("n", "xx", "dd", { desc = "Cortar línea completa" })
keymap.set("v", "x", "d", { desc = "Cortar selección visual" })

-- c abre el menú para copiar (funciona como y - yank)
keymap.set("n", "c", "y", { desc = "Menú de copiar (c + movimiento, o cc para línea)" })
keymap.set("n", "cc", "yy", { desc = "Copiar línea completa" })
keymap.set("v", "c", "y", { desc = "Copiar selección visual" })

-- v para pegar después del cursor, V para pegar antes
keymap.set("n", "v", "p", { desc = "Pegar después del cursor" })
keymap.set("n", "V", "P", { desc = "Pegar antes del cursor" })
keymap.set("v", "v", "p", { desc = "Pegar en selección visual" })
keymap.set("v", "V", "P", { desc = "Pegar antes en selección visual" })

-- ============================================================================
-- 3.2. IDENTACIÓN
-- ============================================================================
-- > para identar a la derecha, < para identar a la izquierda
keymap.set("n", ">", ">>", { desc = "Identar línea a la derecha" })
keymap.set("n", "<", "<<", { desc = "Identar línea a la izquierda" })
keymap.set("v", ">", ">gv", { desc = "Identar selección a la derecha" })
keymap.set("v", "<", "<gv", { desc = "Identar selección a la izquierda" })

-- ============================================================================
-- 4. MOVIMIENTO ENTRE VENTANAS
-- ============================================================================
keymap.set("n", "<C-k>", "<C-w>h", { desc = "Ir a ventana izquierda" })
keymap.set("n", "<C-l>", "<C-w>j", { desc = "Ir a ventana abajo" })
keymap.set("n", "<C-ñ>", "<C-w>l", { desc = "Ir a ventana derecha" })
keymap.set("n", "<C-o>", "<C-w>k", { desc = "Ir a ventana arriba" })

-- ============================================================================
-- 5. NAVEGACIÓN ENTRE BUFFERS (Archivos Abiertos)
-- ============================================================================
keymap.set("n", "<M-k>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Buffer anterior" })
keymap.set("n", "<M-ñ>", "<cmd>BufferLineCycleNext<cr>", { desc = "Buffer siguiente" })
keymap.set("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Cerrar buffer actual" })

-- Saltos directos a buffers específicos
keymap.set("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", { desc = "Ir a buffer 1" })
keymap.set("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", { desc = "Ir a buffer 2" })
keymap.set("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", { desc = "Ir a buffer 3" })
keymap.set("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", { desc = "Ir a buffer 4" })
keymap.set("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", { desc = "Ir a buffer 5" })
keymap.set("n", "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", { desc = "Ir a buffer 6" })
keymap.set("n", "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", { desc = "Ir a buffer 7" })
keymap.set("n", "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", { desc = "Ir a buffer 8" })
keymap.set("n", "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", { desc = "Ir a buffer 9" })

-- ============================================================================
-- 6. NAVEGACIÓN DE EXTREMOS DE LÍNEA
-- ============================================================================
-- Modo Normal
keymap.set("n", "j", "^", { desc = "Ir al inicio de la línea" })
keymap.set("n", "{", "$", { desc = "Ir al final de la línea" })

-- Modo Visual
keymap.set("v", "j", "^", { desc = "Ir al inicio de la línea (visual)" })
keymap.set("v", "{", "$", { desc = "Ir al final de la línea (visual)" })

-- ============================================================================
-- 7. SELECCIÓN VISUAL (Sistema con 's' como prefijo)
-- ============================================================================
-- s → Entrar al modo visual (carácter por carácter)
-- sw → Seleccionar palabra
-- sl → Seleccionar línea completa
-- se → Seleccionar desde cursor hasta el final de línea
-- ss → Seleccionar desde cursor hasta el inicio de línea

keymap.set("n", "s", "v", { desc = "Entrar al modo visual" })
keymap.set("n", "sw", "viw", { desc = "Seleccionar palabra" })
keymap.set("n", "sl", "V", { desc = "Seleccionar línea completa" })
keymap.set("n", "se", "v$", { desc = "Seleccionar hasta el final de línea" })
keymap.set("n", "ss", "v^", { desc = "Seleccionar hasta el inicio de línea" })

-- Mantener compatibilidad con atajos anteriores
keymap.set("n", "K", "v^", { desc = "Seleccionar hasta el inicio de línea" })
keymap.set("n", "Ñ", "v$", { desc = "Seleccionar hasta el final de línea" })

-- Ctrl+d para seleccionar la palabra donde está el cursor (viw)
keymap.set("n", "<C-d>", "viw", { desc = "Seleccionar palabra completa bajo cursor" })

-- ============================================================================
-- 8. SCROLL Y CENTRADO
-- ============================================================================
-- Scroll 1/4 de página (en lugar de 1/2)
keymap.set("n", "<M-l>", function()
    local lines = math.floor(vim.api.nvim_win_get_height(0) / 4)
    vim.cmd("normal! " .. lines .. "jzz")
end, { desc = "Scroll down 1/4 de página y centrar" })

keymap.set("n", "<M-o>", function()
    local lines = math.floor(vim.api.nvim_win_get_height(0) / 4)
    vim.cmd("normal! " .. lines .. "kzz")
end, { desc = "Scroll up 1/4 de página y centrar" })

-- ============================================================================
-- 9. TERMINAL (ToggleTerm)
-- ============================================================================
-- Leader + t para abrir/cerrar terminal horizontal (ID 1)
keymap.set('n', '<leader>t', '<cmd>1ToggleTerm direction=horizontal<cr>', { desc = "Toggle terminal horizontal" })

-- Leader + T para abrir/cerrar terminal flotante (ID 2)
keymap.set('n', '<leader>T', '<cmd>2ToggleTerm direction=float<cr>', { desc = "Toggle terminal flotante" })

-- En modo terminal:
keymap.set('t', '<esc>', [[<C-\><C-n>]], { desc = "Salir del modo insert en terminal" })
keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { desc = "Terminal: ir a ventana izquierda" })
keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { desc = "Terminal: ir a ventana abajo" })
keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { desc = "Terminal: ir a ventana arriba" })
keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { desc = "Terminal: ir a ventana derecha" })

-- ============================================================================
-- GIT (Leader + g)
-- ============================================================================
-- Leader + g + g → Abrir/cerrar LazyGit (toggle)
keymap.set('n', '<leader>gg', function()
    require("core.lazygit-toggle").toggle()
end, { desc = "Git: LazyGit toggle" })

-- Leader + g + a → Git Add (agregar archivos al staging)
keymap.set('n', '<leader>ga', function()
    require("core.git-commands").add()
end, { desc = "Git: Add archivos" })

-- Leader + g + c → Git Commit (hacer commit)
keymap.set('n', '<leader>gc', function()
    require("core.git-commands").commit()
end, { desc = "Git: Commit" })

-- Leader + g + p → Git Pull (traer cambios)
keymap.set('n', '<leader>gp', function()
    require("core.git-commands").pull()
end, { desc = "Git: Pull" })

-- Leader + g + P → Git Push (enviar cambios)
keymap.set('n', '<leader>gP', function()
    require("core.git-commands").push()
end, { desc = "Git: Push" })

-- Leader + g + b → Git New Branch (crear rama nueva + checkout)
keymap.set('n', '<leader>gb', function()
    require("core.git-commands").new_branch()
end, { desc = "Git: Nueva rama" })

-- Leader + g + o → Git Checkout (cambiar de rama)
keymap.set('n', '<leader>go', function()
    require("core.git-commands").checkout()
end, { desc = "Git: Checkout rama" })

-- Leader + g + s → Git Status (ver estado)
keymap.set('n', '<leader>gs', function()
    require("core.git-commands").status()
end, { desc = "Git: Status" })

-- Leader + g + r → Git Restore (deshacer cambios de archivo)
keymap.set('n', '<leader>gr', function()
    require("core.git-commands").restore()
end, { desc = "Git: Restore (deshacer cambios)" })

-- Leader + g + C → Git Commit and Push (add . + commit + push)
keymap.set('n', '<leader>gC', function()
    require("core.git-commands").commit_and_push()
end, { desc = "Git: Add + Commit + Push" })

-- ============================================================================
-- OPENCODE MENU (Leader + a)
-- ============================================================================
-- Leader + a + a → Abrir/cerrar panel de opencode
keymap.set('n', '<leader>aa', function()
    require("core.opencode-panel").toggle()
end, { desc = "Abrir/cerrar OpenCode" })

-- Leader + a + g → Abrir/cerrar panel de gemini
keymap.set('n', '<leader>ag', function()
    require("core.gemini-panel").toggle()
end, { desc = "Abrir/cerrar Gemini" })

-- Leader + a + c → Consultar sobre lo seleccionado
keymap.set('v', '<leader>ac', function()
    require("core.opencode-panel").ask_about_selection()
end, { desc = "Consultar sobre selección" })

-- Leader + a + s → Consultar sobre el buffer activo
keymap.set('n', '<leader>as', function()
    require("core.opencode-panel").ask_about_buffer()
end, { desc = "Consultar sobre buffer activo" })

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
keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: Todos los errores" })
keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    { desc = "Trouble: Errores del archivo" })
keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Trouble: Símbolos" })
keymap.set("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
    { desc = "Trouble: Info LSP" })

-- ============================================================================
-- 12. LSP - NAVEGACIÓN DE CÓDIGO (Todos los lenguajes)
-- ============================================================================
keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "LSP: Ir a definición" })
keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "LSP: Ir a declaración" })
keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "LSP: Ir a implementación" })
keymap.set('n', 'gr', vim.lsp.buf.references, { desc = "LSP: Ver referencias" })
keymap.set('n', 'gt', vim.lsp.buf.type_definition, { desc = "LSP: Ir a definición de tipo" })
keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "LSP: Mostrar documentación (hover)" })

-- ============================================================================
-- 13. LSP - REFACTORING Y ACCIONES
-- ============================================================================
keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "LSP: Renombrar símbolo" })
keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "LSP: Acciones de código" })
keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format({ async = true })
end, { desc = "LSP: Formatear código" })

-- ============================================================================
-- 14. LSP - DIAGNÓSTICOS Y ERRORES
-- ============================================================================
keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Diagnóstico anterior" })
keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Siguiente diagnóstico" })
keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Mostrar diagnóstico flotante" })
keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Lista de diagnósticos" })
keymap.set('n', '<C-.>', vim.diagnostic.open_float, { desc = "Ver error en línea actual" })

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

-- ============================================================================
-- 16. ARRANQUE DE APLICACIONES (Menú <leader>s)
-- ============================================================================
-- Requiere lua/core/runners.lua

-- Spring Boot
keymap.set('n', '<leader>ss', '<cmd>SpringBootRun<CR>', { desc = "Spring Boot: Ejecutar" })
keymap.set('n', '<leader>sS', '<cmd>SpringBootStop<CR>', { desc = "Spring Boot: Detener" })

-- React Router 7
keymap.set('n', '<leader>sr', '<cmd>ReactRouterRun<CR>', { desc = "React Router 7: Ejecutar" })
keymap.set('n', '<leader>sR', '<cmd>ReactRouterStop<CR>', { desc = "React Router 7: Detener" })

-- ============================================================================
-- 17. DOCKER (Menú <leader>k)
-- ============================================================================
-- Leader + k + u → Docker Compose Up (levantar contenedores)
keymap.set('n', '<leader>ku', function()
    require("core.docker-commands").compose_up()
end, { desc = "Docker: Levantar contenedores (up)" })

-- Leader + k + d → Docker Compose Down (detener contenedores)
keymap.set('n', '<leader>kd', function()
    require("core.docker-commands").compose_down()
end, { desc = "Docker: Detener contenedores (down)" })

-- Leader + k + l → Docker Compose Logs (ver logs)
keymap.set('n', '<leader>kl', function()
    require("core.docker-commands").compose_logs()
end, { desc = "Docker: Ver logs" })

-- Leader + k + s → Docker Compose PS (ver estado)
keymap.set('n', '<leader>ks', function()
    require("core.docker-commands").compose_ps()
end, { desc = "Docker: Ver estado de contenedores" })

-- ============================================================================
-- 18. DEBUGGER (DAP) - Todos los lenguajes
-- ============================================================================
keymap.set("n", "<F5>", function() require('dap').continue() end, { desc = "Debug: Iniciar/Continuar" })
keymap.set("n", "<F10>", function() require('dap').step_over() end, { desc = "Debug: Paso sobre (Step Over)" })
keymap.set("n", "<F11>", function() require('dap').step_into() end, { desc = "Debug: Paso dentro (Step Into)" })
keymap.set("n", "<F12>", function() require('dap').step_out() end, { desc = "Debug: Paso fuera (Step Out)" })
keymap.set("n", "<leader>db", function() require('dap').toggle_breakpoint() end, { desc = "Debug: Toggle breakpoint" })
keymap.set("n", "<leader>dB", function()
    require('dap').set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Breakpoint condicional" })
keymap.set("n", "<leader>dr", function() require('dap').repl.open() end, { desc = "Debug: Abrir REPL" })
keymap.set("n", "<leader>dl", function() require('dap').run_last() end, { desc = "Debug: Ejecutar último" })
keymap.set("n", "<leader>du", function() require('dapui').toggle() end, { desc = "Debug: Toggle UI" })

-- ============================================================================
-- 19. ZOOM DUAL (Kitty + Neovim)
-- ============================================================================
local zoom = require('core.zoom')

-- Zoom de fuente (Terminal-Side via Kitty)
keymap.set('n', '<leader>z+', zoom.zoom_in, { desc = "Zoom: Aumentar fuente" })
keymap.set('n', '<leader>z-', zoom.zoom_out, { desc = "Zoom: Disminuir fuente" })
keymap.set('n', '<leader>z=', zoom.zoom_in, { desc = "Zoom: Aumentar fuente" })
keymap.set('n', '<leader>z0', zoom.reset_font_size, { desc = "Zoom: Resetear fuente" })

-- Zoom de ventana (Neovim-Side)
keymap.set('n', '<C-w>m', zoom.toggle_maximize, { desc = "Zoom: Maximizar/Restaurar ventana" })
keymap.set('n', '<C-w>M', zoom.restore, { desc = "Zoom: Restaurar ventana" })

-- Modo Focus (Combinado)
keymap.set('n', '<leader>zf', zoom.focus_mode, { desc = "Zoom: Activar modo focus" })
keymap.set('n', '<leader>zF', zoom.exit_focus_mode, { desc = "Zoom: Desactivar modo focus" })

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
end, { desc = "Mostrar guía de atajos de teclado" })

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
