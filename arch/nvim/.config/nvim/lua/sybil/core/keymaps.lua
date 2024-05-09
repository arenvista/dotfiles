local keymap = vim.keymap
vim.g.mapleader = " "
vim.g.localleader = "\\"
vim.keymap.set("n", "<leader>ex", vim.cmd.Ex, { desc = "󰭇 Explorer"})
vim.keymap.set("n", "<leader>ee", vim.cmd.Neotree, { desc = " Neotree"})
vim.keymap.set("n", "<leader>g", vim.cmd.Git, { desc = "  Fugitive" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = " +"})
vim.keymap.set("n", "<leader>y", [["+Y]], { desc = " +"})
keymap.set("n", "<leader>p", [["+p]], { desc = " +"})
keymap.set({"n", "v"}, "<leader>p", [["+P]], { desc = " +"})

-- This is going to get me cancelled
vim.keymap.set("n", "<Del>", "<Esc>")
vim.keymap.set("v", "<Del>", "<Esc>")
vim.keymap.set("i", "<Del>", "<Esc>")

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)


-- Insta chmod
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- window managment
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split  |" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split   ―"})
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize  "})
keymap.set("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close  "})

keymap.set("n", "<leader>qa", "<cmd>qa!<CR>", { desc = "󰩈 Exit"})
keymap.set("n", "<leader>qw", "<cmd>q<CR>", { desc = " Close Window"})
keymap.set("n", "<leader>qs", "<cmd>suspend<CR>", { desc = "󰤄 Suspend"})

keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = " Save"})
