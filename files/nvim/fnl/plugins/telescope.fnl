(local options {:defaults {:file_ignore_patterns [:.git/]}
                :pickers {:find_files {:hidden true
                                       :theme :ivy
                                       :find_command [:fd
                                                      :--type
                                                      :f
                                                      :--hidden
                                                      :--exclude
                                                      :.git]}}})

[{1 :nvim-telescope/telescope-ui-select.nvim}
 {1 :nvim-telescope/telescope.nvim
  :dependencies [:nvim-lua/plenary.nvim
                 {1 :nvim-telescope/telescope-fzf-native.nvim :build :make}]
  :config (fn []
            (let [telescope (require :telescope)
                  themes (require :telescope.themes)
                  dropdown ((. themes :get_dropdown) {})]
              (set options.extensions {[:ui-select] dropdown})
              (telescope.setup options)
              ((. (require :mappings) :telescope))
              (telescope.load_extension :ui-select)))}]
