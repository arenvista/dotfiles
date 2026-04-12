return {
	{ "nvzone/volt", lazy = true },
	{ "nvzone/menu", lazy = true },

	vim.keymap.set("n", "<C-t>", function()
		require("menu").open("default")
	end, {}),
}
