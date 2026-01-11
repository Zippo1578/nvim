-- ================================================================================================
-- TITLE: NeoVim keymaps
-- ABOUT: sets some quality-of-life keymaps
-- ================================================================================================

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splitting & Resizing
vim.keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick config editing
vim.keymap.set("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

-- File Explorer
vim.keymap.set("n", "<leader>m", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus on File Explorer" })
vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

-- Move selected lines *down/up*
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '>-2<CR>gv=gv")
vim.keymap.set("v", "<M-Up>", ":m '>-2<CR>gv=gv")
vim.keymap.set("v", "<M-Down>", ":m '>+1<CR>gv=gv")

-- Flowting Termin with FTerm
vim.keymap.set("n", "<leader>z", ":lua require('FTerm').open()<CR>") --open term
vim.keymap.set("t", "<Esc>", '<C-\\><C-n><CMD>lua require("FTerm").close()<CR>') --preserves session

-- Run ansible-lint on current file
vim.keymap.set("n", "<leader>al", function()
	print(vim.fn.system("ansible-lint --nocolor " .. vim.fn.expand("%")))
end, { noremap = true, silent = true, desc = "Run ansible-lint on current file" })

-- Run ansible-lint on current file
vim.keymap.set("n", "<leader>al", function()
	print(vim.fn.system("ansible-lint " .. vim.fn.expand("%")))
end, { noremap = true, silent = true, desc = "Run ansible-lint on current file" })

-- Run ansible-lint --fix on current file
vim.keymap.set("n", "<leader>alf", function()
	local file = vim.fn.expand("%:p")
	if file == "" then
		vim.notify("No file name", vim.log.levels.WARN)
		return
	end

	vim.cmd("write")

	vim.system({ "ansible-lint", "--fix", "--nocolor", file }, { text = true }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify("ansible-lint --fix finished")
			else
				vim.notify("ansible-lint failed:\n" .. (result.stderr or result.stdout or ""), vim.log.levels.ERROR)
			end
			vim.defer_fn(function()
				vim.cmd("checktime")
				if vim.bo.modified then
					vim.cmd("edit!")
					vim.lsp.buf_notify(0, "textDocument/didOpen", {
						textDocument = vim.lsp.util.make_text_document_params(),
					})
				end
			end, 100)
		end)
	end)
end, { noremap = true, silent = true, desc = "Run ansible-lint --fix async on current file" })
