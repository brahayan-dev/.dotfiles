[{1 :kylechui/nvim-surround
  :event :VeryLazy
  :config (fn []
            ((. (require :nvim-surround) :setup)))}
 {1 :julienvincent/nvim-paredit
  :lazy true
  :ft [:clojure :fennel]
  :config (fn []
            ((. (require :nvim-paredit) :setup)))}
 {1 :windwp/nvim-autopairs :event :InsertEnter :config true}]
