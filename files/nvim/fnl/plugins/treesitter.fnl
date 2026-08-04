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

(fn callback [args]
  (pcall vim.treesitter.start args.buf)
  nil)

(fn add-support-to-mustache []
  (vim.treesitter.language.register :html :mustache))

[{1 :nvim-treesitter/nvim-treesitter-textobjects
  :branch :main
  :init #(set vim.g.no_plugin_maps true)}
 {1 :nvim-treesitter/nvim-treesitter
  :branch :main
  :build ":TSUpdate"
  :config #(let [{: setup : install} (require :nvim-treesitter)]
             (setup)
             (install langs)
             (add-support-to-mustache)
             (vim.api.nvim_create_autocmd :FileType
                                          {: callback
                                           :pattern [:mustache
                                                     (_G.unpack langs)]}))}]
