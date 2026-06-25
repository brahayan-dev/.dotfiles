;;; init.el --- User Emacs configuration. -*- lexical-binding: t; -*-

;; Author: Brahayan Xavier
;; ~/.dotfiles/files/emacs/.

;;; Code:

;; -----
;; UI
;; -----

(setq-default line-number-mode t)
(global-display-line-numbers-mode 1)

(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      use-short-answers t)

(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

(menu-bar-mode 0)
(scroll-bar-mode 0)
(tool-bar-mode 0)
(tooltip-mode 0)

(defun current-font ()
  "Return the Fira Code font spec string for the current system."
  (let ((size (cond ((eq system-type 'darwin) 18)
                    ((eq system-type 'gnu/linux) 16)
                    (t 14))))
    (format "Fira Code-%d" size)))

(add-to-list 'default-frame-alist (cons 'font (current-font)))

;; Pixel-wise resizing avoids gap glitches under tiling WMs.
(setq frame-resize-pixelwise t)

;; Transparency — 85% opaque background.
(set-frame-parameter (selected-frame) 'alpha '(85 60))
(add-to-list 'default-frame-alist '(alpha . (85 60)))

;; -----
;; Editing
;; -----

(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 100)

(show-paren-mode 1)
(electric-pair-mode 1)
(electric-indent-mode 1)
(delete-selection-mode 1)

;; -----
;; History & files
;; -----

(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(setq recentf-max-menu-items 25
      recentf-save-file (locate-user-emacs-file "recentf"))

(setq uniquify-buffer-name-style 'forward
      uniquify-separator "/"
      uniquify-after-kill-buffer-flag t)

;; -----
;; Misc
;; -----

(global-auto-revert-mode 1)
(setq create-lockfiles nil
      auto-revert-avoid-polling t
      auto-revert-interval 5)

(set-language-environment "UTF-8")
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(setq scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position t)

;; -----
;; Auto Save
;; -----

(defvar auto-save-directory
  (expand-file-name "auto-save/" user-emacs-directory)
  "Directory where auto-save files are stored.")
(make-directory auto-save-directory t)
(setq auto-save-file-name-transforms
      `((".*" ,auto-save-directory t)))

;; -----
;; Native compilation
;; -----

;; Silence async compile warnings; keep .eln-cache loads, skip main-thread JIT.
(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (setq native-comp-async-report-warnings-errors nil
        native-comp-jit-compilation t
        package-native-compile nil))

;; -----
;; Packages
;; -----

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(require 'use-package)
(setq use-package-always-ensure t)

;; GUI Emacs on macOS lacks the shell PATH; inherit it so clj-kondo,
;; metals, guile, etc. are found.
(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

;; -----
;; Theme
;; -----

(use-package ef-themes
  :demand t
  :config
  (load-theme 'ef-bio t))

;; -----
;; Completion
;; -----

(use-package corfu
  :bind (:map corfu-map
              ("TAB" . corfu-next)
              ([tab] . corfu-next)
              ("C-<tab>" . corfu-previous))
  :custom
  (corfu-cycle t)
  (corfu-preselect 'first)
  :hook (after-init . global-corfu-mode))

(setq tab-always-indent 'complete)

(use-package cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-elisp-symbol))

;; -----
;; Minibuffer (Vertico + Marginalia + Orderless)
;; -----

(use-package vertico
  :init
  (vertico-mode)
  (setq vertico-cycle t))

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; -----
;; Modal editing — xah-fly-keys
;; -----

;; Defaults kept: C-s save, C-z undo, C-w close; meta key off (preserves
;; M-j avy); C-x and C-c namespaces are intact. Register the leader with which-key.
(use-package xah-fly-keys
  :demand t
  :config
  (xah-fly-keys-set-layout "qwerty")
  (xah-fly-keys 1))

(use-package which-key
  :demand t
  :config
  (which-key-mode 1)
  (which-key-add-key-based-replacements
    "SPC" 'xah-fly-leader-key-map))

;; -----
;; Navigation
;; -----

(use-package avy
  :bind (("M-j" . avy-goto-char-timer)
         :map isearch-mode-map
         ("C-'" . avy-isearch)))

(use-package consult
  :demand t
  :bind (("C-c i" . consult-imenu)
         ("C-c s" . consult-ripgrep)
         ("C-c b" . consult-buffer)
         ("C-c r" . consult-recent-file)
         ("C-c o" . consult-outline)))

;; -----
;; Structural editing (Lisps)
;; -----

(use-package paredit
  ;; Unbind RET so it doesn't break eval in the CIDER REPL.
  :bind (:map paredit-mode-map ("RET" . nil))
  :hook ((cider-repl-mode . paredit-mode)
         (clojure-mode . paredit-mode)
         (clojurescript-mode . paredit-mode)
         (clojurec-mode . paredit-mode)
         (emacs-lisp-mode . paredit-mode)
         (lisp-mode . paredit-mode)
         (lisp-data-mode . paredit-mode)
         (scheme-mode . paredit-mode)
         (geiser-repl-mode . paredit-mode)
         (inferior-scheme-mode . paredit-mode)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Keep indentation always correct — only in Lisps where it's a win.
(use-package aggressive-indent
  :hook ((emacs-lisp-mode . aggressive-indent-mode)
         (lisp-mode . aggressive-indent-mode)
         (lisp-data-mode . aggressive-indent-mode)
         (scheme-mode . aggressive-indent-mode)
         (clojure-mode . aggressive-indent-mode)
         (clojurescript-mode . aggressive-indent-mode)
         (clojurec-mode . aggressive-indent-mode)))

;; -----
;; Project
;; -----

(use-package projectile
  :custom
  (projectile-completion-system 'default)
  :hook (after-init . projectile-mode))

;; -----
;; Clojure
;; -----

(use-package clojure-mode
  :mode (("\\.edn\\'" . clojure-mode)
         ("\\.cljs\\'" . clojurescript-mode)
         ("\\.cljc\\'" . clojurec-mode))
  :config
  (add-hook 'clojure-mode-hook #'subword-mode))

(use-package cider
  :commands (cider-jack-in cider-jack-in-clojurescript)
  :config
  (setq cider-repl-use-pretty-printing t
        cider-download-java-sources t
        cider-auto-select-error-buffer t
        cider-repl-pop-to-buffer-on-connect nil
        cider-repl-wrap-history t
        cider-test-report-on-success nil))

(use-package clj-refactor
  :hook (clojure-mode . clj-refactor-mode)
  :config
  (cljr-add-keybindings-with-modifier "C-c"))

;; clj-kondo linter. Loading the package registers clj-kondo-clj/cljs/cljc/edn
;; flycheck checkers (auto-selected per major mode). Requires the `clj-kondo'
;; binary on PATH (`cs install clj-kondo' or `brew install clj-kondo').
(use-package flycheck-clj-kondo
  :after flycheck
  :config
  (require 'flycheck-clj-kondo))

;; CIDER auto-integrates with sesman once installed (registers its
;; session system + menu). Declaring it just ensures it's present.
(use-package sesman
  :after cider)

;; -----
;; Nubank
;; -----

;; nu IDE tooling from nudev — not on MELPA, loaded from the local
;; checkout only when it exists (life/linux skip cleanly). nu-lsp needs
;; no lsp-mode, so it coexists with Eglot.
(when (file-directory-p (expand-file-name "~/dev/nu/nudev/ides/emacs"))
  (use-package s)
  (use-package dash)
  (use-package request)
  (use-package graphql-mode)
  (use-package parseedn)
  (use-package nu
    :ensure nil
    :load-path ("~/dev/nu/nudev/ides/emacs/"
                "~/dev/nu/nudev/ides/emacs/test/")
    :commands (nu nu-datomic-query nu-session-switch)
    :config
    (require 'nu)
    (require 'nu-metapod)
    (require 'nu-datomic-query)))

;; -----
;; Scheme
;; -----

(use-package scheme
  :ensure nil
  :mode (("\\.scm\\'" . scheme-mode))
  :custom
  (scheme-program-name "guile"))

(use-package geiser
  :commands (geiser run-geiser))

(use-package geiser-guile
  :after geiser
  :custom
  (geiser-default-implementation 'guile))

;; Stepwise Scheme macro expansion backed by Geiser.
(use-package macrostep-geiser
  :hook ((geiser-mode . macrostep-geiser-setup)
         (geiser-repl-mode . macrostep-geiser-setup)))

;; -----
;; Emacs Lisp
;; -----

(use-package prog-mode
  :ensure nil
  :hook ((emacs-lisp-mode . prettify-symbols-mode)
         (scheme-mode . prettify-symbols-mode)))

(use-package macrostep
  :bind (:map emacs-lisp-mode-map ("C-c e" . macrostep-expand)))

;; -----
;; LSP (Eglot)
;; -----

;; Clojure goes through CIDER; Eglot drives the rest (Scala via Metals).
;; Use `M-x eglot' to start it manually elsewhere.
(use-package eglot
  :ensure nil
  :hook (scala-mode . eglot-ensure)
  :custom
  (eglot-connect-timeout 120)
  (eglot-extend-to-xref t)
  :config
  (add-to-list 'eglot-server-programs '(scala-mode "metals")))

;; -----
;; Flycheck
;; -----

;; Eglot reports LSP diagnostics via Flymake, not Flycheck.
(use-package flycheck
  :hook (after-init . global-flycheck-mode))

;; -----
;; CSS
;; -----

(use-package css-mode
  :ensure nil
  :mode ("\\.css\\'" . css-mode)
  :custom
  (css-indent-offset 2))

;; -----
;; JavaScript
;; -----

(use-package js
  :ensure nil
  :mode ("\\.js\\'" . js-mode)
  :custom
  (js-indent-level 2))

;; -----
;; Markdown
;; -----

(use-package markdown-mode
  :mode "\\.md\\'"
  :custom
  (markdown-hide-urls t)
  :config
  (add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode)))

;; -----
;; YAML
;; -----

(use-package yaml-mode
  :mode (("\\.ya?ml\\'" . yaml-mode)))

;; -----
;; SQL
;; -----

(use-package sql
  :ensure nil
  :mode ("\\.sql\\'" . sql-mode))

(use-package sql-indent
  :hook (sql-mode . sqlind-minor-mode))

;; -----
;; Web mode
;; -----

(use-package web-mode
  :mode (("\\.html\\'" . web-mode)
         ("\\.jsx\\'" . web-mode))
  :custom
  (web-mode-code-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-markup-indent-offset 2))

;; -----
;; Dired
;; -----

(use-package dired
  :ensure nil
  :bind (("C-x C-d" . dired))
  :commands (dired)
  :custom
  (dired-dwim-target t)
  (dired-listing-switches "-alh"))

;; -----
;; Git
;; -----

(use-package magit
  :bind (("C-x C-g" . magit-status))
  :config
  (setq magit-stage-all-confirm nil
        magit-unstage-all-confirm nil
        ediff-window-setup-function 'ediff-setup-windows-plain
        magit-revision-insert-related-refs nil
        magit-diff-refine-hunk t))

;; -----
;; Terminal
;; -----

;; vterm compiles a native module on first use; needs cmake + libvterm.
(use-package vterm
  :commands (vterm)
  :custom (vterm-max-scrollback 100000))

;; -----
;; Warnings
;; -----

;; Surface warnings during diagnosis — :emergency hides real failures.
(use-package warnings
  :ensure nil
  :custom
  (warning-minimum-level :warning))

;; -----
;; After init
;; -----

(defun load-if-exists (f)
  "Load the Emacs Lisp file F if it exists."
  (when (file-exists-p f)
    (load f)))

(add-hook
 'after-init-hook
 (lambda ()
   ;; Per-system config: ~/.dotfiles/files/emacs/<system-name>.el
   (load-if-exists (concat user-emacs-directory (system-name) ".el"))))

(provide 'init)
;;; init.el ends here
