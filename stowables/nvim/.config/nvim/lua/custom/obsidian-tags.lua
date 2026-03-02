local cmp = require("cmp")
local Job = require("plenary.job")

local source = {}

source.new = function()
	local self = setmetatable({}, { __index = source })
	return self
end

local function get_file_name(path)
	return vim.fn.fnamemodify(path, ":t:r") -- filename without extension
end

source.complete = function(self, request, callback)
	local line = request.context.cursor_before_line
	-- Match ll plus optional letters/dashes (the tag)
	local prefix = line:match("ll[%w%-]*$")
	if not prefix then
		return callback({})
	end

	local search_term = prefix:sub(3) -- remove "ll"

	-- Use ripgrep to find all tags in Markdown files
	Job:new({
		command = "rg",
		args = { "--no-heading", "--with-filename", "--only-matching", "--glob", "*.md", "^" .. search_term },
		on_exit = function(j, return_val)
			if return_val ~= 0 then
				return callback({})
			end

			local items = {}
			local seen = {}

			for _, line in ipairs(j:result()) do
				local file, tag = line:match("([^:]+):(%^%S+)")
				if file and tag then
					local key = file .. tag
					if not seen[key] then
						table.insert(items, {
							label = string.format("[%s](%s#%s)", tag, get_file_name(file), tag),
							insertText = string.format("[%s](%s#%s)", tag, get_file_name(file), tag),
							kind = cmp.lsp.CompletionItemKind.Snippet,
						})
						seen[key] = true
					end
				end
			end

			callback(items)
		end,
	}):start()
end

-- Trigger on "l" (so typing "ll" triggers)
source.get_trigger_characters = function()
	return { "l" }
end

source.is_available = function()
	return true
end

return source
