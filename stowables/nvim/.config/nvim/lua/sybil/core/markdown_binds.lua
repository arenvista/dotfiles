local function obsidian_callout()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- 1. Get visual selection range before opening Telescope
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2] - 1
    local end_line = end_pos[2]
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)

    -- 2. Exit visual mode immediately so the UI is clean
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

    -- 3. Define Callout options
    local callouts = {
        "NOTE", "TIP", "IMPORTANT", "WARNING", "CAUTION",
        "INFO", "TODO", "ABSTRACT", "SUCCESS", "QUESTION",
        "FAILURE", "DANGER", "BUG", "EXAMPLE", "QUOTE",
    }

    -- 4. Open Telescope Picker
    pickers
        .new({}, {
            prompt_title = "Select Callout Type",
            finder = finders.new_table({ results = callouts }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)

                    -- 5. Prompt for Title using native input (Telescope handles its own UI)
                    vim.ui.input({ prompt = "Callout Title (optional): " }, function(title)
                        local header = "> [!" .. selection[1] .. "]"
                        if title and title ~= "" then
                            header = header .. " " .. title
                        end

                        local new_lines = { header }
                        for _, line in ipairs(lines) do
                            -- Check if line is empty to prevent trailing whitespace
                            if line == "" then
                                table.insert(new_lines, ">")
                            else
                                table.insert(new_lines, "> " .. line)
                            end
                        end

                        vim.api.nvim_buf_set_lines(buf, start_line, end_line, false, new_lines)
                    end)
                end)
                return true
            end,
        })
        :find()
end

-- Create the keymap (Visual Mode only)
-- Press <leader>cc to trigger
vim.keymap.set("v", "<leader>cc", obsidian_callout, { desc = "Wrap selection in Obsidian Callout" })

-- File: init.lua

-- 1. Add Callout Level (Auto-Nesting with Text)
-- Usage: Visually select text, press R
vim.keymap.set("v", "<leader>r", function()
    local r1 = vim.fn.line("v")
    local r2 = vim.fn.line(".")
    local start_row = math.min(r1, r2) - 1
    local end_row = math.max(r1, r2)
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
    
    local new_lines = {}
    local level = 0
    
    for _, line in ipairs(lines) do
        -- Increment nesting level when any [!tag] is found
        if line:match("^%s*%[%!%w+%]") then
            level = level + 1
        end
        
        if level > 0 then
            -- Handle empty lines cleanly (e.g., "> >" instead of "> > ")
            if line == "" or line:match("^%s*$") then
                local prefix = string.rep("> ", level):gsub("%s+$", "")
                table.insert(new_lines, prefix)
            else
                local prefix = string.rep("> ", level)
                table.insert(new_lines, prefix .. line)
            end
        else
            table.insert(new_lines, line)
        end
    end

    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, new_lines)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end, { silent = true, desc = "Add Nested Callout with Text Blocks" })


-- 2. Undo All Formatting (Strip Quotes & Headers)
-- Usage: Visually select text, press U
vim.keymap.set("v", "U", function()
    local r1 = vim.fn.line("v")
    local r2 = vim.fn.line(".")
    local start_row = math.min(r1, r2) - 1
    local end_row = math.max(r1, r2)
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
    
    local new_lines = {}
    for _, line in ipairs(lines) do
        local clean_line = line
        
        -- Safely strip leading `>` and their trailing space without touching math indentations
        while clean_line:match("^%s*>") do
            clean_line = clean_line:gsub("^%s*>%s?", "")
        end
        
        -- Strip any markdown headers if they were added
        clean_line = clean_line:gsub("^#+%s+", "")
        
        table.insert(new_lines, clean_line)
    end

    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, new_lines)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end, { silent = true, desc = "Undo all Callout and Header formatting" })

-- 2. Remove Callout Level (Unwrap >)
--
-- Usage: Visually select text, press R
vim.keymap.set("v", "R", ":s/^/> /<CR>:nohl<CR>gv", {
    silent = true,
    desc = "Add Markdown Callout/Quote level",
})
-- (Keeping your unwrap function the exact same)
vim.keymap.set("v", "L", [[:s/^> \?//e<CR>:nohl<CR>gv]], {
    silent = true,
    desc = "Remove Markdown Callout/Quote level",
})

-- 3. Add Headers Only
-- Usage: Visually select text, press H
-- Add Headers (Matches Callout Depth)
-- Usage: Visually select text, press H
-- Fix: Reads the `>` prefix depth, creates a matching markdown header (#), 
--      and places it exactly one quote-level above the callout.
vim.keymap.set("v", "H", function()
    local r1 = vim.fn.line("v")
    local r2 = vim.fn.line(".")
    local start_row = math.min(r1, r2) - 1
    local end_row = math.max(r1, r2)
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
    
    local new_lines = {}

    for _, line in ipairs(lines) do
        -- Capture the > prefix (if any) and the text after the [!tag]
        local prefix, text = line:match("^([>%s]*)%[%!%w+%]%s*(.*)")
        
        if prefix and text then
            -- Count the number of '>' to determine heading level
            local _, depth = prefix:gsub(">", "")
            
            if depth > 0 then
                -- Drop the deepest '>' so the header sits one level up
                local header_prefix = (prefix:gsub(">%s*$", ""))
                -- Generate header hashes based on depth (max 6 for standard Markdown)
                local hashes = string.rep("#", math.min(depth, 6))
                
                table.insert(new_lines, header_prefix .. hashes .. " " .. text)
            else
                -- Fallback if there are no '>' characters yet
                table.insert(new_lines, "# " .. text)
            end
        end
        
        -- Always keep the original line intact below the header
        table.insert(new_lines, line)
    end

    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, new_lines)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end, { silent = true, desc = "Inject Headers matching callout depth" })


-- 4. Remove Headers Only
-- Usage: Visually select text, press <leader>x
vim.keymap.set("v", "<leader>h", function()
    local r1 = vim.fn.line("v")
    local r2 = vim.fn.line(".")
    local start_row = math.min(r1, r2) - 1
    local end_row = math.max(r1, r2)
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
    
    local new_lines = {}
    
    for _, line in ipairs(lines) do
        -- If a line is strictly a markdown header (even inside a blockquote), delete it.
        -- Otherwise, keep the line intact.
        if not line:match("^[>%s]*#+%s+.*") then
            table.insert(new_lines, line)
        end
    end

    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, new_lines)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end, { silent = true, desc = "Strip headers while keeping text and math" })
