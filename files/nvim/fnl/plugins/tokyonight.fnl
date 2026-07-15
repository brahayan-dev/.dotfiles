(local opts {:style :storm
             :light_style :day
             :transparent true
             :styles {:comments {:italic true}}})

[{1 :folke/tokyonight.nvim
  :lazy false
  :name :tokyonight
  :priority 1000
  :config (fn []
            (let [{: setup} (require :tokyonight)]
              (setup opts)
              (vim.cmd "colorscheme tokyonight")))}]
