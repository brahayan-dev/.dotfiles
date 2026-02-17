return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, {
        general = {
          positionEncodings = { "utf-16" },
        },
      })

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.enable("sqls")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("elmls")
      vim.lsp.enable("yamlls")
      vim.lsp.enable("bashls")
      vim.lsp.enable("jsonls")
      vim.lsp.enable("tofu_ls")
      vim.lsp.enable("ansiblels")
      vim.lsp.enable("clojure_lsp")

      -- Keymaps LSP
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>i", vim.lsp.buf.format, {})
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, {})
      vim.keymap.set("n", "<leader>g", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>p", vim.lsp.buf.implementation, {})

      vim.diagnostic.config({ virtual_text = true })
    end
  }
}
