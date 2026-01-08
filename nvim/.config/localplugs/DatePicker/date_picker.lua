local M = {}

-- ==========================================================
-- 1. Minimal Date Helper
-- ==========================================================
local Date = {}
Date.__index = Date
function Date.new(year, month, day, hour, min)
  local time = os.time({ year = year, month = month, day = day, hour = hour or 0, min = min or 0 })
  local d = os.date("*t", time)
  return setmetatable(d, Date)
end

function Date.today()
  local now = os.date("*t")
  return Date.new(now.year, now.month, now.day, now.hour, now.min)
end

function Date:format(fmt) return os.date(fmt, os.time(self)) end

function Date:start_of_month() return Date.new(self.year, self.month, 1) end

function Date:end_of_month()
  local time = os.time({ year = self.year, month = self.month + 1, day = 0 })
  local d = os.date("*t", time)
  return setmetatable(d, Date)
end

function Date:add_months(n)
  return Date.new(self.year, self.month + n, self.day)
end

function Date:set_day(d) return Date.new(self.year, self.month, d, self.hour, self.min) end

function Date:get_month_calendar_rows(start_monday)
  local first = self:start_of_month()
  local last = self:end_of_month()
  local dates = {}
  
  for d = 1, last.day do table.insert(dates, Date.new(self.year, self.month, d)) end

  local start_weekday = os.date("*t", os.time(first)).wday -- Sun=1
  local target_wday = start_monday and 2 or 1
  local pad = start_weekday - target_wday
  if pad < 0 then pad = pad + 7 end

  local grid = {}
  local row = {}
  
  for _ = 1, pad do table.insert(row, "  ") end

  for _, dayObj in ipairs(dates) do
    local day_str = string.format("%02d", dayObj.day)
    table.insert(row, day_str)
    if #row == 7 then
      table.insert(grid, row)
      row = {}
    end
  end
  
  if #row > 0 then
    while #row < 7 do table.insert(row, "  ") end
    table.insert(grid, row)
  end
  
  return grid
end


-- ==========================================================
-- 2. The Calendar Picker
-- ==========================================================
local Calendar = {}
Calendar.__index = Calendar

-- CONFIG: Adjusted width to 38 to fit footer and loose grid
local config = {
  width = 38,
  height = 16,
  border = "rounded",
  hl = {
    today = "Special",    
    cursor = "Reverse",   
    header = "Title",
    comment = "Comment",
  }
}

function M.open()
  local self = setmetatable({}, Calendar)
  self.date = Date.today()
  self.today = Date.today()
  self.callback = nil
  
  local buf = vim.api.nvim_create_buf(false, true)
  local win_opts = {
    relative = 'editor',
    width = config.width,
    height = config.height,
    style = 'minimal',
    border = config.border,
    row = (vim.o.lines - config.height) / 2,
    col = (vim.o.columns - config.width) / 2,
    title = ' Set deadline ',
    title_pos = 'center',
  }
  
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  self.buf = buf
  self.win = win

  vim.bo[buf].bufhidden = "wipe"
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,Cursor:Inverse"
  
  local function map(key, fn)
    vim.keymap.set('n', key, fn, { buffer = buf, nowait = true, silent = true })
  end
  
  map('q', function() self:close() end)
  map('<Esc>', function() self:close() end)
  map('>', function() self.date = self.date:add_months(1); self:render() end)
  map('<', function() self.date = self.date:add_months(-1); self:render() end)
  map('.', function() self.date = Date.today(); self:render() end)
  map('<CR>', function() self:select() end)
  
  self:render()
  
  return {
    on_select = function(_, cb) self.callback = cb end
  }
end

function Calendar:close()
  if self.win and vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, true)
  end
end

function Calendar:select()
  local word = vim.fn.expand('<cword>')
  local day = tonumber(word)
  
  if day then
    local final_date = self.date:set_day(day)
    local date_str = final_date:format("%Y-%m-%d")
    self:close()
    if self.callback then self.callback(date_str) end
  else
    vim.notify("Please select a day", vim.log.levels.WARN)
  end
end

function Calendar:render()
  if not vim.api.nvim_buf_is_valid(self.buf) then return end
  
  local content = {}
  local highlights = {} 

  -- Centering Helper
  -- The grid content is 33 chars wide. Window is 38.
  -- 38 - 33 = 5. Left padding ~ 2 or 3.
  local content_width = 33
  local left_pad_len = math.floor((config.width - content_width) / 2)
  local left_pad = string.rep(" ", left_pad_len)

  -- 1. Header (Month Year)
  local header = self.date:format("%B %Y")
  local title_pad = math.floor((config.width - #header) / 2)
  table.insert(content, string.rep(" ", title_pad) .. header)
  table.insert(highlights, {config.hl.header, 0, 0, -1})
  
  -- 2. Weekdays
  -- "Mon" (3) + 2 spaces = 5 chars stride.
  local days = "Mon  Tue  Wed  Thu  Fri  Sat  Sun"
  table.insert(content, left_pad .. days)
  table.insert(highlights, {config.hl.comment, 1, 0, -1})
  
  -- 3. Grid
  local grid = self.date:get_month_calendar_rows(true)
  
  for i, row in ipairs(grid) do
    -- "01" (2) + 3 spaces = 5 chars stride. Matches header.
    local line_str = left_pad .. table.concat(row, "   ") 
    table.insert(content, line_str)
    
    if self.date.year == self.today.year and self.date.month == self.today.month then
      for col_idx, day_str in ipairs(row) do
        if tonumber(day_str) == self.today.day then
          -- Calc start col: pad + (col-1)*5
          local start_col = left_pad_len + (col_idx - 1) * 5
          -- The number is 2 chars wide
          table.insert(highlights, {config.hl.today, #content-1, start_col, start_col + 2})
        end
      end
    end
  end
  
  -- Fill vertical space
  while #content < 8 do table.insert(content, "") end

  -- 4. Footer
  table.insert(content, "")
  local time_str = "--:--"
  local time_pad = math.floor((config.width - #time_str) / 2)
  table.insert(content, string.rep(" ", time_pad) .. time_str)
  table.insert(highlights, {config.hl.comment, #content-1, 0, -1})
  
  table.insert(content, "")
  -- Note: These strings are carefully length-checked for width=38
  table.insert(content, " [<] - prev month   [>] - next month")
  table.insert(content, " [.] - today        [Enter] - select")
  table.insert(content, " [i] - enter date   [r] - clear date")
  table.insert(content, " [t] - enter time")
  
  local footer_start = #content - 4
  for i = footer_start, #content do
    table.insert(highlights, {config.hl.comment, i-1, 0, -1})
  end

  -- Update Buffer
  vim.bo[self.buf].modifiable = true
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, content)
  vim.bo[self.buf].modifiable = false
  
  -- Apply Highlights
  local ns = vim.api.nvim_create_namespace('calendar_picker')
  vim.api.nvim_buf_clear_namespace(self.buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(self.buf, ns, hl[1], hl[2], hl[3], hl[4])
  end
  
  -- 5. Position Cursor
  local target_day = 1
  if self.date.year == self.today.year and self.date.month == self.today.month then
    target_day = self.today.day
  end
  
  local cursor_pos = {3, 2}
  for r, row in ipairs(grid) do
    for c, day_str in ipairs(row) do
      if tonumber(day_str) == target_day then
         local row_idx = 2 + r 
         -- pad + (c-1)*5
         local col_idx = left_pad_len + (c-1) * 5
         cursor_pos = {row_idx, col_idx}
         break
      end
    end
  end
  pcall(vim.api.nvim_win_set_cursor, self.win, cursor_pos)
end

return M
