return {
  "Olical/conjure",
  ft = { "clojure" },
  init = function()
    vim.g["conjure#mapping#doc_word"] = "K"
    vim.g["conjure#client#clojure#nrepl#eval#auto_require"] = false
    vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = false
  end,
}
