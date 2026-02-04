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
		"NOTE",
		"TIP",
		"IMPORTANT",
		"WARNING",
		"CAUTION",
		"INFO",
		"TODO",
		"ABSTRACT",
		"SUCCESS",
		"QUESTION",
		"FAILURE",
		"DANGER",
		"BUG",
		"EXAMPLE",
		"QUOTE",
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
							table.insert(new_lines, "> " .. line)
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
-- Press <leader>bc (Block Callout) to trigger
vim.keymap.set("v", "<leader>cc", obsidian_callout, { desc = "Wrap selection in Obsidian Callout" })
-- File: init.lua

-- 1. Add Callout Level (Wrap with >)
-- Usage: Visually select text, press R
vim.keymap.set("v", "R", ":s/^/> /<CR>:nohl<CR>gv", {
    silent = true,
    desc = "Add Markdown Callout/Quote level",
})

-- 2. Remove Callout Level (Unwrap >)
-- Usage: Visually select text, press L
-- Note: Added '/e' flag to suppress errors if a line doesn't start with '>'
vim.keymap.set("v", "L", ":s/^> //<CR>:nohl<CR>gv", {
    silent = true,
    desc = "Remove Markdown Callout/Quote level",
})
