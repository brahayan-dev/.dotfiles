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
          "lua-language-server",
          "--logpath=" .. vim.fn.stdpath("cache") .. "/lua-ls/log",
          "--metapath=" .. vim.fn.stdpath("cache") .. "/lua-ls/meta",
        },
        root_markers = { ".git", "init.lua" },
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

      vim.lsp.config("clojure_lsp", {
        root_dir = function(bufnr, on_dir)
          local util = require("lspconfig.util")
          local pattern = vim.api.nvim_buf_get_name(bufnr)
          local fallback = vim.loop.cwd()
          local patterns = { "project.clj", "deps.edn", "shadow-cljs.edn", ".git", "bb.edn" }
          local root = util.root_pattern(patterns)(pattern)

          return on_dir((root or fallback))
        end,
      })

      vim.lsp.enable("sqls")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("yamlls")
      vim.lsp.enable("bashls")
      vim.lsp.enable("jsonls")
      vim.lsp.enable("tofu_ls")
      vim.lsp.enable("ansiblels")
      vim.lsp.enable("clojure_lsp")

      require("keymaps").lsp()

      vim.diagnostic.config({ virtual_text = true })
    end,
  },
}
