return {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = true,
    event = { "BufReadPre", "BufNewFile", "VeryLazy" },
    opts = { mode = "cursor", max_lines = 3 },
}
