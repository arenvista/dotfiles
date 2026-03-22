return {
	"lervag/vimtex",
	lazy = false, -- We don't want to lazy load VimTeX
	-- tag = "v2.15", -- Uncomment to pin to a specific release
	init = function()
		-- 1. PDF Viewer: Zathura is highly recommended for forward/backward search
		vim.g.vimtex_view_method = "zathura"

		-- Update time for faster CursorHold events (e.g., for live previewing or plugins)
		vim.opt.updatetime = 100

		-- 2. Compiler Settings: Use latexmk and enable continuous compilation
		vim.g.vimtex_compiler_method = "latexmk"

		-- 3. Quickfix Window: Filter out common/annoying LaTeX warnings
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull",
			"Overfull",
			"specifier changed to",
			"Token not allowed in a PDF string",
		}

		-- Prevent the quickfix window from automatically opening on compilation errors
		vim.g.vimtex_quickfix_mode = 0

		-- 4. Conceal Settings (Optional but highly recommended)
		-- Turns things like \alpha into α or \frac{1}{2} into ½ visually in Neovim
		vim.g.vimtex_syntax_conceal = {
			accents = 1,
			cites = 1,
			fancy = 1,
			greek = 1,
			math_bounds = 1,
			math_delimiters = 1,
			math_fracs = 1,
			math_super_sub = 1,
			symbols = 1,
		}

		-- Note: To make conceal work, you also need to set vim.opt.conceallevel = 2
		-- somewhere in your general options (e.g., in your options.lua)
	end,
}
