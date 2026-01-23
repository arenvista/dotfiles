return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'echasnovski/mini.nvim',
    },
    
    -- Using 'opts' automatically calls require('render-markdown').setup(opts)
    opts = {
        -- You can put custom configuration here (see below)
        code = {
            sign = false,
            width = 'block',
            right_pad = 1,
        },
        heading = {
            sign = true,
            icons = { '① ', '② ', '③ '},
        },
    },
    
    -- Optional: If you want to keep the type checking annotations
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    ft = { "markdown", "norg", "rmd", "org" }, -- Lazy load on these filetypes
}
