(fn general []
  (vim.keymap.set :n :<Esc> :<cmd>nohlsearch<CR>)
  (vim.keymap.set :n :<leader>q ":qa!<CR>" {:desc "Quit all"})
  (vim.keymap.set :n "<leader>;" ":wall<CR>" {:desc "Save all"})
  (vim.keymap.set :n :<leader>of vim.diagnostic.open_float
                  {:desc "Open float on diagnostic"})
  (vim.keymap.set :n :<leader>y
                  (fn [] (vim.fn.setreg "+" (vim.fn.expand "%:p")))
                  {:desc "Copy file path to clipboard"})
  (vim.keymap.set :n :<leader>hh
                  (fn []
                    (local enabled (vim.lsp.inlay_hint.is_enabled {:bufnr 0}))
                    (vim.lsp.inlay_hint.enable (not enabled) {:bufnr 0}))
                  {:desc "Toggle inlay hints"}))

(fn window []
  (vim.keymap.set :n :<leader>wc :<C-w>q {:desc "Quit window"})
  (vim.keymap.set :n :<leader>wo :<C-w>o {:desc "Only window"})
  (vim.keymap.set :n :<leader>ww :<C-w>w {:desc "Next window"})
  (vim.keymap.set :n :<leader>wv :<C-w>v {:desc "Vertical split"})
  (vim.keymap.set :n :<leader>ws :<C-w>s {:desc "Horizontal split"}))

(fn lsp []
  (vim.keymap.set :n :K vim.lsp.buf.hover {})
  (vim.keymap.set :n :<leader>cf
                  (fn []
                    ((. (require :conform) :format) {:async true
                                                     :lsp_format :fallback}))
                  {:desc "Format buffer"})
  (vim.keymap.set :n :<leader>cr vim.lsp.buf.rename {})
  (vim.keymap.set :n :<leader>cg vim.lsp.buf.references {})
  (vim.keymap.set :n :<leader>cd vim.lsp.buf.definition {})
  (vim.keymap.set :n :<leader>ca vim.lsp.buf.code_action {})
  (vim.keymap.set :n :<leader>cp vim.lsp.buf.implementation {}))

(fn telescope []
  (local builtin (require :telescope.builtin))
  (vim.keymap.set :n :<leader>bb builtin.oldfiles {})
  (vim.keymap.set :n :<leader>ff builtin.live_grep {})
  (vim.keymap.set :n :<leader><leader> builtin.find_files {}))

(fn oil [oil]
  (vim.keymap.set :n "-" oil.toggle_float {})
  (vim.keymap.set :n :q oil.close {}))

(fn autocomplete [cmp]
  {:<C-e> (cmp.mapping.abort)
   :<C-Space> (cmp.mapping.complete)
   :<C-f> (cmp.mapping.scroll_docs 4)
   :<C-b> (cmp.mapping.scroll_docs -4)
   :<CR> (cmp.mapping.confirm {:select true})})

(local conjure {:doc-word-key :H})

{: general : window : lsp : telescope : oil : autocomplete : conjure}
