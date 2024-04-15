return {
	"catppuccin/nvim",
	priority = 1000,
	config = function()
		vim.cmd([[colorscheme catppuccin]])
        vim.api.nvim_set_hl(0,"Normal", { bg = "none" } )
        vim.api.nvim_set_hl(0,"NormalFloat", { bg = "none" } )
        vim.api.nvim_set_hl(0, 'LineNr', { fg = "white"})
	end,
    opts = {
      transpanrent_backgrund = true,
      transparent = true,
      styles = {
        sidebars = "transparent",
        float = "transparent",
      },
    },
}
