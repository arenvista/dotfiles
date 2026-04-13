return {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat" },
    event = "VeryLazy", -- Or loads in the background after startup
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "ravitemer/mcphub.nvim",
    },
    config = function()
        require("codecompanion").setup({
            adapters = {
                openai = function()
                    return require("codecompanion.adapters").extend("openai", {
                        schema = {
                            model = {
                                default = "gpt-5",
                            },
                            reasoning_effort = {
                                default = "high",
                            },
                            verbosity = {
                                default = "high",
                            },
                        },
                        env = {
                            api_key = "cmd:echo $OPENAI_API_KEY",
                        },
                    })
                end,
            },
            strategies = {
                chat   = { adapter = "openai" },
                inline = { adapter = "openai" },
                agent  = { adapter = "openai" },
            },
            opts = {
                log_level = "DEBUG",
            },
        })
    end,
}
