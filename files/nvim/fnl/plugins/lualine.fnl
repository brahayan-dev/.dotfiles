(local sections {:lualine_c [{1 :filename :path 1}] :lualine_x [:filetype]})

[{1 :nvim-lualine/lualine.nvim
  :dependencies [:nvim-tree/nvim-web-devicons]
  :enabled true
  :config (fn []
            ((. (require :lualine) :setup) {: sections}))}]
