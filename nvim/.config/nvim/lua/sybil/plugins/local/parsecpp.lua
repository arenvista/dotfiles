return {
    {
        -- Point this to the absolute path of your plugin folder
        dir = "~/Documents/ParseCpp",
        -- Optional: Only load this plugin when opening C++ files (improves startup time)
        ft = { "cpp", "c" },
        -- Set up the keymap inside the plugin spec
        keys = {
            {
                "<leader>ci",
                function()
                    -- Ensure the module name matches the filename inside your plugin's lua/ folder
                    -- e.g., if your plugin has lua/my-ts-plugin/init.lua, use 'my-ts-plugin'
                    require("ParseCpp").generate_implementation()
                end,
                desc = "Generate C++ Implementation",
            },
        },
        -- Optional: If your plugin needs setup() called
        config = function()
            -- require("my-ts-plugin").setup()
        end,
    },
}
