return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
            },
        })
        vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end, { desc = "⤦ Harpoon"})
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        vim.keymap.set("n", "<A-h>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<A-t>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<A-s>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<A-n>", function() harpoon:list():select(4) end)

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<C-S-l>", function() harpoon:list():prev() end)
        vim.keymap.set("n", "<C-S-h>", function() harpoon:list():next() end)
    end,

}
