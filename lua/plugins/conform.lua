return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			bash = { "bashls" },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			-- fallback: treat yaml.ansible as yaml
			["yaml.ansible"] = { "prettierd", "prettier", stop_after_first = true },
		},

		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
}
