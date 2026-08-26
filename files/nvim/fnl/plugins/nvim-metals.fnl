;; https://github.com/neovim-idea/neovim-idea/blob/main/lua/plugins/lsp-config.lua
;; https://github.com/christoomey/dotfiles/blob/master/nvim/lua/plugins/scala-metals.lua
;; TODO: Add support for nvim-dap and telescope

(local settings-scala-3
       {:excludedPackages {}
        :serverVersion :1.6.4
        :showInferredType true
        :showImplicitArguments false
        :javaHome (os.getenv :JAVA_HOME)})

(local settings-scala-2 {:excludedPackages {}
                         :serverVersion :1.6.4
                         :showInferredType true
                         :javaHome (os.getenv :JHFM)
                         :showImplicitArguments false})

(local work? (os.getenv :NU_HOME))

(fn opts []
  (let [{: bare_config} (require :metals)
        {: default_capabilities} (require :cmp_nvim_lsp)
        metals (bare_config)]
    (set metals.settings (if work? settings-scala-2 settings-scala-3))
    (set metals.capabilities (default_capabilities))
    ;; Metals itself needs JDK 17+ to run, regardless of the project's
    ;; target JDK, since JAVA_HOME picks which java launches the server.
    (when work?
      (set metals.cmd_env {:JAVA_HOME (os.getenv :JHFM)}))
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
