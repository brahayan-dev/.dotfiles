(local mappings (require :mappings))

(local options {:defaults {:file_ignore_patterns [:.git/]}
                :pickers {:find_files {:hidden true
                                       :theme :ivy
                                       :find_command [:fd
                                                      :--type
                                                      :f
                                                      :--hidden
                                                      :--exclude
                                                      :.git]}}})

(fn ->config []
  (let [telescope (require :telescope)
        {: get_dropdown} (require :telescope.themes)
        dropdown (get_dropdown {})]
    (set options.extensions {[:ui-select] dropdown})
    (telescope.setup options)
    (mappings.telescope)
    (telescope.load_extension :ui-select)))

[{1 :nvim-telescope/telescope-ui-select.nvim}
 {1 :nvim-telescope/telescope.nvim
  :dependencies [:nvim-lua/plenary.nvim
                 {1 :nvim-telescope/telescope-fzf-native.nvim :build :make}]
  :config ->config}]
