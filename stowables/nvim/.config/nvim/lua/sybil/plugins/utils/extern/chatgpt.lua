return {
	"jackMort/ChatGPT.nvim",
	event = "VeryLazy",
	-- Keybind for "Ctrl+g" in Visual Mode
	keys = {
		{
			"<C-g>",
			"<cmd>ChatGPTRun Explain Concept and write to file<CR>",
			mode = { "v" },
			desc = "ChatGPT Explain & Write to File",
		},
	},
	config = function()
		require("chatgpt").setup({
			-- FIXED: Added 'OPENAI_API_KEY' search term before the file path
			-- This grep finds the line, and cut extracts the value after '='
			actions_paths = {
				vim.fn.stdpath("config") .. "/lua/sybil/plugins/utils/extern/actions.json",
			},

			openai_params = {
				model = "gpt-5-mini",
				frequency_penalty = 0,
				presence_penalty = 0,
				max_tokens = 4095,
				temperature = 0.2,
				top_p = 0.1,
				n = 1,
			},
		})
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"nvim-telescope/telescope.nvim",
	},
}
