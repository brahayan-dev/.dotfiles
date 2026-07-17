;; https://github.com/neovim-idea/neovim-idea/blob/main/lua/plugins/lsp-config.lua
;; https://github.com/christoomey/dotfiles/blob/master/nvim/lua/plugins/scala-metals.lua
;; TODO: Add support for nvim-dap and telescope

(local settings {:excludedPackages {}
                 :serverVersion :1.6.7
                 :showInferredType true
                 :javaHome (os.getenv :JHFM)
                 :showImplicitArguments false})

(fn opts []
  (let [{: bare_config} (require :metals)
        {: default_capabilities} (require :cmp_nvim_lsp)
        metals (bare_config)]
    (set metals.settings settings)
    (set metals.capabilities (default_capabilities))
    metals))

(fn config [{: ft} metals]
  (let [{: initialize_or_attach} (require :metals)
        group (vim.api.nvim_create_augroup :nvim-metals {:clear true})]
    (vim.api.nvim_create_autocmd :FileType
                                 {: group
                                  :pattern ft
                                  :callback #(initialize_or_attach metals)})))

[{1 :scalameta/nvim-metals
  : opts
  : config
  :ft [:scala :sbt :java]
  :dependencies [:nvim-lua/plenary.nvim :hrsh7th/cmp-nvim-lsp]}]
