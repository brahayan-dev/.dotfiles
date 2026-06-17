return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  enabled = true,
  config = function()
    require("lualine").setup({
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
      },
    })
  end,
}
