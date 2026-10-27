(local mappings (require :mappings))

(local lsps [:html
             :sqls
             :ts_ls
             :lua_ls
             :yamlls
             :bashls
             :jsonls
             :tofu_ls
             :fennel_ls
             :ansiblels
             :pyright
             :astro
             :rescriptls
             :just_lsp])

(local lua_ls_settings {:Lua {:diagnostics {:globals [:vim]}}})

(local html_settings
       {:filetypes [:html] :init_options {:provideFormatter false}})

(fn npm-global-root []
  (let [out (vim.fn.systemlist "npm root -g")]
    (if (and (= vim.v.shell_error 0) (. out 1)) (. out 1))))

(fn astro_before_init [_ config]
  (let [{: get_typescript_server_path} (require :lspconfig.util)
        found (get_typescript_server_path config.root_dir)
        tsdk (if (not= found "")
                 found
                 (let [root (npm-global-root)]
                   (if root (.. root "/typescript/lib") "")))]
    (set config.init_options (or config.init_options {}))
    (tset config.init_options :typescript
          (or config.init_options.typescript {}))
    (tset config.init_options.typescript :tsdk tsdk)))

(local astro_settings {:before_init astro_before_init})

(local just_lsp_settings {:cmd [:just-lsp]
                          :filetypes [:just]
                          :root_markers [:justfile]})

(fn capabilities_with_encoding []
  (let [{: default_capabilities} (require :cmp_nvim_lsp)]
    (vim.tbl_deep_extend :force (default_capabilities)
                         {:general {:positionEncodings [:utf-16]}})))

[{1 :neovim/nvim-lspconfig
  :lazy false
  :dependencies [:hrsh7th/cmp-nvim-lsp]
  :config (fn []
            (vim.lsp.config "*" {:capabilities (capabilities_with_encoding)})
            (vim.lsp.config :lua_ls {:settings lua_ls_settings})
            (vim.lsp.config :html html_settings)
            (vim.lsp.config :astro astro_settings)
            (vim.lsp.config :just_lsp just_lsp_settings)
            (vim.diagnostic.config {:virtual_text true})
            (each [_ lsp (ipairs lsps)]
              (vim.lsp.enable lsp))
            (mappings.lsp))}]
