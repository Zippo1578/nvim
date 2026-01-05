-- ================================================================================================
-- TITLE : lsp
-- ABOUT : Neovim LSP integration with Mason and LSP server management.
-- LINKS :
--   > nvim-lspconfig             : https://github.com/neovim/nvim-lspconfig
--   > mason.nvim                 : https://github.com/williamboman/mason.nvim
--   > mason-lspconfig.nvim       : https://github.com/williamboman/mason-lspconfig.nvim
--   > mason-tool-installer.nvim  : https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
-- ================================================================================================

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			----------------------
			-- Mason core
			----------------------
			require("mason").setup()

			----------------------
			-- LSP server installer
			----------------------
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ansiblels",
					"bashls",
					"yamlls",
				},
				automatic_installation = true,
			})

			----------------------
			-- Formatters & Linters installer
			----------------------
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"shfmt",
					"prettierd",
					"prettier",
				},
			})

			----------------------
			-- Enable LSP servers
			----------------------
			vim.lsp.enable({
				"lua_ls",
				"ansiblels",
				"bashls",
				"yamlls",
			})

			----------------------
			-- Diagnostic Config (your preferred version)
			----------------------
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			----------------------
			-- Diagnostic keymaps
			----------------------
			vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostics" })
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
		end,
	},

	{ "mason-org/mason.nvim", cmd = "Mason" },
	{ "mason-org/mason-lspconfig.nvim" },
	{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
}
