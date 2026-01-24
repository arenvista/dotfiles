return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- Autotag setup (kept as you had it, though latex doesn't use tags anyway)
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			},
		})

		-- configure treesitter
		treesitter.setup({
			modules = {},
			sync_install = false,
			highlight = {
				enable = true,
				-- !!! MOVED HERE: This is what allows VimTeX to work !!!
				-- disable = { "latex" },

				-- Optional: Use this if you want to force Vim's regex highlighting for these
				-- additional_vim_regex_highlighting = { "latex", "markdown" },
			},
			-- enable indentation
			indent = { enable = true },
			auto_install = true,
			ensure_installed = {
				"json",
				"rust",
				"javascript",
				"typescript",
				"latex", -- It is okay to keep this installed, just disabled in 'highlight'
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown_inline",
				"bash",
				"lua",
				"vim",
				"python",
				"gitignore",
				"query",
				"vimdoc",
				"c",
				"cpp",
				"asm",
			},
			ignore_install = {
				"org",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
