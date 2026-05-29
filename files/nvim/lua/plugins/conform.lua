return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format", "ruff_fix" },
          ruby = { "rubocop" },
          lua = { "stylua" },
          elm = { "elm_format" },
        },
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          require("conform").format({ bufnr = args.buf, lsp_fallback = true })
        end,
        desc = "Format on save via conform.nvim",
      })
    end,
  },
}