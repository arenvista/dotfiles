return {
	"jackMort/ChatGPT.nvim",
	event = "VeryLazy",
	config = function()
		require("chatgpt").setup({
			actions_paths = {
				vim.fn.stdpath("config") .. "/lua/sybil/plugins/utils/extern/actions.json",
			},
			openai_params = {
				model = "gpt-5.2",
				frequency_penalty = 0,
				presence_penalty = 0,
				max_completion_tokens = 2048,
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
	keys = {
		{
			"<C-g>c",
			"<cmd>ChatGPT<CR>",
			mode = { "n","i" },
			desc = "ChatGPT Action Menu",
		},
		{
			"<C-g>r",
			"<cmd>ChatGPTRun clean_organize_block<CR>",
			mode = { "v" },
			desc = "ChatGPT Action Menu",
		},
	},
}
