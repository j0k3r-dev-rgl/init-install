local M = {}

-- Helper function to find class declaration and relevant line numbers
local function find_java_code_indices(lines)
    local class_line_idx = -1
    local last_import_line_idx = -1
    local package_line_idx = -1
    local first_annotation_line_idx = -1 -- Index of the first @... line before class

    for i, line in ipairs(lines) do
        -- Find package declaration
        if line:match("^%s*package%s+") then
            package_line_idx = i - 1
        end
        -- Find last import declaration
        if line:match("^%s*import%s+") then
            last_import_line_idx = i - 1
        end
        -- Find class declaration (very basic string find for debugging)
        if class_line_idx == -1 and line:find(" class ") then
            class_line_idx = i - 1
        end
        -- Find the first line that looks like an annotation above the class
        if line:match("^%s*@") and (class_line_idx == -1 or i - 1 < class_line_idx) then
            if first_annotation_line_idx == -1 then
                first_annotation_line_idx = i - 1
            end
        end
    end
    return class_line_idx, last_import_line_idx, package_line_idx, first_annotation_line_idx
end

-- Helper function to trim whitespace from a string
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Helper function to insert an import if not present, and return modified lines
-- It ensures one blank line after package and one blank line between imports and class/annotations
local function ensure_import(original_lines, import_statement, last_import_line_idx, package_line_idx)
    local new_lines = {}
    local import_inserted = false

    -- Check if import already exists
    for _, line in ipairs(original_lines) do
        if line:find(import_statement, 1, true) then
            return original_lines -- Import already present, return original lines
        end
    end

    local current_original_line_num = 0
    while current_original_line_num < #original_lines do
        local line = original_lines[current_original_line_num + 1]

        local insert_at_current_position = false
        if last_import_line_idx ~= -1 then -- If imports exist, insert after last one
            insert_at_current_position = (current_original_line_num == last_import_line_idx + 1)
        elseif package_line_idx ~= -1 then -- If no imports but package exists, insert after package
            insert_at_current_position = (current_original_line_num == package_line_idx + 1)
        else -- If neither package nor imports, insert at the very beginning (line 0)
            insert_at_current_position = (current_original_line_num == 0)
        end

        if not import_inserted and insert_at_current_position then
            -- Add a blank line if inserting after package and there's no blank line already
            if package_line_idx ~= -1 and current_original_line_num == package_line_idx + 1 then
                if #new_lines > 0 and trim(new_lines[#new_lines]) ~= "" and trim(line) ~= "" then
                    table.insert(new_lines, "")
                end
            end
            table.insert(new_lines, import_statement)
            import_inserted = true
        end

        table.insert(new_lines, line)
        current_original_line_num = current_original_line_num + 1
    end

    -- Edge case: if file was empty or only package and import was not added
    if not import_inserted then
        if package_line_idx == -1 and last_import_line_idx == -1 then -- Really empty file
             table.insert(new_lines, import_statement)
        else -- Should have been inserted by now, implies error or very unusual file structure
            -- Fallback: insert at the end if not found
            table.insert(new_lines, "") -- Ensure a newline
            table.insert(new_lines, import_statement)
        end
    end

    return new_lines
end


function M.insert_lombok_annotations()
    local current_buf = vim.api.nvim_get_current_buf()
    local original_lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    
    local class_line_idx, last_import_line_idx, package_line_idx, first_annotation_line_idx = find_java_code_indices(original_lines)

    if class_line_idx == -1 then
        vim.notify("Could not find class declaration. Please ensure there is a class declaration (e.g., 'public class MyClass') in the file.", vim.log.levels.ERROR)
        return
    end

    local lombok_import = "import lombok.*;"
    local lombok_annotations_str = "@Setter @Getter @NoArgsConstructor @AllArgsConstructor @Builder @ToString"

    -- 1. Process imports
    local lines_after_import_processing = ensure_import(original_lines, lombok_import, last_import_line_idx, package_line_idx)

    -- Recalculate indices because lines might have shifted due to import insertion
    class_line_idx, last_import_line_idx, package_line_idx, first_annotation_line_idx = find_java_code_indices(lines_after_import_processing)

    -- 2. Process annotations
    local final_lines = {}
    local annotation_merged = false
    local lombok_annotations_present = false

    local current_line_num = 0
    while current_line_num < #lines_after_import_processing do
        local line = lines_after_import_processing[current_line_num + 1]
        local trimmed_line = trim(line)

        -- If we are at the first annotation line or the class line (if no annotations)
        if not annotation_merged and (current_line_num == first_annotation_line_idx or
           (first_annotation_line_idx == -1 and current_line_num == class_line_idx)) then

            local target_annotation_line = (first_annotation_line_idx ~= -1) and lines_after_import_processing[first_annotation_line_idx + 1] or ""
            local target_annotation_line_trimmed = trim(target_annotation_line)

            -- Check if Lombok annotations are already present in the target annotation line
            if target_annotation_line_trimmed:find("Getter") and target_annotation_line_trimmed:find("Setter") then
                lombok_annotations_present = true
            end

            -- If there's an existing annotation line just before the class
            if target_annotation_line_trimmed:find("^@") then
                vim.notify("Lombok merge: existing line '" .. target_annotation_line_trimmed .. "'", vim.log.levels.INFO) -- DEBUG
                if not lombok_annotations_present then
                    -- Merge new Lombok annotations with existing ones, prepending them
                    table.insert(final_lines, lombok_annotations_str .. " " .. target_annotation_line_trimmed)
                else
                    -- Lombok annotations already exist, keep the line as is
                    table.insert(final_lines, line)
                end
                annotation_merged = true
            elseif current_line_num == class_line_idx and first_annotation_line_idx == -1 then
                -- No annotations found before class, insert new Lombok annotations
                table.insert(final_lines, lombok_annotations_str)
                annotation_merged = true
                -- Ensure a blank line if inserting before class and not directly after imports
                if current_line_num > 0 and trim(lines_after_import_processing[current_line_num]) ~= "" and
                   (current_line_num > (last_import_line_idx ~= -1 and last_import_line_idx or package_line_idx) + 1) then
                    table.insert(final_lines, "")
                end
            end
        end

        -- Add the original line if it hasn't been handled (e.g., merged or skipped because it was an annotation line that got merged)
        if not (annotation_merged and first_annotation_line_idx ~= -1 and current_line_num == first_annotation_line_idx) then
             table.insert(final_lines, line)
        end
        current_line_num = current_line_num + 1
    end

    -- Ensure one blank line between imports block and annotations/class if it's not there
    local processed_final_lines_with_blanks = {}
    local import_block_end_idx = last_import_line_idx ~= -1 and last_import_line_idx or package_line_idx
    if import_block_end_idx ~= -1 then
        for i, line in ipairs(final_lines) do
            processed_final_lines_with_blanks[#processed_final_lines_with_blanks + 1] = line
            if i - 1 == import_block_end_idx and i < #final_lines then
                local next_line = final_lines[i + 1]
                if trim(next_line) ~= "" and not next_line:match("^%s*@") then
                    processed_final_lines_with_blanks[#processed_final_lines_with_blanks + 1] = ""
                end
            end
        end
        final_lines = processed_final_lines_with_blanks
    end


    vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, final_lines)
    vim.notify("Lombok annotations and import inserted.", vim.log.levels.INFO)
end


function M.debug_lines()
    local current_buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    local debug_output = {}

    for i, line in ipairs(lines) do
        local printable_chars = {}
        for j = 1, #line do
            local char_byte = string.byte(line, j)
            if (char_byte >= 0 and char_byte <= 31) or (char_byte >= 127 and char_byte <= 159) then
                table.insert(printable_chars, string.format("\\x%02x", char_byte))
            else
                table.insert(printable_chars, string.char(char_byte))
            end
        end
        local printable_line = table.concat(printable_chars)
        table.insert(debug_output, string.format("Line %d: '%s'", i, printable_line))
    end

    if #debug_output == 0 then
        vim.notify("Buffer is empty.", vim.log.levels.INFO)
    else
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
            vim.notify("Buffer content dumped to new split window. Use :q to close it.", vim.log.levels.INFO)
        else
            vim.notify(table.concat(debug_output, "\n"), vim.log.levels.INFO)
        end
    end
end

return M