local vault_list_path = "/home/sybil/dotfiles/utils/obsidianvaults/vaults.md"
local my_vaults = {}
local f = io.open(vault_list_path, "r")
if f then
	for line in f:lines() do
		-- Clean up the line (remove whitespace and trailing slashes)
		local path = line:gsub("%s+", ""):gsub("/$", "")
		if path ~= "" and vim.fn.isdirectory(path) == 1 then
			-- Logic to get the folder above the final directory:
			-- 1. Get the parent directory: /a/b/c/Vault -> /a/b/c
			-- 2. Extract the last part of that parent: /a/b/c -> c
			local parent_path = vim.fn.fnamemodify(path, ":h")
			local vault_name = vim.fn.fnamemodify(parent_path, ":t")
			table.insert(my_vaults, {
				name = vault_name,
				path = path,
			})
		end
	end
	f:close()
end

return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		preferred_link_style = "markdown",
		workspaces = my_vaults, -- Pass the filtered list here
		templates = {
			folder = "./.templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			substitutions = {},
		},
        completion = {
            nvim_cmp = true, -- enable obsidian nvim-cmp source
            min_chars = 2,
        },
	},
	keys = {
		{ "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian note", mode = "n" },
		{ "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Opens In Obsidian", mode = "n" },
		{ "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show location list of backlinks", mode = "n" },
		{ "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image from clipboard", mode = "n" },
		{ "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Follows Link Under Cursor", mode = "n" },
		{ "<leader>ol", "<cmd>ObsidianLinkNew<cr>", desc = "Create New Link", mode = "v" },
		{ "<leader>os", "<cmd>ObsidianAliases<cr>", desc = "Search by Aliases", mode = "n" },
		-- Added the new keymap here
		{ "[#", "<cmd>ObsidianLinkHeader<cr>", desc = "Search and link to header", mode = "n" },
	},
	config = function(_, opts)
		-- 1. Initialize obsidian.nvim
		require("obsidian").setup(opts)

		-- 2. Define the Custom Telescope Functions
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		local previewers = require("telescope.previewers")

		-- [Existing Alias Search Function]
		local function search_aliases()
			local results = {}
			local p = io.popen("rg -l 'aliases:'")
			local file_list = p:read("*a")
			p:close()

			for filename in file_list:gmatch("[^\r\n]+") do
				local file = io.open(filename, "r")
				if file then
					local in_alias_block = false
					local line_num = 0

					for line in file:lines() do
						line_num = line_num + 1

						if line:match("^%s*aliases:") then
							in_alias_block = true
							goto continue
						end

						if in_alias_block and line:match("^%s*tags:") then
							break
						end

						if in_alias_block then
							local alias_text = line:match("^%s*-%s*(.*)") or line:match("^%s*[%[\"'](.*)[%[\"']%s*$")

							if alias_text then
								alias_text = alias_text:gsub("^['\"]", ""):gsub("['\"]$", "")

								table.insert(results, {
									alias = alias_text,
									path = filename,
									lnum = line_num,
								})
							end
						end
						::continue::
					end
					file:close()
				end
			end

			pickers
				.new({}, {
					prompt_title = "Search Obsidian Aliases",
					finder = finders.new_table({
						results = results,
						entry_maker = function(entry)
							return {
								value = entry,
								display = entry.alias .. " \t (" .. entry.path .. ")",
								ordinal = entry.alias,
								path = entry.path,
								lnum = entry.lnum,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					previewer = previewers.vim_buffer_cat.new({}),
					attach_mappings = function(prompt_bufnr, map)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							vim.cmd("edit " .. selection.path)
						end)
						return true
					end,
				})
				:find()
		end
		vim.api.nvim_create_user_command("ObsidianAliases", search_aliases, {})

		-- [NEW: Header Search Function]
		local function search_headers()
			local results = {}
			-- Use ripgrep with vimgrep output format (file:line:col:text) to find markdown headers
			local p = io.popen("rg --vimgrep '^#+\\s+'")
			if not p then
				return
			end
			local grep_output = p:read("*a")
			p:close()

			for line in grep_output:gmatch("[^\r\n]+") do
				-- Parse rg --vimgrep output
				local file, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
				if file and lnum and text then
					-- Extract header text without the markdown '#' hashes
					local header_text = text:gsub("^#+%s*", "")
					-- Get just the filename (without extension) for the link
					local filename = vim.fn.fnamemodify(file, ":t:r")

					table.insert(results, {
						file = file,
						filename = filename,
						lnum = tonumber(lnum),
						header = header_text,
						raw_text = text, -- Keep hashes for display
					})
				end
			end

			pickers
				.new({}, {
					prompt_title = "Search Obsidian Headers (Insert Link)",
					finder = finders.new_table({
						results = results,
						entry_maker = function(entry)
							return {
								value = entry,
								-- Show the full header (with hashes) and the file it belongs to
								display = entry.raw_text .. " \t (" .. entry.filename .. ".md)",
								ordinal = entry.raw_text .. " " .. entry.filename,
								path = entry.file,
								lnum = entry.lnum,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					previewer = previewers.vim_buffer_cat.new({}),
					attach_mappings = function(prompt_bufnr, map)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							local entry = selection.value

							-- Formats the link to insert. Using standard Obsidian wiki-link style for headers.
							-- If you strictly want standard markdown despite Obsidian's handling,
							-- change this to: string.format("[%s](%s.md#%s)", entry.header, entry.filename, entry.header:gsub(" ", "%%20"))
							local link = string.format("[[%s#%s]]", entry.filename, entry.header)

							-- Insert the link at the current cursor position
							vim.api.nvim_put({ link }, "c", true, true)
						end)
						return true
					end,
				})
				:find()
		end
		vim.api.nvim_create_user_command("ObsidianLinkHeader", search_headers, {})
	end,
}
