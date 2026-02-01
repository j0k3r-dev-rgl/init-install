local M = {} -- Helper function to find class declaration and relevant line numbers
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
        -- Find class declaration (basic string find)
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


function M.insert_spring_document_annotation()
    local current_buf = vim.api.nvim_get_current_buf()
    local original_lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    
    local class_line_idx, last_import_line_idx, package_line_idx, first_annotation_line_idx = find_java_code_indices(original_lines)

    if class_line_idx == -1 then
        vim.notify("Could not find class declaration. Please ensure there is a class declaration (e.g., 'public class MyClass') in the file.", vim.log.levels.ERROR)
        return
    end

    local spring_import = "import org.springframework.data.mongodb.core.mapping.Document;"
    local spring_annotation_str = "@Document(collection = \"\")"

    -- 1. Process imports
    local lines_after_import_processing = ensure_import(original_lines, spring_import, last_import_line_idx, package_line_idx)

    -- Recalculate indices because lines might have shifted due to import insertion
    class_line_idx, last_import_line_idx, package_line_idx, first_annotation_line_idx = find_java_code_indices(lines_after_import_processing)

    -- 2. Process annotations
    local final_lines = {}
    local annotation_merged_or_inserted = false
    local spring_annotation_present = false
    local insertion_target_col = -1
    local inserted_annotation_line_idx = -1

    local current_line_num = 0
    while current_line_num < #lines_after_import_processing do
        local line = lines_after_import_processing[current_line_num + 1]
        local trimmed_line = trim(line)

        -- If we are at the first annotation line or the class line (if no annotations)
        if not annotation_merged_or_inserted and (current_line_num == first_annotation_line_idx or
           (first_annotation_line_idx == -1 and current_line_num == class_line_idx)) then

            local target_annotation_line = (first_annotation_line_idx ~= -1) and lines_after_import_processing[first_annotation_line_idx + 1] or ""
            local target_annotation_line_trimmed = trim(target_annotation_line)

            -- Check if Spring annotation is already present in the target annotation line
            if target_annotation_line_trimmed:find("@Document") then
                spring_annotation_present = true
            end

            -- If there's an existing annotation line just before the class
            if target_annotation_line_trimmed:find("^@") then
                if not spring_annotation_present then
                    -- Merge new Spring annotation with existing ones
                    table.insert(final_lines, target_annotation_line_trimmed .. " " .. spring_annotation_str)
                    -- Calculate target_col for cursor
                    insertion_target_col = #target_annotation_line_trimmed + 1 + string.find(spring_annotation_str, 'collection = "') + #('collection = "') - 1
                else
                    -- Spring annotation already exists, keep the line as is
                    table.insert(final_lines, line)
                end
                inserted_annotation_line_idx = #final_lines - 1 -- 0-indexed line in final_lines
                annotation_merged_or_inserted = true
            elseif current_line_num == class_line_idx and first_annotation_line_idx == -1 then
                -- No annotations found before class, insert new Spring annotation
                table.insert(final_lines, spring_annotation_str)
                insertion_target_col = string.find(spring_annotation_str, 'collection = "') + #('collection = "') - 1
                inserted_annotation_line_idx = #final_lines - 1 -- 0-indexed line in final_lines
                annotation_merged_or_inserted = true
            end
        end

        -- Add the original line if it hasn't been handled (e.g., merged or skipped because it was an annotation line that got merged)
        if not (annotation_merged_or_inserted and first_annotation_line_idx ~= -1 and current_line_num == first_annotation_line_idx) then
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
                    -- If next line is not blank and not an annotation, add a blank line
                    processed_final_lines_with_blanks[#processed_final_lines_with_blanks + 1] = ""
                end
            end
        end
        final_lines = processed_final_lines_with_blanks
    end


    vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, final_lines)
    vim.notify("Spring @Document annotation and import inserted.", vim.log.levels.INFO)

    -- Move cursor and enter insert mode
    if inserted_annotation_line_idx ~= -1 and insertion_target_col ~= -1 then
        local target_line_1_based = inserted_annotation_line_idx + 1 -- Convert to 1-based
        -- We want to go *inside* the quotes, so add 1 to the column
        vim.api.nvim_win_set_cursor(0, {target_line_1_based, insertion_target_col + 1})
        vim.cmd('startinsert!')
    end
end

return M