(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")
(set vim.g.have_nerd_font true)

(set vim.opt.expandtab true)
(set vim.opt.tabstop 2)
(set vim.opt.shiftwidth 2)
(set vim.opt.softtabstop 2)
(set vim.opt.swapfile false)
(set vim.opt.listchars {:tab "» " :trail "·" :nbsp "␣"})

(set vim.o.number true)
(set vim.o.relativenumber true)
(set vim.o.mouse :a)
(set vim.o.showmode false)
(set vim.o.breakindent true)
(set vim.o.undofile true)
(set vim.o.ignorecase true)
(set vim.o.smartcase true)
(set vim.o.signcolumn :yes)
(set vim.o.updatetime 250)
(set vim.o.timeout true)
(set vim.o.ttimeoutlen 0)
(set vim.o.timeoutlen 500)
(set vim.o.splitright true)
(set vim.o.splitbelow true)
(set vim.o.list true)
(set vim.o.inccommand :split)
(set vim.o.cursorline true)
(set vim.o.scrolloff 10)
(set vim.o.confirm true)
(set vim.o.autoread true)

(vim.keymap.set [:n :v] :<Space> :<Nop> {:silent true})

(vim.schedule (fn [] (set vim.o.clipboard :unnamedplus)))

(let [mappings (require :mappings)]
  (mappings.general)
  (mappings.window)
  (mappings.lsp))

(vim.api.nvim_create_autocmd [:FocusGained :BufEnter :CursorHold]
                             {:command :checktime})

(vim.api.nvim_create_autocmd :TextYankPost
                             {:group (vim.api.nvim_create_augroup :highlight-yank
                                                                  {:clear true})
                              :callback (fn [] (vim.hl.on_yank))
                              :desc "Highlight when yanking text"})
