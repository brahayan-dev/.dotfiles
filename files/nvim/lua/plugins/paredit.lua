return {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "julienvincent/nvim-paredit",
    lazy = true,
    ft = { "clojure", "fennel" },
    config = function()
      require("nvim-paredit").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
}
