return {
    'glacambre/firenvim',
    build = ":call firenvim#install(0)",
    config = function()
        vim.g.firenvim_config = {
            localSettings = {
                ['.*'] = {
                    -- 'never' prevents firenvim from automatically starting
                    takeover = 'never',
                },
            }
        }
    end
}
