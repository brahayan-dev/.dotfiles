(local {: autocomplete} (require :mappings))

[{1 :hrsh7th/cmp-nvim-lsp}
 {1 :L3MON4D3/LuaSnip
  :dependencies [:saadparwaiz1/cmp_luasnip :rafamadriz/friendly-snippets]}
 {1 :hrsh7th/nvim-cmp
  :event :VimEnter
  :dependencies [:hrsh7th/cmp-nvim-lsp :L3MON4D3/LuaSnip]
  :config (fn []
            (let [cmp (require :cmp)
                  sources-fn (require :cmp.config.sources)
                  win-bordered (require :cmp.config.window)
                  win-bordered-fn (. win-bordered :bordered)
                  {: lsp_expand} (require :luasnip)
                  vscode (require :luasnip.loaders.from_vscode)
                  preset (. cmp.mapping.preset :insert)]
              ((. vscode :lazy_load))
              (cmp.setup {:snippet {:expand (fn [args] (lsp_expand args.body))}
                          :window {:completion (win-bordered-fn)
                                   :documentation (win-bordered-fn)}
                          :mapping (preset (autocomplete cmp))
                          :sources (sources-fn [{:name :nvim_lsp}
                                                {:name :luasnip}]
                                               [{:name :buffer}])})))}]
