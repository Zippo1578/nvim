vim.lsp.config("ansiblels", {
	filetypes = { "yaml", "yaml.ansible" },
	settings = {
		ansible = {
			ansible = { path = "ansible" },
			python = { interpreterPath = "python3" },
			validation = { enabled = true },
		},
	},
})

