-- ================================================================================================
-- TITLE : noice.nvim
-- LINKS :
--   > github : https://github.com/folke/noice.nvim
--   > github : https://github.com/MunifTanjim/nui.nvim
--   > github : https://github.com/rcarriga/nvim-notify.nvim
-- ABOUT : Highly experimental plugin that completely replaces the UI
-- ================================================================================================

return {
  -- Noice for a better command line and notification UI.
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup {
        lsp = {
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      }
    end,
  },
}

