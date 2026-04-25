return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")
      config.setup({
        modules = {},
        ignore_install = {},
        sync_install = true,
        auto_install = true,
        indent = { enable = false },
        highlight = { enable = true },
        ensure_installed = {
          "lua",
          "sql",
          "yaml",
          "json",
          "html",
          "ruby",
          "scala",
          "embedded_template"
        },
      })
    end
  }
}
