local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

if vim.g.started_by_firenvim == true then
    require("lazy").setup(
        {
            {import = "sybil.plugins.firenvim" },
            {import = "sybil.plugins.mini" },
            {import = "sybil.plugins.movement" },
            {import = "sybil.plugins.ui.inline-render" },
            {import = "sybil.plugins.ui.tree-viewers" },
            {import = "sybil.plugins.ui.colorscheme" },
            {import = "sybil.plugins.lsp" },
        })
    -- Configure the filename pattern
    vim.g.firenvim_config.localSettings['*'] = {
        -- {hostname} and {pathname} are variables replaced by Firenvim
        filename = '{hostname}_{pathname}.md',
    }
    vim.cmd("hi Normal guibg=#1e1e2e")
    vim.opt.laststatus = 0 --remove footer
    vim.opt.signcolumn = "no" -- Disable the column where git signs and LSP errors usually appear
    vim.opt.foldcolumn = "0" -- Disable the column used for folding markers
else
    -- vim.o.laststatus = 2
    require("lazy").setup(
        {
            {import = "sybil.plugins.firenvim" },
            {import = "sybil.plugins.mini" },
            {import = "sybil.plugins.movement" },
            {import = "sybil.plugins.ui.inline-render" },
            {import = "sybil.plugins.ui.lualine" },
            {import = "sybil.plugins.ui.tree-viewers" },
            {import = "sybil.plugins.ui.pretty" },
            {import = "sybil.plugins.ui.colorscheme" },
            {import = "sybil.plugins.ui.unsorted" },
            {import = "sybil.plugins.treesitter" },
            {import = "sybil.plugins.org" },
            {import = "sybil.plugins.utils.compile" },
            {import = "sybil.plugins.utils.extern" },
            {import = "sybil.plugins.utils.qql" },
            {import = "sybil.plugins.lsp" },
            {import = "sybil.plugins.telescope" },
            {import = "sybil.plugins.local" },
        },
        {
            checker = {
                enabled = true,
                notify = false,
            },
            change_detection = {
                notify = false,
            },
        })
    -- views can only be fully collapsed with the global statusline
    vim.opt.laststatus = 3
end
