return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        local wk = require("which-key")

        wk.add({
            -- Enter 'g' namespace mappings.
            { "<C-g>c", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat", mode = "n" },
            { "<C-g>t", "<cmd>GpChatToggle popup<cr>", desc = "Toggle Chat", mode = "n" },
            { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder", mode = "n" },
            { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split", mode = "n" },
            { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit", mode = "n" },
            { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew", mode = "n" },
            { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite", mode = "n" },
            { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)", mode = "n" },
            { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)", mode = "n" },
            { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent", mode = "n" },
            { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop", mode = "n" },
            { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext", mode = "n" },

            { "<C-g>c", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat", mode = "v" },
            { "<C-g>t", "<cmd>GpChatToggle popup<cr>", desc = "Toggle Chat", mode = "v" },
            { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder", mode = "v" },
            { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split", mode = "v" },
            { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit", mode = "v" },
            { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew", mode = "v" },
            { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite", mode = "v" },
            { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)", mode = "v" },
            { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)", mode = "v" },
            { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent", mode = "v" },
            { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop", mode = "v" },
            { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext", mode = "v" },

            {"<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New", mode = "v" },
            {"<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste", mode = "v" },
            {"<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat", mode = "v" },
            {"<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite", mode = "v" },
            {"<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)", mode = "v" },
            {"<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)", mode = "v" },
            {"<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection", mode = "v" },

            {"<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File  " },
            {"<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Git Files  " },
            {"<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Grep  " },
            {"<leader>fv", "<cmd>Telescope grep_string<cr>", desc = "Grep Word Under Cursor  " },
            {"<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Todos  " },
            {"<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List Buffers" },
            {"<leader>lr", "<cmd> Leet run<CR>", desc = "Run Code 󰜎 " },
            {"<leader>lc", "<cmd>Leet console<CR>", desc = "Open Console 󰞷 " },
            {"<leader>le", "<cmd>Leet<CR>", desc = "Leet  " },
            {"<leader>li", "<cmd>Leet list<CR>", desc = "Show problem list  " },
            {"<leader>lt", "<cmd>Leet tabs<CR>", desc = "Show tabs list  " },

            -- Enter 'g' subgroup mappings.
            -- {
            --     group = "<C-g>g",
            --     mode = "n",
            --     { "p", "<cmd>GpPopup<cr>", desc = "Popup" },
            --     { "e", "<cmd>GpEnew<cr>", desc = "GpEnew" },
            --     { "n", "<cmd>GpNew<cr>", desc = "GpNew" },
            --     { "v", "<cmd>GpVnew<cr>", desc = "GpVnew" },
            --     { "t", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
            -- },

            -- You would continue here with other <C-g> related keymaps for normal mode
        })





    end,
}
