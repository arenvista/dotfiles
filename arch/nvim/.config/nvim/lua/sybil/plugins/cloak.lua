return{
        "laytan/cloak.nvim",
    config = function()
        print "Loading cloak.nvim"
        require('cloak').setup({
        enabled = true,
        cloak_character = '*',
        -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
        highlight_group = 'Comment',
        -- Applies the length of the replacement characters for all matched
        -- patterns, defaults to the length of the matched pattern.
        cloak_length = nil, -- Provide a number if you want to hide the true length of the value.
        -- Whether it should try every pattern to find the best fit or stop after the first.
        try_all_patterns = true,
        -- Set to true to cloak Telescope preview buffers. (Required feature not in 0.1.x)
        cloak_telescope = true,
        patterns = {
            file_pattern = '.env*',
            cloak_pattern = {
                '(a=).+',
                { '(b=).+' },
                { '(c=).+', replace = '[inner] %1' }
                -- The outer `replace` could also be specified here instead
            },
            replace = '[outer] %1',
        }
    })
    end,
}
