vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ Setting options ]]

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

vim.keymap.set("n", "<leader>q", ":qa!<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>;", ":write<CR>", { desc = "Save file" })

vim.keymap.set("n", "<leader>c", "<C-w>q", { desc = "Quit window" })
vim.keymap.set("n", "<leader>o", "<C-w>o", { desc = "Only window" })
vim.keymap.set("n", "<leader>w", "<C-w>w", { desc = "Next window" })
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>s", "<C-w>s", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Move focus to the right window" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
  desc = "Highlight when yanking (copying) text"
})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = true })
  end,
  desc = "Format on save using LSP",
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.html", "*.js", "*.json" },
  callback = function(args)
    local output = vim.fn.system({ "npx", "prettier", "--write", args.file })

    if vim.v.shell_error ~= 0 then
      vim.notify(output, vim.log.levels.ERROR)
    else
      vim.cmd("edit!")
    end
  end,
  desc = "Format current file with Prettier (sync) on save",
})

vim.filetype.add({
  extension = {
    fs = 'fsharp',
    fsx = 'fsharp',
    fsi = 'fsharp',
  },
})
