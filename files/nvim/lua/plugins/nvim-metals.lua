return {
  "scalameta/nvim-metals",
  ft = { "scala", "sbt", "java" },

  dependencies = {
    "nvim-lua/plenary.nvim",
    "mfussenegger/nvim-dap",
  },

  opts = function()
    local metals = require("metals")

    local metals_config = metals.bare_config()

    metals_config.serverVersion = "latest.release"

    metals_config.capabilities =
        require("cmp_nvim_lsp").default_capabilities()

    metals_config.settings = {
      showInferredType = true,
      showImplicitArguments = true,
      showImplicitConversionsAndClasses = true,
      superMethodLensesEnabled = true,
      enableSemanticHighlighting = true,
      enableIndentOnPaste = true,

      inlayHints = {
        inferredTypes = { enable = true },
        typeParameters = { enable = true },
        implicitArguments = { enable = true },
        implicitConversions = { enable = true },
        hintsInPatternMatch = { enable = true }
      }
    }

    metals_config.init_options.statusBarProvider = "on"

    metals_config.root_dir = function(bufnr)
      return vim.fs.root(bufnr, {
        "build.sbt",
        "build.sc",
        ".scala-build",
        ".git",
      })
    end

    metals_config.on_attach = function(client, bufnr)
      require("metals").setup_dap()

      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, {
          bufnr = bufnr,
        })
      end

      pcall(function()
        require("keymaps").metals()
      end)
    end

    return metals_config
  end,

  config = function(_, metals_config)
    local metals = require("metals")

    local group =
        vim.api.nvim_create_augroup("nvim-metals", {
          clear = true,
        })

    -- Fix watcher glob issues on some systems
    local original_register =
        vim.lsp.handlers["client/registerCapability"]

    vim.lsp.handlers["client/registerCapability"] =
        function(err, result, ctx, config)
          for _, registration in ipairs(result.registrations or {}) do
            if registration.method == "workspace/didChangeWatchedFiles" then
              local watchers =
                  registration.registerOptions
                  and registration.registerOptions.watchers
                  or {}

              for _, watcher in ipairs(watchers) do
                if type(watcher.globPattern) == "string" then
                  watcher.globPattern =
                      watcher.globPattern:gsub("^file://", "")
                elseif type(watcher.globPattern) == "table"
                    and watcher.globPattern.pattern
                then
                  watcher.globPattern.pattern =
                      watcher.globPattern.pattern:gsub(
                        "^file://",
                        ""
                      )
                end
              end
            end
          end

          return original_register(err, result, ctx, config)
        end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt", "java" },
      group = group,

      callback = function()
        metals.initialize_or_attach(metals_config)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MetalsStatus",
      group = group,

      callback = function(args)
        vim.g.metals_status =
            (args.data and args.data.text) or ""
      end,
    })
  end,
}
