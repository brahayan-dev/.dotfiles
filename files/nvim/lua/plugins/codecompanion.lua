local default = "deepseek-v4.1-flash"

local function adapter()
  local extend = require("codecompanion.adapters").extend
  return extend("ollama", {
    schema = { model = { default = default } },
    headers = { ["Content-Type"] = "application/json", Authorization = "Bearer ${api_key}" },
    env = { url = "https://ollama.com", api_key = "OLLAMA_API_KEY" },
  })
end

local base = { adapter = "ollama", model = default }

return {
  {
    "olimorris/codecompanion.nvim",
    version = "^20.0.0",
    opts = {
      adapters = { http = { ollama = adapter } },
      interactions = { cmd = base, chat = base, inline = base },
      display = {
        chat = {
          window = {
            layout = "horizontal",
            height = 0.35,
            opts = { number = false, relativenumber = false, signcolumn = "no" },
          },
        },
      },
    },
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  },
}
