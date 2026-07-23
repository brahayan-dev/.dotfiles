(local {: autocomplete} (require :mappings))

(fn config []
  (let [cmp (require :cmp)
        ->sources (require :cmp.config.sources)
        {: bordered} (require :cmp.config.window)
        {: lsp_expand : filetype_extend} (require :luasnip)
        {: lazy_load} (require :luasnip.loaders.from_vscode)
        preset (. cmp.mapping.preset :insert)]
    (lazy_load)
    (filetype_extend :mustache [:html])
    (cmp.setup {:snippet {:expand #(lsp_expand $.body)}
                :window {:completion (bordered) :documentation (bordered)}
                :mapping (-> cmp autocomplete preset)
                :sources (->sources [{:name :nvim_lsp} {:name :luasnip}]
                                    [{:name :buffer}])})))

[{1 :hrsh7th/cmp-nvim-lsp}
 {1 :L3MON4D3/LuaSnip
  :dependencies [:saadparwaiz1/cmp_luasnip :rafamadriz/friendly-snippets]}
 {1 :hrsh7th/nvim-cmp
  : config
  :event :VimEnter
  :dependencies [:hrsh7th/cmp-nvim-lsp :L3MON4D3/LuaSnip]}]
