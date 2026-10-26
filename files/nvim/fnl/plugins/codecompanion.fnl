(fn adapter []
  (let [{: extend} (require :codecompanion.adapters)]
    (extend :ollama
            {:headers {:Content-Type :application/json
                       :Authorization "Bearer ${api_key}"}
             :schema {:model {:default "glm-5.3-flash"}}
             :env {:url "https://ollama.com" :api_key "OLLAMA_API_KEY"}})))

(local base {:adapter :ollama :model "glm-5.3-flash"})

[{1 :olimorris/codecompanion.nvim
  :version "^20.0.0"
  :opts {:adapters {:http {:ollama adapter}}
         :interactions {:cmd base :chat base :inline base}}
  :dependencies [:nvim-lua/plenary.nvim :nvim-treesitter/nvim-treesitter]}]
