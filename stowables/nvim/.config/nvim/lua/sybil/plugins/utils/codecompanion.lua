return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "ravitemer/mcphub.nvim", 
        -- {
        --     "MeanderingProgrammer/render-markdown.nvim",
        --     ft = { "markdown", "codecompanion" },
        -- },
    },
    -- 1. Add this keys section
    config = function()
        require("codecompanion").setup({
            adapters = {
                openai = function()
                    return require("codecompanion.adapters").extend("openai", {
                        env = {
                            -- Ensure your env var matches what is in your shell (e.g., OPENAI_API_KEY)
                            api_key = "cmd:echo $OPENAI_API_KEY",
                        },
                    })
                end,
            },
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
