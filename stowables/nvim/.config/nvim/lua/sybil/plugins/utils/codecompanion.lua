return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		strategies = {
			chat = {
				adapter = "openai",
				roles = {
					llm = function(adapter)
						local model = adapter.schema.model.default or "unknown model"
						return "CodeCompanion (" .. adapter.formatted_name .. " - " .. model .. ")"
					end,
					user = "Me",
				},
			},
			inline = { adapter = "openai" },
			cmd = { adapter = "openai" },
		},
		adapters = {
			openai = function()
				return require("codecompanion.adapters").extend("openai", {
					schema = {
						model = {
							default = "gpt-5",
							-- YOU MUST ADD IT TO CHOICES SO IT PASSES VALIDATION
							choices = {
								["gpt-5"] = { opts = { can_reason = true } },
								["o1-2024-12-17"] = { opts = { can_reason = true } },
								["gpt-4o"] = { opts = { can_reason = false } },
							},
						},
						reasoning_effort = {
							default = "high",
						},
						max_completion_tokens = {
							default = 20000,
						},
						verbosity = {
							default = "high",
						},
					},
					system_prompt = function(ctx)
						local base = require("codecompanion.adapters").openai.system_prompt(ctx)
						return base .. "If greeted say what's up!"
					end,
				})
			end,
		},
	},
}
