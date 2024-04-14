return {
	'nvim-telescope/telescope.nvim', tag = '0.1.6',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set('n', '<leader>tf', builtin.find_files, { desc = " Files"})
		vim.keymap.set('n', '<leader>tg', builtin.git_files, {desc = " Git"})
		vim.keymap.set('n', '<leader>ts', function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") });
		end, {desc = " Grep"})
	end,
}
