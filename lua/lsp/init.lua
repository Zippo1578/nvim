require("mason").setup()
require("mason-lspconfig").setup()

require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"ansiblels",
		"bashls",
		"stylua",
	},
})

-- Load configs
require("lsp.lua_ls")
require("lsp.ansiblels")

-- Enable explicitly
vim.lsp.enable({
	"lua_ls",
	"ansiblels",
})
