local wk = require("which-key")
local keymap = vim.keymap

-- ==========================================
-- Leader Key Setup
-- ==========================================
vim.g.mapleader = " "
vim.g.localleader = "\\"

-- ==========================================
-- Standard Keymaps (Non-Leader)
-- ==========================================
-- It is best practice to keep standard immediate actions as normal keymaps
keymap.set("n", "<leader><C-f>f", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
keymap.set("n", "<leader><C-f>s", "<cmd>silent !tmux neww tmux-attacher<CR>")

keymap.set({ "n", "i", "v" }, "<C-c>", "<Esc>", { desc = "Rebind ESC to CTRL+C" })
keymap.set({ "n", "i", "v" }, "<Del>", "<Esc>")

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move highlighted lines down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move highlighted lines up" })

-- ==========================================
-- Which-Key Setup (Leader Mappings)
-- ==========================================

-- 1. Define the Groups (The menu labels)
wk.add({
  { "<leader>b", group = "Buffer", icon = "󰓩 " },
  { "<leader>q", group = "Quit & Session", icon = "󰗼 " },
  { "<leader>s", group = "Search", icon = " " },
  { "<leader>l", group = "LSP", icon = "󱐋 " },
  { "<leader>x", group = "Registers", icon = "󱉵 " },
  { "<leader>u", group = "Toggle", icon = " " },
  { "<leader>g", group = "Git", icon = "󰊢 " },
  { "<leader>e", group = "Explorers", icon="󰭈 " },
  { "<leader>o", group = "Org", icon=" " },
  { "<leader>f", group = "Finder", icon="  " },
  { "<leader><c-f>", group = "Tmux", icon=" " },
  { "<leader><c-f>", group = "Notfications", icon="󱈸" },
  { "<leader>a", group = "AI", icon="  " },
})

-- 2. Define the Keymaps
wk.add({
  -- Plugins & External Tools


  -- Text Movement & Formatting
  { "<leader>bf", function()
      local view = vim.fn.winsaveview()
      vim.cmd("normal! gg=G")
      vim.fn.winrestview(view)
  end, desc = "Format entire buffer with =", mode = "n" },

  -- Clipboard & Registers
{ "<leader>y", [["+y]], desc = "Yank to system clipboard", mode = { "n", "v" }, icon = "" },
{ "<leader>Y", [["+Y]], desc = "Yank line to system clipboard", mode = "n", icon = "" },

{ "<leader>p", [["_dP]], desc = "Paste (keep register)", mode = "x", icon = "" },
{ "<leader>p", [["+p]], desc = "Paste from system clipboard", mode = "n", icon = "" },
{ "<leader>P", [["+P]], desc = "Paste from system clipboard (before)", mode = { "n", "v" }, icon = "" },

  -- Save, Quit & Suspend
  { "<leader>w", "<cmd>w<CR>", desc = "Save", mode = "n" , icon=" "},
  { "<leader>qa", "<cmd>qa<CR>", desc = "Quit All", mode = "n" },
  { "<leader>qw", "<cmd>q<CR>", desc = "Close Window", mode = "n" },
  { "<c-c>", "<cmd>q<CR>", desc = "Close Window", mode = "n" },
})

wk.add{
    -- Explorer
  { "<leader>ee", vim.cmd.Neotree, desc = " Neotree", mode = "n" },
  {"<leader>ea", "<cmd>AerialToggle!<CR>", desc = "Aerial", mode="n"},
  { "<leader>eo", function() require("oil").open() end, desc = "󰼙 Oil & Vinegar", },
}

wk.add{
-- Top Pickers & Explorer (Find)
{ "<leader>ff", function() Snacks.picker.smart() end, desc = "Find Files", icon=" "},
{ "<leader>fg", function() Snacks.picker.grep() end, desc = "Find Grep", icon=" "},
{ "<leader>:", function() Snacks.picker.command_history() end, desc = "Find Command History", icon=" "},
{ "<leader>fx", function() Snacks.explorer() end, desc = "File Explorer", icon=" "},
{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find Buffers", icon=" "},
{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File", icon=" "},
{ "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files", icon=" "},
{ "<leader>fp", function() Snacks.picker.projects() end, desc = "Find Projects", icon=" "},
{ "<leader>fr", function() Snacks.picker.recent() end, desc = "Find Recent", icon=" "},
{ "<leader>fb", function() Snacks.picker.lines() end, desc = "Find Buffer Lines", icon=" "},
{ "<leader>fB", function() Snacks.picker.grep_buffers() end, desc = "Find in Open Buffers", icon=" "},
{ "<leader>fN", function() Snacks.picker.notifications() end, desc = "Find Notification History",icon=" " },
{ "<leader>fs", function() Snacks.picker.grep() end, desc = "Find Grep", icon=" "},
{ "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Find Visual selection or word", mode = { "n", "x" }, icon=" "},
-- Git
{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches", icon="󰊤 "},
{ "<leader>gf", vim.cmd.Git, desc = " Fugitive", mode = "n", icon="󰊤 " },
{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log", icon="󰊤 "},
{ "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line", icon="󰊤 "},
{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status", icon="󰊤 "},
{ "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash", icon="󰊤 "},
{ "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)", icon="󰊤 "},
{ "<leader>gF", function() Snacks.picker.git_log_file() end, desc = "Git Log File", icon="󰊤 "},
{ "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)", icon="󰊤 "},
{ "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)", icon="󰊤 "},
{ "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)", icon="󰊤 "},
{ "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)", icon="󰊤 "},
{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit", icon="󰊤 "},
{ "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" }, icon="󰊤 "},

-- Search
{ '<leader>s"', function() Snacks.picker.registers() end, desc = "Search Registers", icon=" "},
{ "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search History", icon=" "},
{ "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Search Autocmds", icon=" "},
{ "<leader>sb", function() Snacks.picker.lines() end, desc = "Search Buffer Lines", icon=" "},
{ "<leader>sc", function() Snacks.picker.command_history() end, desc = "Search Command History", icon=" "},
{ "<leader>sC", function() Snacks.picker.commands() end, desc = "Search Commands", icon=" "},
{ "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Search Diagnostics", icon=" "},
{ "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Search Buffer Diagnostics", icon=" "},
{ "<leader>sh", function() Snacks.picker.help() end, desc = "Search Help Pages", icon=" "},
{ "<leader>sH", function() Snacks.picker.highlights() end, desc = "Search Highlights", icon=" "},
{ "<leader>si", function() Snacks.picker.icons() end, desc = "Search Icons", icon=" "},
{ "<leader>sj", function() Snacks.picker.jumps() end, desc = "Search Jumps", icon=" "},
{ "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Search Keymaps", icon=" "},
{ "<leader>sl", function() Snacks.picker.loclist() end, desc = "Search Location List", icon=" "},
{ "<leader>sm", function() Snacks.picker.marks() end, desc = "Search Marks", icon=" "},
{ "<leader>sM", function() Snacks.picker.man() end, desc = "Search Man Pages", icon=" "},
{ "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search Search for Plugin Spec", icon=" "},
{ "<leader>sq", function() Snacks.picker.qflist() end, desc = "Search Quickfix List", icon=" "},
{ "<leader>sR", function() Snacks.picker.resume() end, desc = "Search Resume", icon=" "},
{ "<leader>su", function() Snacks.picker.undo() end, desc = "Search Undo History", icon=" "},
-- LSP
--
{ "<leader>ld", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", },
{ "<leader>lD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration", },
{ "<leader>lr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References", },
{ "<leader>li", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation", },
{ "<leader>ly", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition", },
{ "<leader>lai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming", },
{ "<leader>lao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing", },
{ "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols", },
{ "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols", },

-- Other
{ "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer", },
{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer", },
-- { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", },
{ "<c-_>", function() Snacks.terminal() end, desc = "which_key_ignore", },
{ "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" }, },
{ "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" }, },

-- Notifications
{ "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History", },
{ "<leader>nd", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications", },
}

    -- Toggles

wk.add{
{ "<leader>uz", function() Snacks.zen() end, desc = "Toggle Zen Mode", },
{ "<leader>uZ", function() Snacks.zen.zoom() end, desc = "Toggle Zoom", },
{ "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal", },
{ "<leader>u.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer", },
{ "<leader>uC", function() Snacks.picker.colorschemfs() end, desc = "Colorschemes", },
}
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
            Snacks.debug.inspect(...)
        end
        _G.bt = function()
            Snacks.debug.backtrace()
        end

        -- Override print to use snacks for `:=` command
        if vim.fn.has("nvim-0.11") == 1 then
            vim._print = function(_, ...)
                dd(...)
            end
        else
            vim.print = _G.dd
        end

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle
            .option("background", { off = "light", on = "dark", name = "Dark Background" })
            :map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
    end,
})

-- Window Management Group
wk.add{
{ "<leader>b", group = "Windows", icon = " " },
{ "<leader>bh", "<C-w>h", desc = "Move Left", icon = " "},
{ "<leader>bj", "<C-w>j", desc = "Move Down", icon = " "},
{ "<leader>bk", "<C-w>k", desc = "Move Up", icon = " "},
{ "<leader>bl", "<C-w>l", desc = "Move Right", icon = " "},
{ "<leader>bv", "<C-w>v", desc = "Split Vertical", icon = " "},
{ "<leader>bs", "<C-w>s", desc = "Split Horizontal", icon = " "},
{ "<leader>bc", "<C-w>c", desc = "Close Window", icon = " "},
{ "<leader>bo", "<C-w>o", desc = "Close Others", icon = " "},
{ "<leader>b=", "<C-w>=", desc = "Equalize Size", icon = " "},
}

vim.keymap.set("n", "<a-h>", "<C-w>>", { desc = "Move Window Left" })
vim.keymap.set("n", "<a-l>", "<C-w><", { desc = "Move Window Right" })
vim.keymap.set("n", "<a-k>", "<C-w>+", { desc = "Move Window Upper" })
vim.keymap.set("n", "<a-j>", "<C-w>-", { desc = "Move Window Down" })


wk.add{
{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions Palette" },
{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Toggle Chat" },
{ "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI Inline Prompt" },
}

