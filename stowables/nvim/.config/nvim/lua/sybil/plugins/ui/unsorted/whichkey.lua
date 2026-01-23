return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		local wk = require("which-key")

		wk.add({
			-- Enter 'g' namespace mappings.
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File  " },
			{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Git Files  " },
			{ "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Grep  " },
			{ "<leader>fv", "<cmd>Telescope grep_string<cr>", desc = "Grep Word Under Cursor  " },
			{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Todos  " },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List Buffers" },
			{ "<leader>lr", "<cmd> Leet run<CR>", desc = "Run Code 󰜎 " },
			{ "<leader>lc", "<cmd>Leet console<CR>", desc = "Open Console 󰞷 " },
			{ "<leader>le", "<cmd>Leet<CR>", desc = "Leet  " },
			{ "<leader>li", "<cmd>Leet list<CR>", desc = "Show problem list  " },
			{ "<leader>lt", "<cmd>Leet tabs<CR>", desc = "Show tabs list  " },
		})
	end,
}
