vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true
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

vim.opt.swapfile = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

require("keymaps").general()
require("keymaps").window()

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
  desc = "Highlight when yanking text",
})

local organize_imports_group =
  vim.api.nvim_create_augroup("organize-imports-on-save", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = organize_imports_group,
  pattern = "*.py",
  callback = function(args)
    vim.lsp.buf.code_action({
      bufnr = args.buf,
      apply = true,
      context = {
        only = { "source.organizeImports" },
        diagnostics = {},
      },
    })
  end,
  desc = "Organize Python imports on save",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
  end,
})
