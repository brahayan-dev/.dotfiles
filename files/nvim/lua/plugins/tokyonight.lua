return {
  "folke/tokyonight.nvim",
  lazy = false,
  name = "tokyonight",
  priority = 1000,
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("tokyonight").setup({
      style = "storm",
      light_style = "day",
      transparent = true,
      styles = {
        comments = { italic = true },
      },
    })
    vim.cmd([[colorscheme tokyonight]])
  end,
}
