vim.g.have_nerd_font = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.swapfile = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.number = true
-- vim.o.relativenumber = true
vim.o.relativenumber = false
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.ttimeoutlen = 0
vim.o.timeoutlen = 500
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.autoread = true

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

local mappings = require("mappings")
mappings.general()
mappings.window()
mappings.lsp()

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, { command = "checktime" })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
  desc = "Highlight when yanking text",
})

vim.filetype.add({ pattern = { ["[Jj]ustfile"] = "just" } })
