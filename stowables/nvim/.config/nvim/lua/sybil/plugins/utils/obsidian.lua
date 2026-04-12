local vault_list_path = "/home/sybil/dotfiles/utils/obsidianvaults/vaults.md"
local my_vaults = {}

local f = io.open(vault_list_path, "r")
if f then
    for line in f:lines() do
        local path = line:gsub("%s+", ""):gsub("/$", "")
        if path ~= "" and vim.fn.isdirectory(path) == 1 then
            local parent_path = vim.fn.fnamemodify(path, ":h")
            local vault_name = vim.fn.fnamemodify(parent_path, ":t")
            table.insert(my_vaults, {
                name = vault_name,
                path = path,
            })
        end
    end
    f:close()
end

return {
    "obsidian-nvim/obsidian.nvim",
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },

    opts = {
        legacy_commands = false, -- 🔥 disable deprecated commands
        preferred_link_style = "markdown",
        workspaces = my_vaults,

        templates = {
            folder = "./.templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            substitutions = {},
        },

        completion = {
            nvim_cmp = true,
            min_chars = 2,
        },
        checkbox = {
            order = { " ", "x" }, -- keep normal states
            cycle = false, -- 🚫 disable cycling on <CR>
        },
    },


    config = function(_, opts)
        require("obsidian").setup(opts)

        require("which-key").add({
            { "<leader>o", group = "Obsidian", icon = "💎", mode = { "n", "v" } },
            { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New Obsidian note", mode = "n" },
            { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian", mode = "n" },
            { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show backlinks", mode = "n" },
            { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image", mode = "n" },
            { "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Follow link", mode = "n" },
            { "<leader>ol", "<cmd>Obsidian link_new<cr>", desc = "Create new link", mode = "v" },
            { "<leader>os", "<cmd>ObsidianAliases<cr>", desc = "Search by Aliases", mode = "n" },
        })

        ------------------------------------------------------------------
        -- Cmdline completion for :Obsidian subcommands
        ------------------------------------------------------------------
        vim.api.nvim_create_autocmd("CmdlineChanged", {
            callback = function()
                if vim.fn.getcmdtype() ~= ":" then
                    return
                end

                local cmdline = vim.fn.getcmdline()

                -- Only trigger for Obsidian command
                if not cmdline:match("^Obsidian%s*[A-Za-z0-9_]*$") then
                    return
                end

                -- Avoid fighting nvim-cmp popup
                if package.loaded["cmp"] then
                    local cmp = require("cmp")
                    if cmp.visible() then
                        return
                    end
                end

                vim.fn.wildtrigger()
            end,
        })

        ------------------------------------------------------------------
        -- Telescope Setup
        ------------------------------------------------------------------
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local previewers = require("telescope.previewers")

        ------------------------------------------------------------------
        -- Helper: get all vault paths for rg restriction
        ------------------------------------------------------------------
        local function get_vault_paths()
            local paths = {}
            for _, ws in ipairs(my_vaults) do
                table.insert(paths, ws.path)
            end
            return table.concat(paths, " ")
        end

        ------------------------------------------------------------------
        -- Alias Search
        ------------------------------------------------------------------
        local function search_aliases()
            local results = {}

            local rg_cmd = "rg -l --no-heading 'aliases:' " .. get_vault_paths()
            local p = io.popen(rg_cmd)
            if not p then
                return
            end

            local file_list = p:read("*a")
            p:close()

            for filename in file_list:gmatch("[^\r\n]+") do
                local file = io.open(filename, "r")
                if file then
                    local in_alias_block = false
                    local line_num = 0

                    for line in file:lines() do
                        line_num = line_num + 1

                        if line:match("^%s*aliases:") then
                            in_alias_block = true
                            goto continue
                        end

                        if in_alias_block and line:match("^%s*tags:") then
                            break
                        end

                        if in_alias_block then
                            local alias_text = line:match("^%s*-%s*(.*)") or line:match("^%s*[%[\"'](.*)[%]\"']%s*$")

                            if alias_text then
                                alias_text = alias_text:gsub("^['\"]", ""):gsub("['\"]$", "")

                                table.insert(results, {
                                    alias = alias_text,
                                    path = filename,
                                    lnum = line_num,
                                })
                            end
                        end
                        ::continue::
                    end

                    file:close()
                end
            end

            pickers
                .new({}, {
                    prompt_title = "Search Obsidian Aliases",
                    finder = finders.new_table({
                        results = results,
                        entry_maker = function(entry)
                            return {
                                value = entry,
                                display = entry.alias .. "  (" .. entry.path .. ")",
                                ordinal = entry.alias,
                                path = entry.path,
                                lnum = entry.lnum,
                            }
                        end,
                    }),
                    sorter = conf.generic_sorter({}),
                    previewer = previewers.vim_buffer_cat.new({}),
                    attach_mappings = function(prompt_bufnr)
                        actions.select_default:replace(function()
                            actions.close(prompt_bufnr)
                            local selection = action_state.get_selected_entry()
                            vim.cmd("edit " .. selection.path)
                            vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
                        end)
                        return true
                    end,
                })
                :find()
        end
    end
}
