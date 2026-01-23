return {
	"L3MON4D3/LuaSnip",
	-- follow latest release.
	version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!).
	build = "make install_jsregexp",
	config = function()
		local ls = require("luasnip")

		-- 1. Load your snippets folder
		-- This loads markdown.lua -> "markdown", tex.lua -> "tex", mathmode.lua -> "mathmode"
        require("luasnip.loaders.from_lua").load({ paths = "./lua/sybil/plugins/lsp/snip" })

		-- 2. Tell markdown and tex to also look at "mathmode" snippets
		ls.filetype_extend("markdown", { "mathmode" })
		ls.filetype_extend("tex", { "mathmode" })
	end,
}
