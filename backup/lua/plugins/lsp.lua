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
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			----------------------
			-- Mason setup
			----------------------
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "ansiblels", "bashls", "yamlls" },
				automatic_installation = true,
			})
			require("mason-tool-installer").setup({
				ensure_installed = { "stylua", "shfmt", "prettierd", "prettier" },
			})

			----------------------
			-- Diagnostics configuration
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
					format = function(d)
						return d.message
					end,
				},
			})

			----------------------
			-- Diagnostic keymaps (modern, non-deprecated)
			----------------------
			vim.keymap.set("n", "gl", function()
				vim.diagnostic.open_float({ border = "rounded" })
			end, { desc = "Show diagnostics" })

			vim.keymap.set("n", "[d", function()
				vim.diagnostic.jump({ count = -1 })
			end, { desc = "Previous diagnostic" })

			vim.keymap.set("n", "]d", function()
				vim.diagnostic.jump({ count = 1 })
			end, { desc = "Next diagnostic" })

			----------------------
			-- LSP server configurations
			----------------------
			local servers = {
				lua_ls = {}, -- default Lua setup
				ansiblels = {
					settings = {
						ansible = {
							validation = { enabled = true },
							lint = { enabled = true },
							python = { interpreterPath = vim.fn.exepath("python3") },
						},
					},
				},
				bashls = {},
				yamlls = {},
			}

			for server, config in pairs(servers) do
				-- register the LSP server
				vim.lsp.config(server, config)
				-- enable it immediately
				vim.lsp.enable(server)
			end
		end,
	},

	----------------------
	-- Mason plugins
	----------------------
	{ "williamboman/mason.nvim", cmd = "Mason" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
}
