return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "DiffyQ",
                path = "/home/sybil/Documents/School-SE1/Fall_2025/MATH225/diffyq_notes",
            },
            {
                name = "RealAnalysis",
                path = "/home/sybil/Documents/MATH301/Notes/",
            },
        },

        note_id_func = function(title)
            local suffix = ""
            if title ~= nil then
                suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
                for _ = 1, 4 do
                    suffix = suffix .. string.char(math.random(65, 90))
                end
            end
            return tostring(os.time()) .. "-" .. suffix
        end,

        note_path_func = function(spec)
            local path = spec.dir / tostring(spec.id)
            return path:with_suffix(".md")
        end,

        disable_frontmatter = false,

        note_frontmatter_func = function(note)
            if note.title then
                note:add_alias(note.title)
            end

            -- NEW: Convert numeric string aliases to actual numbers
            -- This prevents YAML from wrapping them in quotes (e.g. "2025" -> 2025)
            local clean_aliases = {}
            for _, alias in ipairs(note.aliases) do
                local as_num = tonumber(alias)
                if as_num then
                    table.insert(clean_aliases, as_num)
                else
                    table.insert(clean_aliases, alias)
                end
            end

            local out = { id = note.id, aliases = clean_aliases, tags = note.tags }

            if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                for k, v in pairs(note.metadata) do
                    out[k] = v
                end
            end

            return out
        end,

        templates = {
            folder = "./.templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            substitutions = {},
        },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)

        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.md",
            callback = function()
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local new_lines = {}
                local in_frontmatter = false
                local changed = false

                for i, line in ipairs(lines) do
                    if i == 1 and line == "---" then
                        in_frontmatter = true
                    elseif in_frontmatter and line == "---" then
                        in_frontmatter = false
                    end

                    if in_frontmatter then
                        local original_line = line

                        -- 1. Fix Indentation: Convert 2 spaces to 4 spaces
                        -- Targets lines starting with "  - " or "  key:"
                        line = line:gsub("^  (%S)", "    %1")

                        -- 2. Fix Quotes: Remove quotes from numbers/versions in lists
                        -- Turns '    - "2.1.5"' into '    - 2.1.5'
                        -- Matches: whitespace, dash, whitespace, quote, (digits/dots), quote
                        line = line:gsub('(%s*-%s*)"([%d%.]+)"', "%1%2")

                        if line ~= original_line then
                            changed = true
                        end
                    end
                    table.insert(new_lines, line)
                end

                if changed then
                    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
                end
            end,
        })
    end,
    keys = {
        { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian note", mode = "n" },
        { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Opens In Obsidian", mode = "n" },
        { "<leader>os", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch", mode = "n" },
        { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show location list of backlinks", mode = "n" },
        { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image from clipboard", mode = "n" },
        { "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Follows Link Under Cursor", mode = "n" },
        { "<leader>ol", "<cmd>ObsidianLinkNew<cr>", desc = "Create New Link", mode = "v" },
    },
}
