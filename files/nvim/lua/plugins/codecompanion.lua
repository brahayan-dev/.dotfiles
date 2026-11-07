local base = { adapter = "ollama", model = "deepseek-v4.1-flash" }

local function adapter()
  local extend = require("codecompanion.adapters").extend
  return extend("ollama", {
    schema = { model = { default = base.model } },
    headers = { ["Content-Type"] = "application/json", Authorization = "Bearer ${api_key}" },
    env = { url = "https://ollama.com", api_key = "OLLAMA_API_KEY" },
  })
end

local display = {
        chat = {
          window = {
            layout = "horizontal",
            height = 0.35,
            opts = { number = false, relativenumber = false, signcolumn = "no" },
          },
        },
      }

return {
  {
    "olimorris/codecompanion.nvim",
    version = "^20.0.0",
    opts = {
      display = display,
      adapters = { http = { ollama = adapter } },
      interactions = { cmd = base, chat = base, inline = base },
    },
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  },
}
