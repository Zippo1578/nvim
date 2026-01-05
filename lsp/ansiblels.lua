vim.lsp.config("ansiblels", {
  settings = {
    ansible = {
      validation = {
        enabled = false,      -- enable diagnostics
      },
      lint = {
        enabled = false,     -- disable built-in linting (since you use nvim-lint)
      },
      python = {
        interpreterPath = vim.fn.exepath("python3"),
      },
    },
  },
})

