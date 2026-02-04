return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "latexindent", "prettier" },
			},
		})
		local conform = require("conform")
		vim.keymap.set({ "n", "v" }, "<Leader>lf", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
			vim.cmd("w")
			-- end
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
