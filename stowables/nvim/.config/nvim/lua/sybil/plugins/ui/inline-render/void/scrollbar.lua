return {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" }, -- Lazy load when opening a file
    config = function()
        require("scrollbar").setup({
            show_in_active_only = true,
            set_highlights = true,
            folds = 1000, 
            throttle_ms = 150, -- Increased slightly to reduce render frequency
            handle = {
                text = " ",
                blend = 30,
                highlight = "CursorColumn",
                hide_if_all_visible = true,
            },
            handlers = {
                cursor = false, -- MASSIVE performance win; kills CursorMoved events
                diagnostic = true,
                gitsigns = true, 
                handle = true,
                search = false,
                ale = false,
            },
        })
    end,
}
