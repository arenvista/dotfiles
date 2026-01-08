return {
    "mfussenegger/nvim-dap",
    dependencies = {

        -- fancy UI for the debugger
        {

            "rcarriga/nvim-dap-ui",
            dependencies = { "nvim-neotest/nvim-nio" },
            -- stylua: ignore
            keys = {
                { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
                { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
            },
            opts = {},
            config = function(_, opts)
                require("dap")


                local sign = vim.fn.sign_define

                sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = ""})
                sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = ""})
                sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = ""})
                sign('DapStopped', { text='➤ ', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })

                local dap = require("dap")
                local dapui = require("dapui")
                dapui.setup(opts)
                dap.listeners.after.event_initialized["dapui_config"] = function()
                    dapui.open({})
                end
                dap.listeners.before.event_terminated["dapui_config"] = function()
                    dapui.close({})
                end
                dap.listeners.before.event_exited["dapui_config"] = function()
                    dapui.close({})
                end
            end,
        },

        -- virtual text for the debugger
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {},
        },

        -- which key integration
        -- {
        --     "folke/which-key.nvim",
        --     opts = {
        --         defaults = {
        --             ["<leader>d"] = { name = "+debug" },
        --         },
        --     },
        -- },

        -- mason.nvim integration
        {
            "jay-babu/mason-nvim-dap.nvim",
            dependencies = "mason.nvim",
            cmd = { "DapInstall", "DapUninstall" },
            opts = {
                -- Makes a best effort to setup the various debuggers with
                -- reasonable debug configurations
                automatic_installation = true,

                -- You can provide additional configuration to the handlers,
                -- see mason-nvim-dap README for more information
                handlers = {
                },

                -- You'll need to check that you have the required things installed
                -- online, please don't ask me how to install them :)
                ensure_installed = {
                    -- Update this to ensure that you have the debuggers for the langs you want
                },
            },
        },
    },

    -- stylua: ignore
            -- {"<leader>lt", "<cmd>Leet tabs<CR>", desc = "Show tabs list  " },
    keys = {
        { "<leader><BS>B", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
        { "<leader><BS>b", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
        { "<leader><BS>c", function() require("dap").continue() end, desc = "Continue" },
        { "<leader><BS>C", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
        { "<leader><BS>g", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
        { "<leader><BS>i", function() require("dap").step_into() end, desc = "Step Into" },
        { "<leader><BS>o", function() require("dap").step_out() end, desc = "Step Out" },
        { "<leader><BS>v", function() require("dap").step_over() end, desc = "Step Over" },
        { "<leader><BS>u", function() require("dap").step_back() end, desc = "Step Back" },
        { "<leader><BS>j", function() require("dap").down() end, desc = "Down" },
        { "<leader><BS>k", function() require("dap").up() end, desc = "Up" },
        { "<leader><BS>l", function() require("dap").run_last() end, desc = "Run Last" },
        { "<leader><BS>p", function() require("dap").pause() end, desc = "Pause" },
        { "<leader><BS>r", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
        { "<leader><BS>s", function() require("dap").session() end, desc = "Session" },
        { "<leader><BS>t", function() require("dap").terminate() end, desc = "Terminate" },
        { "<leader><BS>a", function() require("dap.ext.vscode").load_launchjs(nil, {cppdbg = {'c', 'h', 'cpp'}}) end, desc = "Launch JSON"},
        { "<leader><BS>w", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    }

}

