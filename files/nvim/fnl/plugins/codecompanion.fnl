(local adapter {:name :ollama :model "glm-5.2:cloud"})
(local opts {:opts {:log_level :DEBUG}
             :interactions {:cmd {: adapter}
                            :chat {: adapter}
                            :inline {: adapter}
                            :background {: adapter}}})

[{1 :olimorris/codecompanion.nvim
  : opts
  :dependencies [:nvim-lua/plenary.nvim :nvim-treesitter/nvim-treesitter]}]
