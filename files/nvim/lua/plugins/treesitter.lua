local langs = {
  "lua",
  "sql",
  "css",
  "bash",
  "yaml",
  "json",
  "html",
  "javascript",
  "typescript",
  "just",
  "python",
  "rescript",
  "astro",
}

local function callback(args)
  pcall(vim.treesitter.start, args.buf)
end

return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function()
      vim.g.no_plugin_maps = true
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      treesitter.setup()
      treesitter.install(langs)
      vim.api.nvim_create_autocmd("FileType", { callback = callback, pattern = langs })
    end,
  },
}
