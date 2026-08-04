(local mappings (require :mappings))

(local lsps [:html
             :sqls
             :ts_ls
             :lua_ls
             :yamlls
             :bashls
             :jsonls
             :tofu_ls
             :fennel_ls
             :ansiblels
             :clojure_lsp])

(local lua_ls_settings {:Lua {:diagnostics {:globals [:vim]}}})

(local html_settings
       {:filetypes [:html :mustache] :init_options {:provideFormatter false}})

(fn capabilities_with_encoding []
  (let [{: default_capabilities} (require :cmp_nvim_lsp)]
    (vim.tbl_deep_extend :force (default_capabilities)
                         {:general {:positionEncodings [:utf-16]}})))

[{1 :neovim/nvim-lspconfig
  :lazy false
  :dependencies [:hrsh7th/cmp-nvim-lsp]
  :config (fn []
            (vim.lsp.config "*" {:capabilities (capabilities_with_encoding)})
            (vim.lsp.config :lua_ls {:settings lua_ls_settings})
            (vim.lsp.config :html html_settings)
            (vim.diagnostic.config {:virtual_text true})
            (each [_ lsp (ipairs lsps)]
              (vim.lsp.enable lsp))
            (mappings.lsp))}]
