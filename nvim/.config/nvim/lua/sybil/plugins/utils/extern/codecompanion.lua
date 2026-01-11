return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "ravitemer/mcphub.nvim",
        {
            "MeanderingProgrammer/render-markdown.nvim",
            ft = { "markdown", "codecompanion" },
        },
    },
    -- 1. Add this keys section
    keys = {
        -- Open the Action Palette (The main interface for prompts like "Explain", "Fix", etc.)
        { "<leader>cca", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions Palette" },
        -- Toggle the Chat Buffer (Sidebar)
        { "<leader>ccc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Toggle Chat" },
        -- Inline Generation (Replaces or adds code directly in buffer)
        { "<leader>cci", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI Inline Prompt" },
    },
    config = function()
        require("codecompanion").setup({
            strategies = {
                chat = { adapter = "openai" },
                inline = { adapter = "openai" },
                agent = { adapter = "openai" },
            },
            opts = {
                log_level = "DEBUG",
            },
        })
    end,
}
