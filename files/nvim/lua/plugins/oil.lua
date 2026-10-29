local mappings = require("mappings")

local function is_hidden(name, _)
  local hidden_names =
    { "..", ".git", ".vault_", ".become_", ".parcel-cache", "dist", "lua_modules", "node_modules" }
  for _, v in ipairs(hidden_names) do
    if name == v then
      return true
    end
  end
  return false
end

local setup = {
  delete_to_trash = false,
  skip_confirm_for_simple_edits = true,
  float = { padding = 2, max_width = 90, max_height = 0, border = "rounded" },
  win_options = { signcolumn = "no", number = false, relativenumber = false },
  view_options = { show_hidden = true, is_always_hidden = is_hidden },
}

return {
  {
    "stevearc/oil.nvim",
    config = function()
      local oil = require("oil")
      oil.setup(setup)
      mappings.oil(oil)
    end,
  },
}
