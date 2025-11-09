local keymap = vim.keymap
vim.g.mapleader = " "
vim.g.localleader = "\\"
vim.keymap.set("n", "<leader>ex", vim.cmd.Ex, { desc = "󰭇 Explorer"})
vim.keymap.set("n", "<leader>ee", vim.cmd.Neotree, { desc = " Neotree"})
vim.keymap.set("n", "<leader>g", vim.cmd.Git, { desc = " Fugitive" })
vim.keymap.set("n", "-", "^", { desc = "Move to first non-blank character of the line" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = " +"})
vim.keymap.set("n", "<leader>y", [["+Y]], { desc = " +"})
keymap.set("n", "<leader>p", [["+p]], { desc = " +"})
keymap.set({"n", "v"}, "<leader>p", [["+P]], { desc = " +"})

-- This is going to get me cancelled
vim.keymap.set("n", "<Del>", "<Esc>")
vim.keymap.set("v", "<Del>", "<Esc>")
vim.keymap.set("i", "<Del>", "<Esc>")

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)

vim.keymap.set("n", "<leader>z", ":set foldmethod=indent")

vim.keymap.set('n', '<Leader>h', ':set hlsearch!<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>t', ':! date +\\%Y-\\%m-\\%d<CR>')

-- Insta chmod
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- window managment
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split  |" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split   ―"})
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize  "})
keymap.set("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close  "})

keymap.set("n", "<leader>qa", "<cmd>qa!<CR>", { desc = "󰩈 Exit"})
keymap.set("n", "<leader>qw", "<cmd>q<CR>", { desc = " Close Window"})
keymap.set("n", "<leader>qs", "<cmd>suspend<CR>", { desc = "󰤄 Suspend"})

keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = " Save"})

-- keymap.set("n", "<leader>wa", "<cmd>bw<CR>", { desc = " Save all buffers"})

function visual_replace_global()
  -- To get the visually selected text, we can programmatically yank it.
  -- 'gvy' yanks the last visual selection without moving the cursor.
  -- 'noau' prevents autocommands from firing during this operation.
  vim.cmd("noautocmd normal! gvy")
  local word_to_replace = vim.fn.getreg('"xy')
  print(vim.fn.getreg('"by'))

  -- Trim leading/trailing whitespace which might be selected accidentally.
  word_to_replace = vim.fn.trim(word_to_replace)

  -- Exit if the selection was empty.
  if not word_to_replace or word_to_replace == "" then
    vim.notify("No text selected or selection is empty.", vim.log.levels.WARN, { title = "Replace Canceled" })
    return
  end

  -- Prompt the user for the replacement text.
  local new_word = vim.fn.input("Replace all '" .. word_to_replace .. "' with: ")

  -- If the user cancels the input (e.g., by pressing Esc or entering nothing), abort.
  if not new_word or new_word == "" then
    vim.notify("Replacement canceled.", vim.log.levels.INFO, { title = "Replace Canceled" })
    return
  end

  -- Escape special characters in both the search pattern and the replacement string
  -- to prevent them from being interpreted as parts of the regex command.
  -- For the search term, we escape common regex symbols.
  local search_pattern = vim.fn.escape(word_to_replace, [[\/.*$^]])
  -- For the replacement term, we mainly need to escape the backslash '\' and ampersand '&'.
  local replacement_string = vim.fn.escape(new_word, [[\&]])

  -- Construct the final substitution command string.
  -- Note: Backslashes for word boundaries (<, >) must be escaped for the string format.
  local command = string.format("%%s/\\<%s\\>/%s/g", search_pattern, replacement_string)

  -- Execute the command using the Neovim API.
  vim.api.nvim_command(command)

  -- Provide feedback to the user.
  vim.notify(
    string.format("Ran command: %s", command),
    vim.log.levels.INFO,
    { title = "Replace Complete" }
  )
end

-- This creates a keymap for visual mode.
-- When you press '<leader>s' while text is selected, it will call the function.
keymap.set("n", "<leader>rr", function()
    visual_replace_global()
end, {
    noremap = true,
    silent = true,
    desc = "Replace selected word globally in file"
})
