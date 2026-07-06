;;; init.el --- User Emacs configuration. -*- lexical-binding: t; -*-

;; Author: Brahayan Xavier
;; ~/.dotfiles/files/emacs/.

;;; Code:

;; -----
;; Built-in tweaks — UI, editing, history & files, misc
;; -----

(use-package emacs
  :ensure nil
  :init
  (setq-default line-number-mode t)

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

  ;; Editing
  (setq-default indent-tabs-mode nil
                tab-width 2
                fill-column 100)

  (show-paren-mode 1)
  (delete-selection-mode 1)

  ;; History & files
  (savehist-mode 1)
  (save-place-mode 1)
  (recentf-mode 1)
  (setq recentf-max-menu-items 25
        recentf-save-file (locate-user-emacs-file "recentf"))

  (setq uniquify-buffer-name-style 'forward
        uniquify-separator "/"
        uniquify-after-kill-buffer-flag t)

  ;; Misc
  (global-auto-revert-mode 1)
  (setq create-lockfiles nil
        auto-revert-avoid-polling t
        auto-revert-interval 5)

  (set-language-environment "UTF-8")
  (setq locale-coding-system 'utf-8
        default-coding-systems 'utf-8
        terminal-coding-system 'utf-8
        keyboard-coding-system 'utf-8
        selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)

  (setq scroll-step 1
        scroll-conservatively 10000
        scroll-preserve-screen-position t)

  ;; Warnings — surface during diagnosis; :emergency hides real failures.
  (setq warning-minimum-level :warning))

(use-package prog-mode
  :ensure nil
  :hook ((prog-mode . display-line-numbers-mode)
         (prog-mode . prettify-symbols-mode)))

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
;; Backups
;; -----

(defvar backup-directory
  (expand-file-name "backups/" user-emacs-directory)
  "Directory where Emacs keeps backup files.")
(make-directory backup-directory t)
(setq backup-directory-alist
      `((".*" ,backup-directory t))
      make-backup-files t
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 5
      kept-old-versions 2)

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
  (tab-always-indent 'complete)
  :hook (after-init . global-corfu-mode))

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

;; Defaults kept: C-s save, C-z undo, C-w close.
;; Meta key, C-x and C-c namespaces are intact.
;; Register the leader with which-key.
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

(use-package consult
  :demand t
  :bind (("C-c i" . consult-imenu)
         ("C-c s" . consult-ripgrep)
         ("C-c b" . consult-buffer)
         ("C-c r" . consult-recent-file)
         ("C-c o" . consult-outline)))

;; Jump to any visible position: type a char, then the overlay label.
(use-package avy
  :bind (("M-j" . avy-goto-char-timer)
         :map isearch-mode-map
         ("C-'" . avy-isearch)))

;; -----
;; Structural editing (Lisps)
;; -----

(use-package paredit
  ;; Unbind RET so it doesn't break eval in the CIDER REPL.
  :bind (:map paredit-mode-map ("RET" . nil))
  :hook ((clojure-mode . paredit-mode)
         (lisp-mode . paredit-mode)
         (scheme-mode . paredit-mode)
         (cider-repl-mode . paredit-mode)
         (geiser-repl-mode . paredit-mode)
         (inferior-scheme-mode . paredit-mode)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Keep indentation always correct — only in Lisps where it's a win.
(use-package aggressive-indent
  :hook ((lisp-mode . aggressive-indent-mode)
         (lisp-data-mode . aggressive-indent-mode)
         (scheme-mode . aggressive-indent-mode)
         (clojure-mode . aggressive-indent-mode)))

;; -----
;; Clojure
;; -----

(use-package clojure-mode
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

;; clj-kondo linter. Loading the package registers clj-kondo-clj/cljs/cljc/edn
;; flycheck checkers (auto-selected per major mode). Requires the `clj-kondo'
;; binary on PATH (`cs install clj-kondo' or `brew install clj-kondo').
(use-package flycheck-clj-kondo
  :after flycheck)

;; CIDER auto-integrates with sesman once installed (registers its
;; session system + menu). Declaring it just ensures it's present.
(use-package sesman
  :after cider)

;; -----
;; Scala — Eglot + Metals
;; -----

;; `metals' must be on PATH; `workstation install scala' installs it via
;; coursier (`cs install metals'). `exec-path-from-shell' above inherits
;; the shell PATH, so GUI Emacs finds it.
(use-package scala-ts-mode
  :ensure nil
  :mode "\\.s\\(cala\\|bt\\|sc\\)$"
  :config
  (add-hook 'scala-ts-mode-hook #'eglot-ensure)
  (add-hook 'scala-ts-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'eglot-format nil t))))

;; Editing build.sbt; Eglot starts Metals for sbt files too.
(use-package sbt-mode
  :mode "\\.sbt\\'"
  :config
  (add-hook 'sbt-mode-hook #'eglot-ensure))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((scala-mode scala-ts-mode) . ("metals"))))

;; -----
;; ECA — Editor Code Assistant
;; -----

;; Native Ollama provider. ECA talks straight to Ollama's `/api/chat'
;; endpoint. Both cloud models you currently use via `ollama launch'
;; are listed explicitly so ECA's model picker shows them.
(use-package eca
  :vc (:url "https://github.com/editor-code-assistant/eca-emacs"
            :rev :newest
            :files ("*.el"))
  :hook ((eca-chat-mode . (lambda ()
                            (when (bound-and-true-p xah-fly-mode)
                              (xah-fly-mode -1))))
         (eca-chat-mode-exit . (lambda ()
                                 (when (fboundp 'xah-fly-keys)
                                   (xah-fly-keys 1)))))
  :custom
  (eca-server-download-method 'curl)
  (eca-chat-auto-add-cursor t)
  (eca-chat-auto-add-repomap t)
  (eca-chat-read-only-history t))

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
  :hook ((scheme-mode . geiser-mode)))

(use-package geiser
  :commands (geiser run-geiser)
  :custom
  (geiser-mode-autodoc-p t)
  (geiser-mode-start-repl-p nil))

(use-package geiser-guile
  :after geiser
  :custom
  (geiser-default-implementation 'guile)
  :config
  (setq scheme-program-name "guile"
        geiser-repl-history-filename "~/.config/emacs/geiser-history"
        ;; One REPL per project. `project-current' returns a cons cell
        ;; (e.g. `(projectile . "/path/")` or `(vc Git "/path/")`),
        ;; but Geiser feeds it directly to `file-name-nondirectory'
        ;; (geiser-repl.el:381) which expects a string — extract the
        ;; root path first.
        geiser-repl-per-project-p t
        geiser-repl-current-project-function
        (lambda () (when-let* ((proj (project-current)))
                     (project-root proj)))))

;; Stepwise Scheme macro expansion backed by Geiser.
(use-package macrostep-geiser
  :hook ((geiser-mode . macrostep-geiser-setup)
         (geiser-repl-mode . macrostep-geiser-setup)))

(use-package macrostep
  :bind (:map emacs-lisp-mode-map ("C-c e" . macrostep-expand)))

;; -----
;; Flycheck
;; -----

(use-package flycheck
  :hook (after-init . global-flycheck-mode))

;; -----
;; CSS
;; -----

(use-package css-mode
  :ensure nil
  :custom
  (css-indent-offset 2))

;; -----
;; JavaScript
;; -----

(use-package js
  :ensure nil
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
  :ensure nil)

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
  (setq magit-revision-insert-related-refs nil
        magit-diff-refine-hunk t))

;; -----
;; Terminal
;; -----

(use-package vterm
  :ensure t
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

;; Per-system config: ~/.dotfiles/files/emacs/<system-name>.el
(let ((file (concat user-emacs-directory (system-name) ".el")))
  (when (file-exists-p file)
    (load file)))

(provide 'init)
;;; init.el ends here
