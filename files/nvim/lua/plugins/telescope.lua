return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { ".git/" },
        },
        pickers = {
          find_files = {
            hidden = true,
            theme = "ivy",
            find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      require "keymaps".telescope()
      require("telescope").load_extension("ui-select")
    end,
  }
}
