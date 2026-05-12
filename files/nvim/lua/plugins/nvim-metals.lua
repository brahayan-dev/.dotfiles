return {
  "scalameta/nvim-metals",
  ft = { "scala", "sbt", "java" },
  dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
  opts = function()
    local metals = require("metals")
    local metals_config = metals.bare_config()

    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

    metals_config.settings = {
      showImplicitArguments = true,
      showImplicitConversionsAndClasses = true,
      showInferredType = true,
      superMethodLensesEnabled = true,
      enableSemanticHighlighting = true,
      enableIndentOnPaste = true,
      excludedPackages = {
        "akka.actor.typed.javadsl",
        "com.github.swagger.akka.javadsl",
      },
      serverVersion = "latest.release",
      inlayHints = {
        hintsInPatternMatch = { enable = true },
        implicitArguments = { enable = true },
        implicitConversions = { enable = true },
        inferredTypes = { enable = true },
        typeParameters = { enable = true },
      },
    }

    metals_config.init_options.statusBarProvider = "on"

    metals_config.root_dir = function(bufnr)
      return vim.fs.root(bufnr, {
        "build.sc",
        "build.sbt",
        ".scala-build",
        ".git",
      })
    end

    metals_config.on_attach = function(client, bufnr)
      require("metals").setup_dap()
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
      require("keymaps").metals()
    end

    return metals_config
  end,
  config = function(self, metals_config)
    local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })

    local original_register = vim.lsp.handlers["client/registerCapability"]
    vim.lsp.handlers["client/registerCapability"] = function(err, result, ctx, config)
      for _, registration in ipairs(result.registrations or {}) do
        if registration.method == "workspace/didChangeWatchedFiles" then
          for _, watcher in ipairs(registration.registerOptions and registration.registerOptions.watchers or {}) do
            if type(watcher.globPattern) == "string" then
              watcher.globPattern = watcher.globPattern:gsub("^file://", "")
            elseif type(watcher.globPattern) == "table" and watcher.globPattern.pattern then
              watcher.globPattern.pattern = watcher.globPattern.pattern:gsub("^file://", "")
            end
          end
        end
      end
      return original_register(err, result, ctx, config)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = self.ft,
      group = group,
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MetalsStatus",
      group = group,
      callback = function(args)
        vim.g.metals_status = args.data and args.data.text or ""
      end,
    })
  end,
}
