return {
	"Prgebish/sigil.nvim",
	config = function()
		require("sigil").setup({
			filetypes = { "tex", "plaintex", "latex", "typst" },
			filetype_symbols = {
				tex = {
					{ pattern = "\\alpha", replacement = "α", boundary = "left" },
					{ pattern = "\\beta", replacement = "β", boundary = "left" },
					{ pattern = "\\to", replacement = "→" },
					{ pattern = "\\leq", replacement = "≤" },
				},
			},
		})
	end,
}
