(fn hidden? [name _]
  (var result false)
  (each [_ v (ipairs [".."
                      :.git
                      :.vault_
                      :.become_
                      :.parcel-cache
                      :dist
                      :node_modules])]
    (when (= name v)
      (set result true)))
  result)

(local setup
       {:delete_to_trash false
        :skip_confirm_for_simple_edits true
        :float {:padding 2 :max_width 90 :max_height 0 :border :rounded}
        :win_options {:signcolumn :no :number false :relativenumber false}
        :view_options {:show_hidden true :is_always_hidden hidden?}})

[{1 :stevearc/oil.nvim
  :config (fn []
            (let [oil (require :oil)]
              (oil.setup setup)
              ((. (require :mappings) :oil) oil)))}]
