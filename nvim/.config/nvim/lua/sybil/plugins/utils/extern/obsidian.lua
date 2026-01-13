-- 1. Define all POTENTIAL vaults
local defined_vaults = {
    {
        name = "DiffyQ",
        path = "/home/sybil/Documents/School-SE1/Fall_2025/MATH225/diffyq_notes",
    },
    {
        name = "RealAnalysis",
        path = "/home/sybil/Documents/MATH301/Notes/",
    },
    {
        name = "OperatingSystems",
        path = "/home/sybil/Documents/OS/Notes/",
    },
    {
        name = "OperatingSystems",
        path = "/home/sybil/Documents/math301/Notes",
    },
}

-- 2. Filter: Only add them to 'my_vaults' if the directory actually exists on this machine
local my_vaults = {}
for _, vault in ipairs(defined_vaults) do
    -- vim.fn.isdirectory returns 1 if it exists, 0 if not
    if vim.fn.isdirectory(vault.path) == 1 then
        table.insert(my_vaults, vault)
    end
end

-- 3. Return the plugin config
return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    -- The cond function uses the filtered 'my_vaults' list
    cond = function()
        local cwd = vim.fn.getcwd()
        for _, vault in ipairs(my_vaults) do
            -- Check if cwd starts with the vault path (handles subdirectories too)
            -- We use plain=true for string.find to avoid regex issues with path chars
            if string.find(cwd, vault.path, 1, true) then
                return true
            end
        end
        return false
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        preferred_link_style = "markdown",
        workspaces = my_vaults, -- Pass the filtered list here
        templates = {
            folder = "./.templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            substitutions = {},
        },
    },
    keys = {
        { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian note", mode = "n" },
        { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Opens In Obsidian", mode = "n" },
        { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show location list of backlinks", mode = "n" },
        { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image from clipboard", mode = "n" },
        { "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Follows Link Under Cursor", mode = "n" },
        { "<leader>ol", "<cmd>ObsidianLinkNew<cr>", desc = "Create New Link", mode = "v" },
        { "<leader>os", "<cmd>ObsidianAliases<cr>", desc = "Search by Aliases", mode = "n" },
    },
    config = function(_, opts)
        -- 1. Initialize obsidian.nvim
        require("obsidian").setup(opts)

        -- 2. Define the Custom Telescope Function
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local previewers = require("telescope.previewers")

        local function search_aliases()
            local results = {}
            -- Use ripgrep to quickly find files containing "aliases:"
            local p = io.popen("rg -l 'aliases:'")
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
                            local alias_text = line:match("^%s*-%s*(.*)") or line:match("^%s*[%[\"'](.*)[%[\"']%s*$")

                            if alias_text then
                                alias_text = alias_text:gsub("^['\"]", ""):gsub("['\"]$", "")

                                table.insert(results, {
                                    alias = alias_text,
                                    path = filename,
                                    lnum = line_num
                                })
                            end
                        end
                        ::continue::
                    end
                    file:close()
                end
            end

            pickers.new({}, {
                prompt_title = "Search Obsidian Aliases",
                finder = finders.new_table {
                    results = results,
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = entry.alias .. " \t (" .. entry.path .. ")",
                            ordinal = entry.alias,
                            path = entry.path,
                            lnum = entry.lnum,
                        }
                    end,
                },
                sorter = conf.generic_sorter({}),
                previewer = previewers.vim_buffer_cat.new({}),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        vim.cmd("edit " .. selection.path)
                    end)
                    return true
                end,
            }):find()
        end

        vim.api.nvim_create_user_command("ObsidianAliases", search_aliases, {})
    end
}
