return{
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
        options = {
            mode = "buffers", -- Shows your open files as tabs
            -- Optional: Add keymaps here or in your main keymaps file
        }
    },
vim.keymap.set("n", "H", ":bprevious<CR>", { desc = "Previous Buffer", silent = true }),
vim.keymap.set("n", "L", ":bnext<CR>", { desc = "Next Buffer", silent = true })
}
