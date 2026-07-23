(local formatters_by_ft {:lua [:stylua]
                         :html [:prettier]
                         :json [:prettier]
                         :mustache [:prettier]
                         :fennel [:fnlfmt]
                         :scala [:scalafmt]
                         :clojure [:cljfmt]
                         :markdown [:prettier]})

(local format_on_save {:timeout_ms 500 :lsp_format :fallback})
(local formatters {:prettier {:options {:ft_parsers {:mustache :html}}}})

[{1 :stevearc/conform.nvim
  :event [:BufWritePre]
  :cmd [:ConformInfo]
  :config #(let [{: setup} (require :conform)]
             (setup {: formatters_by_ft : format_on_save : formatters}))}]
