-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move selected lines *down/up*
vim.keymap.set("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
vim.keymap.set("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })

-- Flowting Termin with FTerm
vim.keymap.set("n", "<leader>z", ":lua require('FTerm').open()<CR>") --open term
vim.keymap.set("t", "<Esc>", '<C-\\><C-n><CMD>lua require("FTerm").close()<CR>') --preserves session

-- Ansible Linter keymaps
local function is_ansible()
  return vim.bo.filetype == "yaml.ansible" or vim.bo.filetype == "ansible"
end

-- Run ansible-lint (no fix)
vim.keymap.set("n", "<leader>al", function()
  if not is_ansible() then
    vim.notify("Not an Ansible file", vim.log.levels.WARN)
    return
  end

  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  vim.system({ "ansible-lint", "--nocolor", file }, { text = true }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.notify("ansible-lint OK")
      else
        vim.notify(res.stderr or res.stdout or "ansible-lint failed", vim.log.levels.ERROR)
      end
    end)
  end)
end, { desc = "Ansible: lint current file" })

-- Run ansible-lint --fix
vim.keymap.set("n", "<leader>alf", function()
  if not is_ansible() then
    vim.notify("Not an Ansible file", vim.log.levels.WARN)
    return
  end

  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  vim.cmd("write")

  vim.system({ "ansible-lint", "--fix", "--nocolor", file }, { text = true }, function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.notify("ansible-lint --fix applied")
      else
        vim.notify(res.stderr or res.stdout or "ansible-lint --fix failed", vim.log.levels.ERROR)
      end

      -- Reload file if changed on disk
      vim.cmd("checktime")
    end)
  end)
end, { desc = "Ansible: lint --fix current file" })
