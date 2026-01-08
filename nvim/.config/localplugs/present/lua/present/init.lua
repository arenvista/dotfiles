local M = {}

M.setup = function(opts)
    print("My Cool Plugin is loaded!")
end

M.say_hello = function()
    print("Hello from local plugin!")
end

-- Fixed: changed arg 'config' to 'opts' to match usage inside
local function create_floating_window(opts, enter)
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.8)
    local height = opts.height or math.floor(vim.o.lines * 0.8)

    -- Find Center
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2) -- Fixed: changed 'col' to 'row'

    local buf = vim.api.nvim_create_buf(false, true)

    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded"
    }

    -- Fixed: passed 'win_config' (the table we just made) instead of 'config'
    local win = vim.api.nvim_open_win(buf, enter or false, win_config)

    return { buf = buf, win = win }
end

---@class present.Slides
---@field slides string[][]

---@param lines string[]
---@return present.Slides
local parse_slides = function(lines)
    local slides = { slides = {} }
    local current_slide = {}
    local separator = "^#"
    
    for _, line in ipairs(lines) do
        if line:find(separator) then
            if #current_slide > 0 then
                table.insert(slides.slides, current_slide)
            end
            current_slide = {}
        end
        table.insert(current_slide, line)
    end
    table.insert(slides.slides, current_slide)
    return slides
end

M.start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0 -- Fixed typo: bufrn -> bufnr
    
    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
    local parsed = parse_slides(lines)
    local float = create_floating_window(opts, true)

    local current_slide = 1
    local content = parsed.slides[current_slide] or {"No content"} -- Safety check in case file is empty

    vim.keymap.set("n", "n", function()
        current_slide = math.min(current_slide + 1, #parsed.slides)
        print("Current slide number: " .. current_slide)
        content = parsed.slides[current_slide] or {"No content"}
        vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, content)
    end,{
            buffer = float.buf
        })
    vim.keymap.set("n", "p", function()
        current_slide = math.max(current_slide - 1, 1) -- Fixed logic to prevent going below 1
        print("Current slide number: " .. current_slide)
        content = parsed.slides[current_slide] or {"No content"}
        vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, content)
    end,{
            buffer = float.buf
        })
    vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, content)
end

vim.api.nvim_create_user_command('StartPresentation', function(opts)
    -- Changed require('present') to M so this works if you source the file directly
    M.start_presentation({ bufnr = 3 })
end, {})

return M
