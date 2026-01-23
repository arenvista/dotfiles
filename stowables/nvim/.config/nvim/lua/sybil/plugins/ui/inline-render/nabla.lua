return {
    "jbyuki/nabla.nvim",
    keys = {
        -- Toggle the inline math view
        { "<leader>vm", function() require("nabla").toggle_virt() end, desc = "Toggle Math (Virtual Text)" },
        -- Show the math in a floating popup (good for complex formulas)
        { "<leader>vp", function() require("nabla").popup() end, desc = "View Math (Popup)" },
    },
    config = function()
        -- Optional: Enable automatically for specific filetypes
        -- vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        --     pattern = { "*.py", "*.md", "*.tex" },
        --     callback = function() require("nabla").enable_virt() end,
        -- })
    end
}
