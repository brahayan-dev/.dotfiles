return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install({
        "lua",
        "sql",
        "yaml",
        "json",
        "html",
        "ruby",
        "scala",
        "embedded_template",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
