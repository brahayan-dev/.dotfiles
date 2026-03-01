return {
  "stevearc/oil.nvim",
  config = function()
    local oil = require "oil"
    oil.setup({
      delete_to_trash = false,
      skip_confirm_for_simple_edits = true,

      float = {
        padding = 2,
        max_width = 90,
        max_height = 0,
        border = "rounded",
      },

      win_options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
      },

      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          local exclude = { "node_modules", ".become_", ".vault_", ".git", ".parcel-cache", ".." }
          for _, v in ipairs(exclude) do
            if name == v then
              return true
            end
          end
        end,
      }
    })

    vim.keymap.set("n", "-", oil.toggle_float, {})
  end,
}
