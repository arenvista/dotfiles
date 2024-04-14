vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true
vim.api.nvim_set_hl(0, 'LineNr', { fg = "white"})

--tabs and indentations
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- search settings
opt.ignorecase = true
opt.smartcase = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace  = "indent,eol,start"

-- splits
opt.splitright = true
opt.splitbelow = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.opt.updatetime = 50


