-- File: lua/sybil/plugins/telescope/telescope-funcs/telescope-tmux.lua
local M = {}

-- Define the function locally or as part of M
function M.switch_window()
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local sorters = require('telescope.config').values.generic_sorter
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local tmux_cmd = { 'tmux', 'list-windows', '-a', '-F', '#{session_name}:#{window_index} - #{window_name}' }

    pickers.new({}, {
        prompt_title = 'Tmux Windows',
        finder = finders.new_oneshot_job(tmux_cmd),
        sorter = sorters({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    local target = selection[1]:match("^(%S+)")
                    if target then
                        vim.fn.system('tmux switch-client -t ' .. target)
                    end
                end
            end)
            return true
        end,
    }):find()
end

-- A setup function to apply the keymap
function M.setup()
    vim.keymap.set("n", "<leader>tna", M.switch_window, { desc = "Telescope: Switch Tmux Window" })
end

return M
