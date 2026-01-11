return {
  -- Lazygit integration.
  {
    'kdheepak/lazygit.nvim',
    cmd = { 'LazyGit' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    init = function()
      vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = 'Open LazyGit' })
    end,
  },
}

