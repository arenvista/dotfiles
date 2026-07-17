return {
	"stevearc/conform.nvim",
	opts = {},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },

				-- Formatter mappings for LaTeX and Typst
				tex = { "latexindent" },
				typst = { "prettypst" },
				markdown = { "latexindent", "prettier" },
			},

			-- Override specific formatter settings globally
			formatters = {
				stylua = {
					prepend_args = { "--indent-width", "4", "--indent-type", "Spaces" },
				},
				prettier = {
					prepend_args = { "--tab-width", "4" },
				},
				prettierd = {
					prepend_args = { "--tab-width", "4" },
				},

				-- Customizing LaTeX & Typst formatters to enforce your preference
				latexindent = {
					-- Force latexindent to use 4 spaces (can be configured via local YAML profiles as well)
					prepend_args = { "-m", "-g", "/dev/null" },
				},
				prettypst = {
					-- Tells prettypst to seek configuration files (e.g. prettypst.toml with indent = 4)
					prepend_args = { "--use-configuration" },
				},
			},
		})

		local conform = require("conform")
		vim.keymap.set({ "n", "v" }, "<Leader>bc", function()
			conform.format({
				lsp_fallback = true,
				timeout_ms = 5000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
