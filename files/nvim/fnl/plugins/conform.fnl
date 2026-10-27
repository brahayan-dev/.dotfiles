(local formatters_by_ft {:lua [:stylua]
                         :html [:prettier]
                         :json [:prettier]
                         :fennel [:fnlfmt]
                         :markdown [:prettier]
                         :typescript [:prettier]
                         :javascript [:prettier]
                         :python [:ruff_format]
                         :rescript [:rescript-format]
                         :just [:just_fmt]})

(local format_on_save {:timeout_ms 500 :lsp_format :fallback})
(local formatters {:just_fmt {:command :just
                              :args ["--justfile" "$FILENAME" "--fmt"]
                              :format :inplace}})

[{1 :stevearc/conform.nvim
  :event [:BufWritePre]
  :cmd [:ConformInfo]
  :config #(let [{: setup} (require :conform)]
             (setup {: formatters_by_ft : format_on_save : formatters}))}]
