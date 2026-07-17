return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = function()
        local ok, ts = pcall(require, "nvim-treesitter")
        if not ok or not ts.get_installed then
            vim.schedule(function()
                vim.notify(
                    "nvim-treesitter: restart Neovim and run `:TSUpdate` to finish installing the `main` branch.",
                    vim.log.levels.WARN
                )
            end)
        end
    end,
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts = {
        -- NOTE: `highlight.enable` is a no-op on the `main` branch — highlighting
        -- is started manually below via `vim.treesitter.start()`. Kept only so
        -- `opts.ensure_installed` has somewhere sane to live.
        ensure_installed = {
            "bash",
            "c",
            "diff",
            "html",
            "javascript",
            "jsdoc",
            "json",
            "lua",
            "luadoc",
            "luap",
            "markdown",
            "markdown_inline",
            "printf",
            "python",
            "query",
            "regex",
            "toml",
            "tsx",
            "typescript",
            "vim",
            "vimdoc",
            "xml",
            "yaml",
        },
    },
    config = function(_, opts)
        local ts = require("nvim-treesitter")

        if not ts.get_installed then
            vim.notify(
                "nvim-treesitter: `main` branch not fully installed — run `:Lazy update`.",
                vim.log.levels.ERROR
            )
            return
        end

        if type(opts.ensure_installed) ~= "table" then
            vim.notify("nvim-treesitter: `ensure_installed` must be a table.", vim.log.levels.ERROR)
            return
        end

        -- Block the old `compilers` setting: it silently did nothing pre-rewrite,
        -- now it errors loudly so misconfigured dotfiles get noticed immediately.
        setmetatable(require("nvim-treesitter.install"), {
            __newindex = function(_, key)
                if key == "compilers" then
                    vim.schedule(function()
                        vim.notify(
                            table.concat({
                                "nvim-treesitter: setting custom `compilers` is no longer supported.",
                                "See: https://docs.rs/cc/latest/cc/#compile-time-requirements",
                            }, "\n"),
                            vim.log.levels.ERROR
                        )
                    end)
                end
            end,
        })

        ts.setup(opts)

        -- Fold defaults: start fully unfolded everywhere.
        vim.opt.foldenable = true
        vim.opt.foldlevel = 99
        vim.opt.foldlevelstart = 99

        -- Enable native TS highlighting + folding per-buffer, skipping
        -- special buffers (terminals, prompts, etc.) where it doesn't apply.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
            pattern = "*",
            callback = function(event)
                if vim.bo[event.buf].buftype ~= "" then
                    return
                end

                local attached = pcall(vim.treesitter.start, event.buf)
                if not attached then
                    return
                end

                vim.wo.foldmethod = "expr"
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            end,
        })
    end,
}
