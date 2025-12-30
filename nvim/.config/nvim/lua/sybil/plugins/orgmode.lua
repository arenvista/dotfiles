return {
    'nvim-orgmode/orgmode',

    dependencies = {
        'hamidi-dev/org-super-agenda.nvim',
        'nvim-telescope/telescope.nvim',
        -- { 'lukas-reineke/headlines.nvim', config = true }, -- optional nicety
        'nvim-orgmode/telescope-orgmode.nvim',
        'nvim-orgmode/org-bullets.nvim',
        "danilshvalov/org-modern.nvim",
        -- 'Saghen/blink.cmp'
    },
    event = 'VeryLazy',
    config = function()
        require('orgmode').setup({
            -- See => https://github.com/nvim-orgmode/orgmode/blob/master/docs/configuration.org 
            org_agenda_files = '~/orgfiles/**/*',
            org_default_notes_file = '~/orgfiles/refile.org',
            org_todo_keywords = {
                'TODO', '|',
                'PROG', '|',
                'WAIT', '|',
                'DONE',
            },
            org_todo_keyword_faces = {
                -- specific keyword  =  properties string
                TODO  = ':foreground #FF5555 :weight bold :slant italic',
                WAIT  = ':foreground #BD93F9 :weight bold :slant italic',
                PROG  = ':foreground #FFAA00  :weight bold',
                DONE  = ':foreground #50FA7B :weight bold', 
            },
            -- win_split_mode = {"float", 0.9},
            -- win_split_mode = function(name)
            --     -- Make sure it's not a scratch buffer by passing false as 2nd argument
            --     local bufnr = vim.api.nvim_create_buf(true, false)
            --     --- Setting buffer name is required
            --     vim.api.nvim_buf_set_name(bufnr, name)
            --
            --     local fill = 0.8
            --     local width = math.floor((vim.o.columns * (fill*0.8)))
            --     local height = math.floor((vim.o.lines * fill))
            --     local row = math.floor((((vim.o.lines - height) / 2) - 1))
            --     local col = math.floor(((vim.o.columns - width) / 2))
            --
            --     vim.api.nvim_open_win(bufnr, true, {
            --         relative = "editor",
            --         width = width,
            --         height = height,
            --         row = row,
            --         col = col,
            --         style = "minimal",
            --         border = "rounded",
            --     })
            -- end,
            win_full_mode = function(name)
                -- Create the buffer
                local bufnr = vim.api.nvim_create_buf(true, false)
                vim.api.nvim_buf_set_name(bufnr, name)

                -- Create a new tab and switch to it
                vim.cmd('tabnew') 

                -- Set the buffer of this new tab to your created buffer
                vim.api.nvim_set_current_buf(bufnr)
            end,
            win_border = "rounded",
            org_agenda_time = {
                type = { 'daily', 'today', 'require-timed' },
                times = { 800, 1000, 1200, 1400, 1600, 1800, 2000 },
                time_separator = '┄┄┄┄┄',
                time_label = '┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄'
            },
            org_agenda_use_time_grid = true,
            org_tags_column = -80,

            org_agenda_custom_commands = {
                -- "c" is the shortcut that will be used in the prompt
                c = {
                    description = 'Combined view', -- Description shown in the prompt for the shortcut
                    types = {
                        {
                            type = 'tags_todo', -- Type can be agenda | tags | tags_todo
                            match = '+PRIORITY="A"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                            org_agenda_overriding_header = 'High priority todos',
                            org_agenda_todo_ignore_deadlines = 'far', -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
                        },
                        {
                            type = 'agenda',
                            org_agenda_overriding_header = 'My daily agenda',
                            org_agenda_span = 'day' -- can be any value as org_agenda_span
                        },
                        {
                            type = 'tags',
                            match = 'WORK', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
                            org_agenda_overriding_header = 'My work todos',
                            org_agenda_todo_ignore_scheduled = 'all', -- Ignore all headlines that are scheduled. Possible values: past | future | all
                        },
                        {
                            type = 'agenda',
                            org_agenda_overriding_header = 'Whole week overview',
                            org_agenda_span = 'week', -- 'week' is default, so it's not necessary here, just an example
                            org_agenda_start_on_weekday = 1, -- Start on Monday
                            org_agenda_remove_tags = true -- Do not show tags only for this view
                        },
                    }
                },
                p = {
                    description = 'Personal agenda',
                    types = {
                        {
                            type = 'tags_todo',
                            org_agenda_overriding_header = 'My personal todos',
                            org_agenda_category_filter_preset = 'todos', -- Show only headlines from `todos` category. Same value providad as when pressing `/` in the Agenda view
                            org_agenda_sorting_strategy = {'todo-state-up', 'priority-down'} -- See all options available on org_agenda_sorting_strategy
                        },
                        {
                            type = 'agenda',
                            org_agenda_overriding_header = 'Personal projects agenda',
                            org_agenda_files = {'~/my-projects/**/*'}, -- Can define files outside of the default org_agenda_files
                        },
                        {
                            type = 'tags',
                            org_agenda_overriding_header = 'Personal projects notes',
                            org_agenda_files = {'~/my-projects/**/*'},
                            org_agenda_tag_filter_preset = 'NOTES-REFACTOR' -- Show only headlines with NOTES tag that does not have a REFACTOR tag. Same value providad as when pressing `/` in the Agenda view
                        },
                    }
                },
                f = {
                    description = 'Two Week View',
                    types = {
                        {
                            type = 'agenda',
                            org_agenda_overriding_header = 'Whole week overview',
                            org_agenda_span = 14, -- 'week' is default, so it's not necessary here, just an example
                            org_agenda_start_on_weekday = 1, -- Start on Monday
                            org_agenda_remove_tags = true -- Do not show tags only for this view
                        },
                    }
                }
            }

        })

        require('org-bullets').setup({
            concealcursor = false,
            symbols = {
                list = "•",
                headlines = { 
                    { "◉", "MyBulletL1" },
                    { "○", "MyBulletL2" },
                    { "⏵", "MyBulletL3" },
                    { "⏩", "MyBulletL4" },
                },
                checkboxes = {
                    half = { "⍻", "@org.checkbox.halfchecked" },
                    done = { "✓", "@org.keyword.done" },
                    todo = { "", "@org.keyword.todo" },
                },
                vim.api.nvim_set_hl(0, '@org.checkbox.halfchecked',  { link = '@constructor' })
            }
        })

        -- require('blink.cmp').setup({
        --     sources = {
        --         per_filetype = {
        --             org = {'orgmode'}
        --         },
        --         providers = {
        --             orgmode = {
        --                 name = 'Orgmode',
        --                 module = 'orgmode.org.autocompletion.blink',
        --                 fallbacks = { 'buffer' },
        --             },
        --         },
        --     },
        -- })

        require('telescope').setup()
        require('telescope').load_extension('orgmode')
        vim.keymap.set('n', '<leader>r', require('telescope').extensions.orgmode.refile_heading)
        vim.keymap.set('n', '<leader>fh', require('telescope').extensions.orgmode.search_headings)
        vim.keymap.set('n', '<leader>li', require('telescope').extensions.orgmode.insert_link)
        local Menu = require("org-modern.menu")

        require("orgmode").setup({
            ui = {
                menu = {
                    handler = function(data)
                        Menu:new({
                            window = {
                                margin = { 1, 0, 1, 0 },
                                padding = { 0, 1, 0, 1 },
                                title_pos = "center",
                                border = "single",
                                zindex = 1000,
                            },
                            icons = {
                                separator = "➜",
                            },
                        }):open(data)
                    end,
                },
            },
        })

        require('org-super-agenda').setup({
            -- Where to look for .org files
            org_files           = {'~/orgfiles/*.org'},
            org_directories     = {'~/orgfiles/'}, -- only the directory for *.org
            exclude_files       = {},
            exclude_directories = {},

            -- TODO states + their quick filter keymaps and highlighting
            -- Optional: add `shortcut` field to override the default key (first letter)
            todo_states = {
                { name='TODO',     keymap='ot', color='#FF5555', strike_through=false, fields={'filename','todo','headline','priority','date','tags'} },
                { name='PROGRESS', keymap='op', color='#FFAA00', strike_through=false, fields={'filename','todo','headline','priority','date','tags'} },
                { name='WAITING',  keymap='ow', color='#BD93F9', strike_through=false, fields={'filename','todo','headline','priority','date','tags'} },
                { name='DONE',     keymap='od', color='#50FA7B', strike_through=true,  fields={'filename','todo','headline','priority','date','tags'} },
            },

            -- Agenda keymaps (inline comments explain each)
            keymaps = {
                filter_reset      = 'oa', -- reset all filters
                toggle_other      = 'oo', -- toggle catch-all "Other" section
                filter            = 'of', -- live filter (exact text)
                filter_fuzzy      = 'oz', -- live filter (fuzzy)
                filter_query      = 'oq', -- advanced query input
                undo              = 'u',  -- undo last change
                reschedule        = 'cs', -- set/change SCHEDULED
                set_deadline      = 'cd', -- set/change DEADLINE
                cycle_todo        = 't',  -- cycle TODO state
                set_state         = 's',  -- set state directly (st, sd, etc.) or show menu
                reload            = 'r',  -- refresh agenda
                refile            = 'R',  -- refile via Telescope/org-telescope
                hide_item         = 'x',  -- hide current item
                preview           = 'K',  -- preview headline content
                reset_hidden      = 'X',  -- clear hidden list
                toggle_duplicates = 'D',  -- duplicate items may appear in multiple groups
                cycle_view        = 'ov', -- switch view (classic/compact)
            },

            -- Window/appearance
            window = {
                width        = 0.8,
                height       = 0.7,
                border       = 'rounded',
                title        = 'Org Super Agenda',
                title_pos    = 'center',
                margin_left  = 0,
                margin_right = 0,
                fullscreen_border = 'none', -- border style when using fullscreen
            },

            -- Group definitions (order matters; first match wins unless allow_duplicates=true)
            groups = {
                { name = ' Today',     matcher = function(i) return i.scheduled and i.scheduled:is_today() end, sort={ by='priority', order='desc' } },
                { name = '⏩Tomorrow', matcher = function(i) return i.scheduled and i.scheduled:days_from_today() == 1 end },
                { name = '⏳ Deadlines', matcher = function(i) return i.deadline and i.todo_state ~= 'DONE' and not i:has_tag('personal') end, sort={ by='deadline', order='asc' } },
                { name = '⭐Important',  matcher = function(i) return i.priority == 'A' and (i.deadline or i.scheduled) end, sort={ by='date_nearest', order='asc' } },
                { name = '❌Overdue',    matcher = function(i) return i.todo_state ~= 'DONE' and ((i.deadline and i.deadline:is_past()) or (i.scheduled and i.scheduled:is_past())) end, sort={ by='date_nearest', order='asc' } },
                { name = ' Personal',   matcher = function(i) return i:has_tag('personal') end },
                { name = '󰼭 Work',       matcher = function(i) return i:has_tag('work') end },
                { name = '⏵Upcoming',   matcher = function(i)
                    local days = require('org-super-agenda.config').get().upcoming_days or 10
                    local d1 = i.deadline  and i.deadline:days_from_today()
                    local d2 = i.scheduled and i.scheduled:days_from_today()
                    return (d1 and d1 >= 0 and d1 <= days) or (d2 and d2 >= 0 and d2 <= days)
                end,
                    sort={ by='date_nearest', order='asc' }
                },
            },

            -- Defaults & behavior
            upcoming_days      = 10,
            hide_empty_groups  = true,      -- drop blank sections
            keep_order         = false,     -- keep original org order (rarely useful)
            allow_duplicates   = false,     -- if true, an item can live in multiple groups
            group_format       = '* %s',    -- group header format
            other_group_name   = 'Other',
            show_other_group   = false,     -- show catch-all section
            show_tags          = true,      -- draw tags on the right
            show_filename      = true,      -- include [filename]
            heading_max_length = 70,
            persist_hidden     = false,     -- keep hidden items across reopen
            view_mode          = 'classic', -- 'classic' | 'compact'

            classic = { heading_order={'filename','todo','priority','headline'}, short_date_labels=false, inline_dates=true },
            compact = { filename_min_width=10, label_min_width=12 },

            -- Global fallback sort for groups that omit `sort`
            group_sort = { by='date_nearest', order='asc' },

            -- Popup mode: run in a persistent tmux session for instant access
            popup_mode = {
                enabled      = false,
                hide_command = nil, -- e.g., "tmux detach-client"
            },

            debug = false,
        })
        vim.api.nvim_set_hl(0, '@org.priority.highest', { link = '@comment.error' })
        vim.api.nvim_set_hl(0, '@org.priority.default',  { bg = '#ef9f76', fg = '#292c3c'})
        -- vim.api.nvim_set_hl(0, '@org.priority.default',  { bg = '#ef9f76', fg = '#292c3c', bold = false })
        vim.api.nvim_set_hl(0, '@org.priority.lowest',  { bg = '#f9e2af', fg = '#292c3c'})
    end,

}
