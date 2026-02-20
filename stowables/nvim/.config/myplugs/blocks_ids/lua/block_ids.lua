print("loaded plug")
local M = {}

local scan = require("plenary.scandir")
local Path = require("plenary.path")

local vault_path = "/home/sybil/Documents/School/2026-Spring/MATH-341/Notes-MATH(341)"
local block_ids = {}

-- Scan vault for block IDs
function M.index()
  block_ids = {}

  local files = scan.scan_dir(vault_path, {
    search_pattern = "%.md$",
    hidden = false,
  })

  for _, file in ipairs(files) do
    for line in io.lines(file) do
      local id = line:match("%^([%w%-_]+)")
      if id then
        table.insert(block_ids, id)
      end
    end
  end
end

-- nvim-cmp source
M.new = function()
  return {
    complete = function(_, params, callback)
      local line = params.context.cursor_before_line
      if not line:match("%^%w*$") then
        return callback({ isIncomplete = false, items = {} })
      end

      local items = {}
      for _, id in ipairs(block_ids) do
        table.insert(items, {
          label = id,
          kind = 1,
        })
      end

      callback({ isIncomplete = false, items = items })
    end,
  }
end

return M

