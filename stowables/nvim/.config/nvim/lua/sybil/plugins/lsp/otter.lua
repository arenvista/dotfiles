return {
    "jmbuhr/otter.nvim",

	event = { "BufReadPre", "BufNewFile", "VeryLazy" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
}
