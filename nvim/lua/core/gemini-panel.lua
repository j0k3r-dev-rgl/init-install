-- ============================================================================
-- Panel persistente de Gemini
-- Maneja la apertura/cierre del panel lateral manteniendo su tamaño
-- La sesión de gemini se mantiene activa entre abrir/cerrar
-- ============================================================================

local M = {}
local gemini_win = nil
local gemini_buf = nil
local gemini_job_id = nil
local panel_width = 60 -- Ancho por defecto, puede ser configurable

-- Crear o mostrar el panel de gemini
function M.toggle()
    -- Si la ventana ya existe y está visible, solo ocultarla (sin cerrar el proceso)
    if gemini_win and vim.api.nvim_win_is_valid(gemini_win) then
        -- Solo cerrar la ventana, mantener el buffer y el proceso vivos
        vim.api.nvim_win_close(gemini_win, false)
        gemini_win = nil
        return
    end

    -- Guardar ventana original
    local original_win = vim.api.nvim_get_current_win()

    -- Si el buffer ya existe (sesión previa), reutilizarlo
    if gemini_buf and vim.api.nvim_buf_is_valid(gemini_buf) then
        -- Recrear ventana con el buffer existente
        vim.cmd('topleft vertical ' .. panel_width .. 'split')
        gemini_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(gemini_win, gemini_buf)

        -- Configurar propiedades de la ventana
        vim.api.nvim_win_set_option(gemini_win, 'winfixwidth', true)
        vim.api.nvim_win_set_option(gemini_win, 'number', false)
        vim.api.nvim_win_set_option(gemini_win, 'relativenumber', false)
        vim.api.nvim_win_set_option(gemini_win, 'signcolumn', 'no')
        vim.api.nvim_win_set_option(gemini_win, 'foldcolumn', '0')
        vim.api.nvim_win_set_option(gemini_win, 'wrap', true)

        -- Enfocar el panel de gemini y entrar en modo insertar
        vim.api.nvim_set_current_win(gemini_win)
        vim.cmd('startinsert')
        return
    end

    -- Primera vez: crear buffer y proceso nuevo
    local cwd = vim.fn.getcwd()

    -- Crear buffer scratch persistente (no aparece en bufferline)
    gemini_buf = vim.api.nvim_create_buf(false, true)

    -- Configurar opciones del buffer para que no aparezca en la lista pero persista
    vim.api.nvim_buf_set_option(gemini_buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(gemini_buf, 'bufhidden', 'hide') -- 'hide' en lugar de 'wipe'
    vim.api.nvim_buf_set_option(gemini_buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(gemini_buf, 'buflisted', false)
    vim.api.nvim_buf_set_option(gemini_buf, 'filetype', 'gemini') -- Nuevo filetype

    -- Crear split vertical a la izquierda absoluta
    vim.cmd('topleft vertical ' .. panel_width .. 'split')
    gemini_win = vim.api.nvim_get_current_win()

    -- Asignar el buffer a la ventana
    vim.api.nvim_win_set_buf(gemini_win, gemini_buf)

    -- Configurar propiedades de la ventana para que sea fija
    vim.api.nvim_win_set_option(gemini_win, 'winfixwidth', true)
    vim.api.nvim_win_set_option(gemini_win, 'number', false)
    vim.api.nvim_win_set_option(gemini_win, 'relativenumber', false)
    vim.api.nvim_win_set_option(gemini_win, 'signcolumn', 'no')
    vim.api.nvim_win_set_option(gemini_win, 'foldcolumn', '0')
    vim.api.nvim_win_set_option(gemini_win, 'wrap', true)

    -- Ejecutar gemini en la terminal (solo la primera vez)
    gemini_job_id = vim.fn.termopen('gemini', { -- Assuming 'gemini' is the command
        cwd = cwd,
        on_exit = function()
            -- Limpiar completamente solo cuando el proceso termina
            if gemini_win and vim.api.nvim_win_is_valid(gemini_win) then
                pcall(vim.api.nvim_win_close, gemini_win, true)
            end
            if gemini_buf and vim.api.nvim_buf_is_valid(gemini_buf) then
                pcall(vim.api.nvim_buf_delete, gemini_buf, { force = true })
            end
            gemini_win = nil
            gemini_buf = nil
            gemini_job_id = nil
        end
    })

    -- Enfocar el panel de gemini
    vim.api.nvim_set_current_win(gemini_win)
end

return M
