return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer", -- source for text in buffer
        "hrsh7th/cmp-path", -- source for file system paths
        {
            "L3MON4D3/LuaSnip",
            -- follow latest release.
            version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
            -- install jsregexp (optional!).
            build = "make install_jsregexp",
        },
        "saadparwaiz1/cmp_luasnip", -- for autocompletion
        "rafamadriz/friendly-snippets", -- useful snippets
        "onsails/lspkind.nvim", -- vs-code like pictograms
        "micangl/cmp-vimtex",
    },
    config = function()
        local cmp = require "cmp"
        local compare = cmp.config.compare
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").load({ paths = "./lua/sybil/plugins/lsp/snip" })
        luasnip.setup({
            enable_autosnippets = true,
        })
        cmp.setup({
            sorting = {
                priority_weight = 1.0,
                comparators = {
                    compare.score,            -- Jupyter kernel completion shows prior to LSP
                    compare.recently_used,
                    compare.locality,
                },
            },
            completion = {
                completeopt = "menu,menuone,preview,noselect",
            },
            snippet = { -- configure how nvim-cmp interacts with snippet engine
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-Backspace>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),

                ["<Tab>"] = cmp.mapping(function(fallback)
                    -- Priority 1: Snippet Jump (i(1) -> i(2))
                    if luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                        -- Priority 2: Completion Menu (if open)
                    elseif cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    elseif cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            -- sources for autocompletion
            sources = cmp.config.sources({
                -- { name = "luasnip" }, -- snippets
                { name = "buffer" }, -- text within current buffer
                { name = "bufname"},
                { name = "buffer-lines"},
                { name = "calc"},
                { name = "dictionary"},
                { name = "spell"},
                { name = "omni"},
                { name = "digraphs"},
                { name = "path" }, -- file system paths
                -- { name = "jupynium", priority = 1000 },  -- consider higher priority than LSP
                { name = "nvim_lsp", priority = 100 },
                { name = "orgmode"},
                { name = "git"},
                { name = "rg"},
                { name = "cmdline"},
                { name = "vimtex"},
            }),

            -- configure lspkind for vs-code like pictograms in completion menu
            formatting = {
                format = lspkind.cmp_format({
                    maxwidth = 50,
                    ellipsis_char = "...",
                }),
            },
        })
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }    -- Autocomplete file paths
            }, {
                    { name = 'cmdline' } -- Autocomplete vim commands/functions
                }),
        })

        -- 3. ENABLE SEARCH AUTOCOMPLETE (/)
        cmp.setup.cmdline('/', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' },
            }
        })
    end,
}
