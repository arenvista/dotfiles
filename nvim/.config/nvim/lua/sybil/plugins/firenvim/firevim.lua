return {
    'glacambre/firenvim',
    build = ":call firenvim#install(0)",
    config = function()
        vim.g.firenvim_config = {
            localSettings = {
                ['.*'] = {
                    takeover = 'never', -- 'never' prevents firenvim from automatically starting
                    filename = '{hostname}_{pathname}.md',
                },
            }
        }
    end
}
