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
        cmd = {
          'lua-language-server',
          '--logpath=' .. vim.fn.stdpath('cache') .. '/lua-ls/log',
          '--metapath=' .. vim.fn.stdpath('cache') .. '/lua-ls/meta',
        },
        root_markers = { '.git', 'init.lua' },
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = {
              globals = { "vim" },
            },
            format = { enable = false },
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
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("yamlls")
      vim.lsp.enable("bashls")
      vim.lsp.enable("jsonls")
      vim.lsp.enable("tofu_ls")
      vim.lsp.enable("ansiblels")

      vim.lsp.config("ruff", {
        root_markers = { "pyproject.toml", ".git" },
      })

      vim.lsp.enable("ruff")

      vim.lsp.config("basedpyright", {
        root_markers = { "pyproject.toml", ".git" },
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
            },
            disableOrganizeImports = true,
          },
        },
      })

      vim.lsp.enable("basedpyright")

      require "keymaps".lsp()

      vim.diagnostic.config({ virtual_text = true })
    end
  }
}
