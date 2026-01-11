-- ================================================================================================
-- TITLE : FTerm.nvim
-- LINKS :
--   > github : https://github.com/numToStr/FTerm.nvim
-- ABOUT : Floating terminal plugin for Neovim with easy toggle and configurable shell.
-- ================================================================================================

return {
  "numToStr/FTerm.nvim",
  config = function()
    local fterm = require("FTerm")

    fterm.setup({
      cmd = "/bin/bash", -- change if you use zsh/fish/etc
      border = "rounded",
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
      auto_close = false,
    })
  end,
}
