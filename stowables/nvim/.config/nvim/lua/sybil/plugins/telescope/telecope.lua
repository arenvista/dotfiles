return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        "benfowler/telescope-luasnip.nvim",
    },
    -- We recommend defining keymaps here so they show up in WhichKey
    keys = {
        {
            "<leader>sl",
            function() require("telescope").extensions.luasnip.luasnip({}) end,
            desc = "Search Snippets",
        },
    },
    -- We must override the config to load the extension after setup
    config = function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)
        telescope.load_extension("luasnip")
    end,
}
