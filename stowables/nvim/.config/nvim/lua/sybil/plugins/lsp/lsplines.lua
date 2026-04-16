return {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
        require("lsp_lines").setup()

        -- Disable Neovim's default inline virtual text so they don't overlap
        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = true, -- Turns on lsp_lines
        })
    end,
}
