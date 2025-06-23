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
            show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
            term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
            dim_inactive = {
                enabled = true, -- dims the background color of inactive window
                shade = "dark",
                percentage = 0.15, -- percentage of the shade to apply to the inactive window
            },
            no_italic = false, -- Force no italic
            no_bold = false, -- Force no bold
            no_underline = false, -- Force no underline
            styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
                comments = { "italic" }, -- Change the style of comments
                conditionals = { "italic" },
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
                -- miscs = {}, -- Uncomment to turn off hard-coded styles
            },
            color_overrides = {},
            custom_highlights = {},
            default_integrations = true,
            integrations = {
                aerial = true,
                alpha = true,
                cmp = true,
                dashboard = true,
                flash = true,
                fzf = true,
                grug_far = true,
                gitsigns = true,
                headlines = true,
                illuminate = true,
                indent_blankline = { enabled = true },
                leap = true,
                lsp_trouble = true,
                mason = true,
                markdown = true,
                mini = true,
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { "undercurl" },
                        hints = { "undercurl" },
                        warnings = { "undercurl" },
                        information = { "undercurl" },
                    },
                },
                navic = { enabled = true, custom_bg = "lualine" },
                neotest = true,
                neotree = true,
                noice = true,
                notify = true,
                semantic_tokens = true,
                snacks = true,
                telescope = true,
                treesitter = true,
                treesitter_context = true,
                which_key = true,
            }
        })
        vim.cmd.colorscheme("catppuccin")
        -- vim.api.nvim_set_hl(0, 'LineNr', { fg = "white"})
        -- vim.api.nvim_set_hl(0, "Comment", { fg = "#8c8fa1"})
        -- vim.api.nvim_set_hl(0, "", { fg = "#8c8fa1"})
        -- vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = "#8c8fa1"})
        -- vim.api.nvim_set_hl(0, "WinBar", { fg = "#8c8fa1"})
        -- vim.api.nvim_set_hl(0, "Cursor", { fg = "#8c8fa1"})
        -- vim.api.nvim_set_hl(0, "lCursor", { fg = "#8c8fa1"})
        -- vim.api.nvim_set_hl(0, "CursorIM", { fg = "#8c8fa1"})
        -- vim.api.nvim_set_hl(0, "@string.special.url", { fg = "#8c8fa1"})
        -- vim.api.nvim_set_hl(0, "NotifyTRACETitle", { fg = "#8c8fa1"})
        -- @string.special.url xxx cterm=underline,italic gui=underline,italic guifg=#f4dbd7

    end,
}
