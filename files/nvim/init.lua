local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "--branch=stable", -- latest stable release
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("lazy").setup("plugins", {
  -- automatically check for plugin updates
  checker = { enabled = true },
  change_detection = {
    notify = false,
  },
})
