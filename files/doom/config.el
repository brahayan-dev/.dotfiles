;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq
 confirm-kill-emacs nil
 mode-line-default-help-echo nil
 show-help-function nil

 read-process-output-max (* 1024 1024)

 projectile-project-search-path '("~/dev/nu/")
 projectile-enable-caching nil

 evil-split-window-below t
 evil-vsplit-window-right t

 doom-font (font-spec :family "Fira Code" :size 18)
 doom-symbol-font (font-spec :size 18)
 doom-big-font-increment 2

 doom-theme 'doom-nord-light
 doom-themes-treemacs-theme "all-the-icons"
 doom-localleader-key ","

 +format-on-save-enabled-modes '(dart-mode)

 treemacs-width-is-initially-locked nil
 evil-collection-setup-minibuffer t)

(use-package! cider
  :after clojure-mode
  :config
  (setq cider-show-error-buffer t ;'only-in-repl
        cider-font-lock-dynamically nil ; use lsp semantic tokens
        cider-eldoc-display-for-symbol-at-point nil ; use lsp
        cider-prompt-for-symbol nil
        cider-reuse-dead-repls nil
        cider-clojure-cli-aliases "dev:test"
        cider-jack-in-nrepl-middlewares '("metrepl/middleware" "cider.nrepl/cider-middleware")
        cider-use-xref nil) ; use lsp
  (set-lookup-handlers! '(cider-mode cider-repl-mode) nil) ; use lsp
  (set-popup-rule! "*cider-test-report*" :side 'right :width 0.4)
  (set-popup-rule! "^\\*cider-repl" :side 'bottom :quit nil)
  ;; use lsp completion
  (add-hook 'cider-mode-hook (lambda () (remove-hook 'completion-at-point-functions #'cider-complete-at-point))))

(use-package! clj-refactor
  :after clojure-mode
  :config
  (set-lookup-handlers! 'clj-refactor-mode nil)
  (setq cljr-warn-on-eval nil
        cljr-eagerly-build-asts-on-startup nil
        cljr-add-ns-to-blank-clj-files nil ; use lsp
        cljr-magic-require-namespaces
        '(("s"   . "schema.core")
          ("gen" . "common-test.generators")
          ("d-pro" . "common-datomic.protocols.datomic")
          ("ex" . "common-core.exceptions.core")
          ("dth" . "common-datomic.test-helpers")
          ("t-money" . "common-core.types.money")
          ("t-time" . "common-core.types.time")
          ("d" . "datomic.api")
          ("m" . "matcher-combinators.matchers")
          ("pp" . "clojure.pprint"))))

(use-package! clojure-mode
  :config
  (setq clojure-indent-style 'align-arguments))

(use-package! lsp-mode
  :commands lsp
  :config

  ;; Core
  (setq lsp-headerline-breadcrumb-enable nil
        lsp-signature-render-documentation nil
        lsp-signature-function 'lsp-signature-posframe
        lsp-signature-auto-activate nil
        lsp-completion-provider :none
        lsp-semantic-tokens-enable t
        lsp-enable-indentation nil
        lsp-inlay-hint-enable t
        lsp-idle-delay 0.05 ;; Smoother LSP features response in cost of performance (Most servers I use have good performance)
        lsp-use-plists t)
  (add-hook 'lsp-after-apply-edits-hook (lambda (&rest _) (save-buffer)))

  ;; Clojure
  (let ((clojure-lsp-dev (expand-file-name "~/dev/clojure-lsp/clojure-lsp")))
    (when (file-exists-p clojure-lsp-dev)
      (setq lsp-clojure-custom-server-command `("bash" "-c" ,clojure-lsp-dev)
            lsp-completion-no-cache t
            lsp-completion-use-last-result nil)))

  ;; Copilot
  (setq lsp-copilot-enabled nil))

(use-package! lsp-treemacs
  :config
  (setq lsp-treemacs-error-list-current-project-only t))

(use-package! lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-peek-enable nil))

(use-package! paredit
  :hook ((clojure-mode . paredit-mode)
         (emacs-lisp-mode . paredit-mode)))

(use-package! treemacs-all-the-icons
  :after treemacs)
