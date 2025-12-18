return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
    },
    -- //swap header
    config = function()
        local function switch_source_header(bufnr, client)
            local method_name = 'textDocument/switchSourceHeader'
            ---@diagnostic disable-next-line:param-type-mismatch
            if not client or not client:supports_method(method_name) then
                return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
            end
            local params = vim.lsp.util.make_text_document_params(bufnr)
            ---@diagnostic disable-next-line:param-type-mismatch
            client:request(method_name, params, function(err, result)
                if err then
                    error(tostring(err))
                end
                if not result then
                    vim.notify('corresponding file cannot be determined')
                    return
                end
                vim.cmd.edit(vim.uri_to_fname(result))
            end, bufnr)
        end
    -- //end swap header func

        -- import lspconfig plugin
        -- local lspconfig = require("lspconfig")
        -- vim.lsp.config('…')

        -- import mason_lspconfig plugin
        local mason_lspconfig = require("mason-lspconfig")

        -- import cmp-nvim-lsp plugin
	local cmp_nvim_lsp = require("cmp_nvim_lsp")

	local keymap = vim.keymap -- for conciseness

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)

			-- Buffer local mappings.
			-- See `:help vim.lsp.*` for documentation on any of the below functions
			local opts = { buffer = ev.buf, silent = true }

			-- set keybinds
			opts.desc = "Find Function"
			keymap.set("n", "fc", ":lua require('telescope.builtin').lsp_document_symbols({ symbols={'function', 'method'} })<CR>", opts) -- show definition, references

			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

			opts.desc = "Rename across entire project"
			keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts) -- rename across entire project

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
		end,
	})

	-- used to enable autocompletion (assign to every lsp server config)
	local capabilities = cmp_nvim_lsp.default_capabilities()

	-- require('lspconfig').gdscript.setup(capabilities)

	-- Change the Diagnostic symbols in the sign column (gutter)
	local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	-- 1. Let mason-lspconfig manage installations and enabling servers
	require("mason-lspconfig").setup({
		-- A list of servers to automatically install if they're not already installed
		ensure_installed = {
			"svelte",
			"clangd",
			"pyright",
			"graphql",
			"emmet_ls",
			"lua_ls",
		},
	})

	-- 2. Define custom configurations for specific servers using the new API
	-- These settings will be automatically applied by Neovim when the server is enabled.
    vim.lsp.config("svelte", {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = { "*.js", "*.ts" },
                callback = function(ctx)
                    client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                end,
            })
        end,
    })

    -- Clangd
    vim.lsp.config("clangd", {
        capabilities = vim.tbl_deep_extend("force", capabilities, {
            textDocument = {
                completion = {
                    editsNearCursor = true,
                    completionItem = {
                        snippetSupport = true,
                        preselectSupport = true,
                        insertReplaceSupport = true,
                        labelDetailsSupport = true,
                        deprecatedSupport = true,
                        commitCharactersSupport = true,
                        tagSupport = { valueSet = { 1 } },
                        resolveSupport = {
                            properties = {
                                "additionalTextEdits",
                                "documentation",
                                "detail",
                            },
                        },
                    },
                },
            },
        }),
        offsetEncoding = { "utf-8", "utf-16" },
            on_attach = function(client, bufnr)
                vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdSwitchSourceHeader', function()
                    switch_source_header(bufnr, client)
                end, { desc = 'Switch between source/header' })

                vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdShowSymbolInfo', function()
                    symbol_info(bufnr, client)
                end, { desc = 'Show symbol info' })

                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gs', '<Cmd>LspClangdSwitchSourceHeader<CR>', { noremap = true, silent = true })
            end,
        })


    -- Pyright
    vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "workspace",
                    typeCheckingMode = "basic",
                    autoImportCompletions = true,
                    useLibraryCodeForTypes = true,
                    typeGuessingEnabled = true,
                    autoImportAll = true,
                },
            },
        },
    })

    -- GraphQL
    vim.lsp.config("graphql", {
        capabilities = capabilities,
        filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
    })

    -- Emmet
    vim.lsp.config("emmet_ls", {
        capabilities = capabilities,
        filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })

    -- Lua
    vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                completion = { callSnippet = "Replace" },
            },
        },
    })
    end
}
