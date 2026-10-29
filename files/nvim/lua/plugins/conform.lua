local formatters_by_ft = {
  lua = { "stylua" },
  html = { "prettier" },
  json = { "prettier" },
  markdown = { "prettier" },
  typescript = { "prettier" },
  javascript = { "prettier" },
  python = { "ruff_format" },
  rescript = { "rescript-format" },
  just = { "just_fmt" },
}

local format_on_save = { timeout_ms = 500, lsp_format = "fallback" }
local formatters = {
  just_fmt = { command = "just", args = { "--justfile", "$FILENAME", "--fmt" }, format = "inplace" },
}

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = formatters_by_ft,
        format_on_save = format_on_save,
        formatters = formatters,
      })
    end,
  },
}
