-- ================================================================================================
-- TITLE : nvim-treesitter
-- ABOUT : Treesitter configurations and abstraction layer for Neovim.
-- LINKS :
--   > github : https://github.com/nvim-treesitter/nvim-treesitter
-- ================================================================================================

return {
	"nvim-treesitter/nvim-treesitter",
	-- No branch needed because 'main' is now the default
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		-- The rewrite uses a smaller set of options.
		-- 'highlight' and 'indent' are now largely handled by Neovim core 0.11+
		auto_install = true,
	},
	config = function(_, opts)
		local ts = require("nvim-treesitter")

		-- In the new 'main' branch, you manually trigger the install for your languages.
		-- This is non-blocking (asynchronous) by default.
		ts.install({
			"lua",
			"vim",
			"vimdoc",
			"query",
			"python",
			"markdown",
			"markdown_inline",
			"bash",
			"yaml",
		})

		-- Highlighting is now typically enabled via a simple vim command
		-- or autocmd in the new version, but the plugin still helps:
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})
	end,
}
