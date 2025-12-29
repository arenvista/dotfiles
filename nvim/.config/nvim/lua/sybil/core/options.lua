vim.cmd("let g:netrw_liststyle = 3")
vim.o.timeoutlen = 1000
vim.o.ttimeoutlen = 10
vim.opt.spelllang = "en"
local opt = vim.opt
local sign = vim.fn.sign_define
sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = ""})
sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = ""})
sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = ""})
sign('DapStopped', { text='➥ ', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })

vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.opt.nu = true
vim.opt.relativenumber = true
vim.api.nvim_set_hl(0, 'LineNr', { fg = "white"})
vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#85c1dc', bold=true })
vim.api.nvim_set_hl(0, 'LineNr', { fg='white', bold=true }) -- Must set in colorscheme.lua
vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#e78284', bold=true })


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
vim.g.markdown_fenced_languages = { "javascript", "typescript", "bash", "lua", "go", "rust", "c", "cpp", "python"}
