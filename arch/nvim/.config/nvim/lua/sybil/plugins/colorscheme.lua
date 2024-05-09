return {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    opts = {
    },
    config = function()
        require("catppuccin").setup({
            flavour = "macchiato",
            transparent_background = true,
        })
        vim.cmd.colorscheme("catppuccin")
        vim.api.nvim_set_hl(0, 'LineNr', { fg = "white"})
        vim.api.nvim_set_hl(0, "Comment", { fg = "#8c8fa1"})
    end,
}
