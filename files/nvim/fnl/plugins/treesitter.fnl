(local langs [:lua
              :sql
              :css
              :bash
              :yaml
              :json
              :html
              :scala
              :fennel
              :clojure
              :javascript
              :embedded_template])

[{1 :nvim-treesitter/nvim-treesitter-textobjects
  :branch :main
  :init (fn [] (tset vim.g :no_plugin_maps true))
  :config (fn [] nil)}
 {1 :nvim-treesitter/nvim-treesitter
  :branch :main
  :build ":TSUpdate"
  :config (fn []
            (let [ts (require :nvim-treesitter)]
              (ts.setup)
              (ts.install langs)
              (vim.api.nvim_create_autocmd :FileType
                                           {:callback (fn [args]
                                                        (pcall vim.treesitter.start
                                                               args.buf)
                                                        nil)})))}]
