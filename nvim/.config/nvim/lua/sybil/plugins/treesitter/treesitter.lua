return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    config = function()
        -- import nvim-treesitter plugin
        local treesitter = require("nvim-treesitter.configs")

        require('nvim-ts-autotag').setup({
            opts = {
                -- Defaults
                enable_close = true,          -- Auto close tags
                enable_rename = true,         -- Auto rename pairs of tags
                enable_close_on_slash = false -- Auto close on trailing </
            },
            -- Per filetype overrides
            per_filetype = {
                ["html"] = {
                    enable_close = false
                }
            },
            -- Add aliases for custom filetypes
            aliases = {
                ["astro"] = "html", -- Example: treat astro files like html
            }
        })
        -- configure treesitter
        treesitter.setup({
            modules = {},
            sync_install = false,
            highlight = {
                enable = true,
            },
            -- enable indentation
            indent = { enable = true },
            auto_install = true,
            ensure_installed = {
                "json",
                "rust",
                "javascript",
                "typescript",
                "latex",
                "tsx",
                "yaml",
                "html",
                "css",
                "prisma",
                "markdown",
                "markdown_inline",
                "bash",
                "lua",
                "vim",
                "python",
                "gitignore",
                "query",
                "vimdoc",
                "c",
                "cpp",
                "asm",
            },
            ignore_install = { 'org' },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        })
    end,
}
