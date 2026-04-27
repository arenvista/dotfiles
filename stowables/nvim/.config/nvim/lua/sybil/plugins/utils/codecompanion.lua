return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"lalitmee/codecompanion-spinners.nvim",
      "folke/snacks.nvim",
      "folke/noice.nvim",
	},
	opts = {
		-- ... your main codecompanion config ...
		extensions = {
			spinner = {
				enabled = true, -- This is the default
				opts = {
					-- Your spinner configuration goes here
					style = "snacks",
				},
			},
		},
	},
	config = function()
		require("codecompanion").setup({
			interactions = {
				chat = {
					-- You can specify an adapter by name and model (both ACP and HTTP)
					adapter = {
						name = "openai",
						model = "gpt-5.4",
					},
					roles = {
						llm = function(adapter)
							local model = adapter.schema.model.default or "unknown model"
							return "CodeCompanion (" .. adapter.formatted_name .. " - " .. model .. ")"
						end,
						user = "Me",
					},
				},
				-- Or, just specify the adapter by name
				inline = {
					adapter = {
						name = "openai",
						model = "gpt-5.4",
					},
				},
				cmd = {
					adapter = {
						name = "openai",
						model = "gpt-5.4",
					},
				},
				background = {
					adapter = {
						name = "openai",
						model = "gpt-5.4",
					},
				},
			},
		})
	end,
}

-- roles = {
-- 	llm = function(adapter)
-- 		local model = adapter.schema.model.default or "unknown model"
-- 		return "CodeCompanion (" .. adapter.formatted_name .. " - " .. model .. ")"
-- 	end,
-- 	user = "Me",
-- },
