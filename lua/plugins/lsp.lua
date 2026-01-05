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
      -- Mason core
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ansiblels",
          "bashls",
          "yamlls",
        },
        automatic_installation = true,
      })

      require("mason-tool-installer").setup({
        ensure_installed = {
          "lua_ls",
          "ansiblels",
          "bashls",
          "stylua",
        },
      })

      ---- Load per-server configs
      --require("lsp.lua_ls")
      --require("lsp.ansiblels")

      -- Enable servers (Neovim 0.12 native API)
      --vim.lsp.enable({
      --  "lua_ls",
      --  "ansiblels",
      --  "bashls",
      --})
    end,
  },

  { "mason-org/mason.nvim", cmd = "Mason" },
  { "mason-org/mason-lspconfig.nvim" },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
}

