(local lsps [:sqls
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

(local capabilities_with_encoding
       (fn []
         (let [default_capabilities ((. (require :cmp_nvim_lsp)
                                        :default_capabilities))]
           (vim.tbl_deep_extend :force default_capabilities
                                {:general {:positionEncodings [:utf-16]}}))))

[{1 :neovim/nvim-lspconfig
  :lazy false
  :dependencies [:hrsh7th/cmp-nvim-lsp]
  :config (fn []
            (vim.lsp.config "*" {:capabilities (capabilities_with_encoding)})
            (vim.lsp.config :lua_ls {:settings lua_ls_settings})
            (each [_ lsp (ipairs lsps)]
              (vim.lsp.enable lsp))
            ((. (require :mappings) :lsp))
            (vim.diagnostic.config {:virtual_text true}))}]
