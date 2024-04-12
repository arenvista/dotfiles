-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

vim.keymap.set("n", "<A-r>", function()
  ui.nav_file(1)
end)
vim.keymap.set("n", "<A-m>", function()
  ui.nav_file(2)
end)
vim.keymap.set("n", "<A-f>", function()
  ui.nav_file(3)
end)
vim.keymap.set("n", "<A-h>", function()
  ui.nav_file(4)
end)

vim.keymap.set("n", "<A-t>", function()
  ui.nav_file(5)
end)
vim.keymap.set("n", "<A-s>", function()
  ui.nav_file(6)
end)
vim.keymap.set("n", "<A-l>", function()
  ui.nav_file(7)
end)
vim.keymap.set("n", "<A-d>", function()
  ui.nav_file(8)
end)
vim.keymap.set("n", "<A-w>", function()
  ui.nav_file(9)
end)
vim.keymap.set("n", "<A-Space>", function()
  ui.nav_file(0)
end)
-- Remaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["*y]])
vim.keymap.set("n", "<leader>y", [["*y]])

vim.keymap.set({ "n", "v" }, "<leader>p", [["*p]])
vim.keymap.set("n", "<leader>p", [["*p]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("n", "<Del>", "<Esc>")
vim.keymap.set("v", "<Del>", "<Esc>")
vim.keymap.set("i", "<Del>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
