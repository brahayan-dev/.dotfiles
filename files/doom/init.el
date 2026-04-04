;;; init.el -*- lexical-binding: t; -*-

;; NOTE: Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;   documentation. There you'll find a link to Doom's Module Index where all of
;;   our modules are listed, including what flags they support.

;; NOTE: Move your cursor over a module's name (or its flags) and press 'K' (or
;;   'C-c c k' for non-vim users) to view its documentation. This works on flags
;;   as well (those symbols that start with a plus).
;;
;;   Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;   directory (for easy access to its source code).

(doom! :input

       :completion
       (corfu +orderless)
       vertico

       :ui
       doom
       dashboard
       hl-todo
       ligatures
       modeline
       ophints
       (popup +defaults)
       smooth-scroll
       (vc-gutter +pretty)
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       multiple-cursors
       parinfer
       snippets
       (whitespace +guess +trim)

       :emacs
       dired
       electric
       tramp
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       ansible
       biblio
       debugger
       direnv
       (eval +overlay)
       lookup
       lsp
       magit
       tree-sitter

       :os
       (:if (featurep :system 'macos) macos)
       tty

       :lang
       data
       emacs-lisp
       json
       latex
       markdown
       sh
       web
       yaml
       (clojure +lsp +tree-sitter)
       (javascript  +lsp +tree-sitter)

       :email

       :app

       :config
       (default +bindings +smartparens))
