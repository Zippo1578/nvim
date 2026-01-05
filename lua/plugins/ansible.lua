-- ================================================================================================
-- TITLE : ansible
-- ABOUT : Ansible syntax highlighting and linting integration for Neovim.
-- LINKS :
-- INFO  : "print(vim.fn.system("/home/zippo/.venvs/bin/ansible-lint " .. vim.fn.expand("%")))"
--   > ansible-vim: https://github.com/pearofducks/ansible-vim
--   > nvim-lint  : https://github.com/mfussenegger/nvim-lint
-- ================================================================================================
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      local efm = "%f:%l:%c: %m,%f:%l: %m"

      lint.linters.ansible_lint = {
        name = "ansible-lint",
        cmd = vim.fn.exepath("ansible-lint"),
        args = { "-p", "--nocolor" },
        ignore_exitcode = true,
        parser = require("lint.parser").from_errorformat(efm, {
          source = "ansible-lint",
          severity = vim.diagnostic.severity.INFO,
        }),
      }

      lint.linters_by_ft = {
        ["yaml.ansible"] = { "ansible_lint" },
        python = { "pylint" }, -- "ruff" is possible
      }

      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  {
    "pearofducks/ansible-vim",
    ft = { "yaml.ansible", "ansible" },
  },
}

