(local sections {:lualine_c [{1 :filename :path 1}] :lualine_x [:filetype]})

[{1 :nvim-lualine/lualine.nvim
  :enabled true
  :dependencies [:nvim-tree/nvim-web-devicons]
  :config #(let [{: setup} (require :lualine)]
             (setup {: sections}))}]
