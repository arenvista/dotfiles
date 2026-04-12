return {
	"folke/twilight.nvim",
	opts = {
		dimming = {
			alpha = 0.25, -- amount of dimming
		},
		context = 0, -- Set to 0 to only focus on the exact node/paragraph you're in
		treesitter = true, -- Relies on nvim-treesitter with the latex parser installed
	},
    config = function()
        -- Keybinding to toggle Twilight
        vim.keymap.set('n', '<leader>tw', function()
          require('twilight').toggle()
        end, { desc = 'Toggle Twilight' })
    end
}
