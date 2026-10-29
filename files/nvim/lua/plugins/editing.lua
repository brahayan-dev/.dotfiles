return {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
}
