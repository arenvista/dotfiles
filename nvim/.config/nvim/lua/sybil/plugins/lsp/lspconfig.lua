return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-cmdline",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		-- Lazydev is the key to recognizing nvim modules
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
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
		local servers = {
			-- Lua LS
			lua_ls = {
				settings = {
					Lua = {
						runtime = {
							-- Tell the language server which version of Lua you're using
							-- (most likely LuaJIT in the case of Neovim)
							version = "LuaJIT",
						},
						workspace = {
							-- Make the server aware of Neovim runtime files
							-- library = ... -- DON'T set this manually, lazydev does it for you!
							checkThirdParty = true,
						},
						completion = {
							callSnippet = "Replace",
						},
						telemetry = { enable = false },
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							globals = { "vim" },
							disable = { "missing-fields" }, -- Optional: Ignore noisy warnings
						},
					},
				},
			},

			-- Clangd
			clangd = {
                cmd = {'clangd', '--background-index', '--clang-tidy', '--log=verbose'},
                init_options = {
                    fallbackFlags = { '-std=c++17' },
                },
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
		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
			handlers = {
				function(server_name)
					local server_config = servers[server_name] or {}
					server_config.capabilities =
						vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})

					lspconfig[server_name].setup(server_config)
				end,
			},
		})

		-- 4. LspAttach Autocommand (Global Keybinds)
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
					keymap.set(
						"n",
						"gs",
						"<cmd>ClangdSwitchSourceHeader<CR>",
						{ buffer = ev.buf, desc = "Switch Source/Header" }
					)
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
	end,
}
