-- 1. Configuration: Map filetypes to terminal commands
local filetype_commands = {
	python = "python3 %",
	javascript = "node %",
	typescript = "ts-node %",
	sh = "bash %",
	go = "go run .",
	rust = "cargo run",
	c = "gcc % -o %< && ./%<",
	cpp = "g++ % -o %< && ./%<",
	lua = "lua %",
	tex = "pdflatex %",
}

-- 2. Create the User Command
vim.api.nvim_create_user_command("Run", function()
	local ft = vim.bo.filetype
	local command = filetype_commands[ft]

	if command then
		vim.cmd("write")

		local file_name = vim.fn.expand("%")
		local run_cmd = command:gsub("%%", file_name)

		-- Dimensions
		local width = math.floor(vim.o.columns * 0.8)
		local height = math.floor(vim.o.lines * 0.8)
		local col = math.floor((vim.o.columns - width) / 2)
		local row = math.floor((vim.o.lines - height) / 2)

		-- Create buffer and window
		local buf = vim.api.nvim_create_buf(false, true)
		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			width = width,
			height = height,
			col = col,
			row = row,
			style = "minimal",
			border = "rounded",
		})

		-- Run the command
		vim.fn.termopen(run_cmd)

		-- 3. KEY MAPPINGS FOR THIS BUFFER

		-- Map <Esc> to exit Terminal Mode and go to Normal Mode
		-- This lets you scroll up/down using standard Vim keys (k, j, C-u, C-d)
		vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = buf, silent = true })

		-- Map 'q' in Normal Mode to actually CLOSE the window
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })

		-- Start in Insert mode
		vim.cmd("startinsert")
	else
		print("No run command defined for: " .. ft)
	end
end, {})

vim.keymap.set("n", "<leader>rc", "<cmd>Run<CR>", { buffer = buf, silent = true, desc = "Run File" })

vim.api.nvim_create_user_command("RunBackground", function()
	local ft = vim.bo.filetype
	local command = filetype_commands[ft]

	if command then
		vim.cmd("write")

		local file_name = vim.fn.expand("%")
		local run_cmd = command:gsub("%%", file_name)

		-- Notify start
		vim.notify("Background Job Started: " .. run_cmd, vim.log.levels.INFO)

		-- Store output to display later if needed
		local output = {}

		local function on_output(job_id, data, event)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(output, line)
					end
				end
			end
		end

		-- Start the job
		vim.fn.jobstart(run_cmd, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_stdout = on_output,
			on_stderr = on_output,
			on_exit = function(job_id, exit_code, event)
				-- Schedule the notification to run on the main UI thread
				vim.schedule(function()
					if exit_code == 0 then
						vim.notify("Job Finished Successfully", vim.log.levels.INFO)
						-- Optional: Uncomment below to see output even on success
						-- if #output > 0 then vim.print(output) end
					else
						vim.notify("Job Failed (Code " .. exit_code .. ")", vim.log.levels.ERROR)
						-- Print output to :messages on failure
						if #output > 0 then
							vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
						end
					end
				end)
			end,
		})
	else
		vim.notify("No run command defined for: " .. ft, vim.log.levels.WARN)
	end
end, {})

-- Key mapping
vim.keymap.set("n", "<leader>rb", "<cmd>RunBackground<CR>", { silent = true, desc = "Run File in Background" })

vim.keymap.set("n", "<leader>d", function()
	-- Run the shell command silently without flashing the screen
	vim.fn.system("date +%Y-%m-%d | wl-copy")
	print("Date copied to wl-clipboard")
end, { desc = "Copy Date to Clipboard" })

vim.keymap.set("n", "<leader>sni", function()
	local ft = vim.bo.filetype
	local snips = require("luasnip").get_snippets(ft)
	local global_snips = require("luasnip").get_snippets("all")
	local output = {}

	-- 1. Calculate the maximum trigger length for alignment
	local max_width = 0

	local function update_max_width(list)
		if not list then
			return
		end
		for _, s in pairs(list) do
			if #s.trigger > max_width then
				max_width = #s.trigger
			end
		end
	end

	update_max_width(snips)
	update_max_width(global_snips)

	-- Add a tiny buffer (e.g., 2 spaces) so it doesn't feel cramped
	local fmt_str = "%-" .. (max_width + 2) .. "s -> %s"

	-- 2. Generate Output Lines
	table.insert(output, "--- Snippets for " .. ft .. " ---")
	if snips then
		for _, snip in pairs(snips) do
			table.insert(output, string.format(fmt_str, snip.trigger, snip.name or "No Name"))
		end
	else
		table.insert(output, "No snippets found.")
	end

	if global_snips and #global_snips > 0 then
		table.insert(output, "\n--- Global Snippets ---")
		for _, snip in pairs(global_snips) do
			table.insert(output, string.format(fmt_str, snip.trigger, snip.name or "No Name"))
		end
	end

	print(table.concat(output, "\n"))
end, { desc = "Print available snippets" })

