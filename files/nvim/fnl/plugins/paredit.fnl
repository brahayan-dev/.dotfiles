[{1 :kylechui/nvim-surround
  :event :VeryLazy
  :config #(let [{: setup} (require :nvim-surround)]
             (setup))}
 {1 :julienvincent/nvim-paredit
  :lazy true
  :ft [:clojure :fennel]
  :config #(let [{: setup} (require :nvim-paredit)]
             (setup))}
 {1 :windwp/nvim-autopairs :event :InsertEnter :config true}]
