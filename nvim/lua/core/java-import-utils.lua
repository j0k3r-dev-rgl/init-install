local M = {}

function M.add_import_under_cursor()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    local jdtls_client = nil
    for _, client in ipairs(clients) do
        if client.name == 'jdtls' then
            jdtls_client = client
            break
        end
    end

    if not jdtls_client then
        vim.notify("JDTLS is not active for this buffer. Please ensure jdtls is running and attached.", vim.log.levels.WARN)
        return
    end

    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    local lsp_row = cursor_row - 1
    local lsp_col = cursor_col

    local range_param = {
        start = { line = lsp_row, character = lsp_col },
        ['end'] = { line = lsp_row, character = lsp_col },
    }

    -- Request ALL code actions (for debugging purposes)
    vim.lsp.buf_request(bufnr, 'textDocument/codeAction', {
        textDocument = { uri = vim.uri_from_bufnr(bufnr) },
        range = range_param,
        context = {
            diagnostics = {},
            -- Removed 'only' filter to see all available actions
            triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
        },
    }, function(err, result, ctx) 
        if err then
            vim.notify("Error requesting code actions: " .. err, vim.log.levels.ERROR)
            return
        end

        if not result or #result == 0 then
            vim.notify("No code actions found under cursor.", vim.log.levels.INFO)
            return
        end

        local debug_output = {"Available Code Actions:"}
        for _, action in ipairs(result) do
            table.insert(debug_output, "  - Title: '" .. (action.title or "N/A") .. "', Kind: '" .. (action.kind or "N/A") .. "'")
        end

        -- Dump output to split window or notification
        local total_chars = 0
        for _, str in ipairs(debug_output) do
            total_chars = total_chars + #str
        end
        local max_notify_chars = 1000
        if total_chars > max_notify_chars or #debug_output > 20 then
            vim.cmd('split')
            vim.cmd('enew')
            vim.api.nvim_buf_set_lines(0, 0, -1, false, debug_output)
            vim.api.nvim_buf_set_option(0, 'buftype', 'nofile')
            vim.api.nvim_buf_set_option(0, 'bufhidden', 'wipe')
            vim.api.nvim_buf_set_option(0, 'readonly', true)
            vim.api.nvim_set_current_win(vim.api.nvim_list_wins()[1])
            vim.notify("Code Actions dumped to new split window. Use :q to close it.", vim.log.levels.INFO)
        else
            vim.notify(table.concat(debug_output, "\n"), vim.log.levels.INFO)
        end
    end)
end

return M
