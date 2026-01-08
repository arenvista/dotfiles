return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-cmdline",
        { "antosha417/nvim-lsp-file-operations", config = true },
        {
            "folke/lazydev.nvim",
            ft = "lua",
            opts = {
                library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
    },
    config = function()
        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local keymap = vim.keymap

        -- 1. Setup Capabilities
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- 2. Define Server Specific Configs
        -- This keeps your config clean and data-driven
        local servers = {
            -- Lua LS
            lua_ls = {
                settings = {
                    Lua = {
                        completion = { callSnippet = "Replace" },
                        telemetry = { enable = false },
                    },
                },
            },
            
            -- Svelte
            svelte = {
                on_attach = function(client, bufnr)
                    vim.api.nvim_create_autocmd("BufWritePost", {
                        pattern = { "*.js", "*.ts" },
                        callback = function(ctx)
                            client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                        end,
                    })
                end,
            },

            -- Clangd
            clangd = {
                cmd = { "clangd", "--offset-encoding=utf-16" },
            },

            -- Pyright
            pyright = {
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = "workspace",
                            useLibraryCodeForTypes = true,
                        },
                    },
                },
            },

            -- GraphQL
            graphql = {
                filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
            },

            -- Emmet
            emmet_ls = {
                filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
            },
        }

        -- 3. Mason Setup & Handlers
        -- This effectively replaces the manual lspconfig.setup calls
        require("mason-lspconfig").setup({
            ensure_installed = vim.tbl_keys(servers), -- Auto-install the keys from the table above
            handlers = {
                function(server_name)
                    local server_config = servers[server_name] or {}
                    -- Merge capabilities (important!)
                    server_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})
                    
                    -- This handles the setup. 
                    -- Note: If you are strictly on 0.11 Nightly, you might eventually use 
                    -- vim.lsp.config[server_name] = server_config
                    -- vim.lsp.enable(server_name)
                    -- But for now, this wrapper is the safest bridge.
                    lspconfig[server_name].setup(server_config)
                end,
            },
        })

        -- 4. LspAttach Autocommand (Global Keybinds)
        -- Kept exactly as you had it, this is the correct modern way.
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                local opts = { buffer = ev.buf, silent = true }

                opts.desc = "Show documentation"
                keymap.set("n", "K", vim.lsp.buf.hover, opts)
                opts.desc = "Go to declaration"
                keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                opts.desc = "Show LSP definitions"
                keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
                opts.desc = "Code Action"
                keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
                opts.desc = "Rename"
                keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

                -- Clangd Switch Header specific
                if client.name == "clangd" then
                    keymap.set('n', 'gs', "<cmd>ClangdSwitchSourceHeader<CR>", { buffer = ev.buf, desc = "Switch Source/Header" })
                end
            end,
        })

        -- 5. Diagnostic Signs & Config
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })
    end
}
