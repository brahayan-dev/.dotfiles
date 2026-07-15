(local root_dir
       (fn [bufnr]
         (vim.fs.root bufnr [:build.sbt :build.sc :.scala-build :.git])))

(local on_attach
       (fn [client bufnr]
         (when client.server_capabilities.inlayHintProvider
           (vim.lsp.inlay_hint.enable true {: bufnr}))))

(local fix_watcher_glob
       (fn [original_register]
         (fn [err result ctx _config]
           (each [_ registration (ipairs (or result.registrations []))]
             (when (= registration.method :workspace/didChangeWatchedFiles)
               (let [watchers (or (and registration.registerOptions
                                       registration.registerOptions.watchers)
                                  [])]
                 (each [_ watcher (ipairs watchers)]
                   (if (= (type watcher.globPattern) :string)
                       (set watcher.globPattern
                            (watcher.globPattern:gsub "^file://" ""))
                       (when (and (= (type watcher.globPattern) :table)
                                  watcher.globPattern.pattern)
                         (set watcher.globPattern.pattern
                              (watcher.globPattern.pattern:gsub "^file://" ""))))))))
           (original_register err result ctx _config))))

(local opts (fn []
              (let [metals (require :metals)
                    {: default_capabilities} (require :cmp_nvim_lsp)
                    raw (vim.fn.system "cs java-home --jvm temurin:17 2>/dev/null")
                    java_home (raw:gsub "\n" "")
                    java_settings (when (not= java_home "")
                                    (set vim.env.JAVA_HOME java_home)
                                    (set vim.env.PATH
                                         (.. java_home "/bin:" vim.env.PATH))
                                    {:javaHome java_home})
                    base (metals.bare_config)]
                (set base.serverVersion :latest.release)
                (set base.settings
                     (vim.tbl_deep_extend :force (or java_settings {})
                                          {:showInferredType false
                                           :showImplicitArguments false
                                           :showImplicitConversionsAndClasses false
                                           :superMethodLensesEnabled true
                                           :enableSemanticHighlighting true
                                           :enableIndentOnPaste true
                                           :inlayHints {:inferredTypes {:enable false}
                                                        :typeParameters {:enable false}
                                                        :implicitArguments {:enable false}
                                                        :implicitConversions {:enable false}
                                                        :hintsInPatternMatch {:enable false}}}))
                (set base.capabilities default_capabilities)
                (set base.init_options.statusBarProvider :on)
                (set base.root_dir root_dir)
                (set base.on_attach on_attach)
                base)))

[{1 :scalameta/nvim-metals
  :ft [:scala :sbt :java]
  :dependencies [:nvim-lua/plenary.nvim :hrsh7th/cmp-nvim-lsp]
  : opts
  :config (fn [_ metals_config]
            (let [metals (require :metals)
                  group (vim.api.nvim_create_augroup :nvim-metals {:clear true})
                  original_register (. vim.lsp.handlers
                                       :client/registerCapability)]
              (set vim.lsp.handlers.client/registerCapability
                   (fix_watcher_glob original_register))
              (vim.api.nvim_create_autocmd :FileType
                                           {:pattern [:scala :sbt :java]
                                            : group
                                            :callback (fn []
                                                        (metals.initialize_or_attach metals_config))})
              (vim.api.nvim_create_autocmd :User
                                           {:pattern :MetalsStatus
                                            : group
                                            :callback (fn [args]
                                                        (set vim.g.metals_status
                                                             (or (and args.data
                                                                      args.data.text)
                                                                 "")))})))}]
