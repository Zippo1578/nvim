vim.lsp.config("ansiblels", {
	settings = {
		ansible = {
			validation = {
				enabled = true, -- enable diagnostics
			},
			lint = {
				enabled = true, -- disable built-in linting (since you use nvim-lint)
			},
			python = {
				interpreterPath = vim.fn.exepath("python3"),
			},
		},
	},
})
