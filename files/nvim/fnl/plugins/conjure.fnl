(local {: conjure} (require :mappings))

(fn init []
  (set vim.g.conjure#mapping#doc_word (. conjure :doc-word-key))
  (set vim.g.conjure#filetype#fennel :conjure.client.fennel.nfnl)
  (set vim.g.conjure#client#clojure#nrepl#eval#auto_require false)
  (set vim.g.conjure#client#clojure#nrepl#connection#auto_repl#enabled false))

[{1 :Olical/conjure :ft [:fennel :clojure] : init}]
