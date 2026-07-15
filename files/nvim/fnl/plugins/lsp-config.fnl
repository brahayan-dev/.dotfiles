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

(local lua_ls_cmd
       [:lua-language-server
        (.. :--logpath= (vim.fn.stdpath :cache) :/lua-ls/log)
        (.. :--metapath= (vim.fn.stdpath :cache) :/lua-ls/meta)])

(local lua_ls_settings
       {:Lua {:runtime {:version :LuaJIT}
              :diagnostics {:globals [:vim]}
              :format {:enable false}
              :workspace {:checkThirdParty false
                          :library (vim.api.nvim_get_runtime_file "" true)}
              :telemetry {:enable false}}})

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
            (vim.lsp.config :lua_ls
                            {:cmd lua_ls_cmd
                             :root_markers [:.git :init.lua]
                             :settings lua_ls_settings})
            (vim.lsp.config :clojure_lsp
                            {:root_markers [:project.clj
                                            :deps.edn
                                            :shadow-cljs.edn
                                            :.git
                                            :bb.edn]})
            (each [_ lsp (ipairs lsps)]
              (vim.lsp.enable lsp))
            ((. (require :mappings) :lsp))
            (vim.diagnostic.config {:virtual_text true}))}]
