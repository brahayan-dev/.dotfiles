local mappings = require("mappings")

local options = {
  defaults = { file_ignore_patterns = { ".git/" } },
  pickers = {
    find_files = {
      hidden = true,
      theme = "ivy",
      find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
    },
  },
}

local function config()
  local telescope = require("telescope")
  local get_dropdown = require("telescope.themes").get_dropdown
  local dropdown = get_dropdown({})

  options.extensions = { ["ui-select"] = dropdown }
  mappings.telescope()
  telescope.setup(options)
  telescope.load_extension("ui-select")
end

return {
  { "nvim-telescope/telescope-ui-select.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = config,
  },
}
