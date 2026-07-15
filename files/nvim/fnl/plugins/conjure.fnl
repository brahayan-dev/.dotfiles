[{1 :Olical/conjure
  :ft [:clojure]
  :init (fn []
          (tset vim.g "conjure#mapping#doc_word" :K)
          (tset vim.g "conjure#client#clojure#nrepl#eval#auto_require" false)
          (tset vim.g
                "conjure#client#clojure#nrepl#connection#auto_repl#enabled"
                false))}]
