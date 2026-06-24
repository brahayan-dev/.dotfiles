;;; init.el --- User Emacs configuration. -*- lexical-binding: t; -*-

;; Author: Brahayan Xavier
;; Commentary: Minimal vanilla Emacs configuration. Managed by Ansible
;; via symlink from ~/.dotfiles/files/emacs/.

;;; Code:

;; -----
;; UI
;; -----

(setq-default line-number-mode t)
(global-display-line-numbers-mode 1)

;; Disable startup splash and message.
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; Yes/No prompts instead of y/n.
(setq use-short-answers t)
(defalias 'yes-or-no-p 'y-or-n-p)

;; Pixel-scroll precision (Emacs 29+).
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; Disable UI clutter.
(menu-bar-mode 0)
(scroll-bar-mode 0)
(tool-bar-mode 0)
(tooltip-mode 0)

;; Theme is configured via ef-themes in the Packages section below.

;; Font — Fira Code, sized per OS (from the old Doom config:
;; macOS 18, Linux 16; 14 elsewhere).
(defun current-font ()
  "Return the Fira Code font spec string for the current system."
  (let ((size (cond ((eq system-type 'darwin) 18)
                    ((eq system-type 'gnu/linux) 16)
                    (t 14))))
    (format "Fira Code-%d" size)))

(add-to-list 'default-frame-alist (cons 'font (current-font)))

;; Resize frames by single pixels rather than rounding to character
;; cells (avoids gap glitches under tiling window managers).
(setq frame-resize-pixelwise t)

;; Transparency — 85% opaque background.
(set-frame-parameter (selected-frame) 'alpha '(85 60))
(add-to-list 'default-frame-alist '(alpha . (85 60)))

;; -----
;; Editing
;; -----

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default fill-column 100)

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
(setq recentf-max-menu-items 25)
(setq recentf-save-file (locate-user-emacs-file "recentf"))

;; Unique buffer names.
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-separator "/")
(setq uniquify-after-kill-buffer-p t)

;; -----
;; Misc
;; -----

;; Auto-revert buffers when the underlying file changes.
(global-auto-revert-mode 1)

;; Don't lock files; revert buffers silently if they change on disk.
(setq create-lockfiles nil)
(setq auto-revert-avoid-polling t)
(setq auto-revert-interval 5)

;; UTF-8 everywhere.
(set-language-environment "UTF-8")
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Smooth scrolling.
(setq scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position t)

;; -----
;; Auto Save
;; -----

;; Keep auto-save files in one directory instead of next to originals.
(defvar auto-save-directory
  (expand-file-name "auto-save/" user-emacs-directory)
  "Directory where auto-save files are stored.")
(make-directory auto-save-directory t)
(setq auto-save-file-name-transforms
      `((".*" ,auto-save-directory t)))

;; -----
;; Native compilation
;; -----

;; Compile installed packages to native code and silence the noisy
;; async compilation warnings. Guarded for builds without native-comp.
(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (setq native-comp-async-report-warnings-errors nil)
  (setq native-comp-jit-compilation t)
  ;; Disabled — was making startup hang for minutes while Emacs
  ;; recompiled MELPA packages to .eln on the main thread.
  ;; Native-compiled packages from eln-cache/ still load fine.
  (setq package-native-compile nil))

;; -----
;; Packages
;; -----

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;; use-package is built-in on Emacs 29+. Always install declared packages.
(require 'use-package)
(setq use-package-always-ensure t)

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

;; Let TAB complete when the line is already indented.
(setq tab-always-indent 'complete)

;; Cape adds extra completion-at-point backends consumed by Corfu.
(use-package cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-elisp-symbol))

;; -----
;; Minibuffer completion (Vertico + Marginalia + Orderless)
;; -----

;; Complements Corfu (which handles in-buffer completion). Vertico
;; shows minibuffer candidates inline, Marginalia annotates them
;; (file sizes, key bindings, etc.), and Orderless matches flexibly
;; (e.g. "spa fly" → flycheck-mode).

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
;; Paredit — structural editing for Lisps (Clojure, Scheme, Elisp)
;; -----

(use-package paredit
  ;; Unbind RET so it doesn't break eval in the CIDER REPL buffer.
  :bind (:map paredit-mode-map ("RET" . nil))
  :hook ((cider-repl-mode . paredit-mode)
         (clojure-mode . paredit-mode)
         (clojurescript-mode . paredit-mode)
         (clojurec-mode . paredit-mode)
         (emacs-lisp-mode . paredit-mode)
         (scheme-mode . paredit-mode)))

;; -----
;; Navigation
;; -----

;; Jump to any visible position: type a char, then the overlay label.
(use-package avy
  :bind (("M-j" . avy-goto-char-timer)
         :map isearch-mode-map
         ("C-'" . avy-isearch)))

;; -----
;; Projectile
;; -----

(use-package projectile
  :bind-keymap ("C-c p" . projectile-command-map)
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
  ;; Pretty print in the REPL.
  (setq cider-repl-use-pretty-printing t)
  ;; Auto-download source artifacts for 3rd-party Java classes.
  (setq cider-download-java-sources t)
  ;; Auto-select the error buffer when displayed.
  (setq cider-auto-select-error-buffer t)
  ;; Don't pop to the REPL buffer on connect.
  (setq cider-repl-pop-to-buffer-on-connect nil)
  ;; Wrap history around when the end is reached.
  (setq cider-repl-wrap-history t)
  ;; Don't show the test report buffer on passing tests.
  (setq cider-test-report-on-success nil))

;; -----
;; Nubank
;; -----

;; The nu IDE tooling from nudev. Not on MELPA — loaded from the local
;; checkout, and only when that checkout exists (so life/linux skip it
;; cleanly). nu's external deps are declared explicitly since nu isn't
;; a package that pulls them in. nu-lsp does not require lsp-mode, so it
;; coexists with our Eglot setup.
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

;; Emacs and Scheme talk to each other.
(use-package geiser
  :commands (geiser run-geiser))

;; The Geiser implementation for Guile.
(use-package geiser-guile
  :after geiser
  :custom
  (geiser-default-implementation 'guile))

;; -----
;; Emacs Lisp
;; -----

;; Render lambda and friends as pretty symbols.
(use-package prog-mode
  :ensure nil
  :hook (emacs-lisp-mode . prettify-symbols-mode))

;; -----
;; LSP (Eglot)
;; -----

;; Eglot is built-in on Emacs 29+. Clojure goes through CIDER, so we
;; don't auto-start an LSP there; Eglot drives the other languages
;; (Scala via Metals). Use `M-x eglot' to start it manually elsewhere.
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

;; On-the-fly syntax checking. Note: Eglot reports LSP diagnostics
;; through Flymake, not Flycheck; add `flycheck-eglot' if you want
;; those surfaced in Flycheck too.
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

;; Context-aware SQL indentation.
(use-package sql-indent
  :hook (sql-mode . sqlind-minor-mode))

;; -----
;; Web mode
;; -----

;; Templating mode for HTML with embedded CSS/JS, and JSX.
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
  ;; Guess a sensible target when two dired windows are open.
  (dired-dwim-target t)
  ;; Show all files with human-readable sizes.
  (dired-listing-switches "-alh"))

;; -----
;; Git
;; -----

(use-package magit
  :bind (("C-x C-g s" . magit-status))
  :config
  (setq magit-stage-all-confirm nil)
  (setq magit-unstage-all-confirm nil)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  ;; Performance optimizations for the magit-revision buffer.
  (setq magit-revision-insert-related-refs nil)
  (setq magit-diff-refine-hunk t))

(use-package forge
  :after magit
  :commands (forge-pull))

;; -----
;; Terminal
;; -----

;; vterm compiles a native module on first use; needs cmake + libvterm.
(use-package vterm
  :commands (vterm)
  :custom
  (vterm-max-scrollback 100000)
  :config
  ;; vterm doesn't bind the mouse wheel, so it falls through to the
  ;; global handler — pixel-scroll-precision-mode — which fights vterm's
  ;; redraws and makes the wheel feel stuck. Bind the wheel locally to
  ;; plain line scrolling through the scrollback; the local binding wins
  ;; over the global pixel-scroll one.
  (dolist (ev '([wheel-up] [double-wheel-up] [triple-wheel-up]))
    (define-key vterm-mode-map ev
                (lambda () (interactive) (scroll-down 3))))
  (dolist (ev '([wheel-down] [double-wheel-down] [triple-wheel-down]))
    (define-key vterm-mode-map ev
                (lambda () (interactive) (scroll-up 3)))))

;; -----
;; MCP
;; -----

;; Client for Model Context Protocol servers. Configure servers via
;; `mcp-hub-servers'; pairs with an in-Emacs LLM client when you add one.
(use-package mcp
  :commands (mcp-hub))

;; -----
;; Warnings
;; -----

;; Surface warnings during diagnosis — :emergency was hiding real
;; failures (flycheck/flymake crashes, package load errors) behind
;; "Emacs appears hung". Keep at :warning; lower to :emergency once
;; the config is known clean.
(use-package warnings
  :ensure nil
  :custom
  (warning-minimum-level :warning))

;; -----
;; After init hook
;; -----

;; Per-system config loader and personal keybindings. Placeholder
;; from r0man's setup — to be cleaned up to taste.

(defun load-if-exists (f)
  "Load the Emacs Lisp file F if it exists."
  (when (file-exists-p f)
    (load f)))

(add-hook
 'after-init-hook
 (lambda ()
   ;; Load system specific config.
   (load-if-exists (concat user-emacs-directory system-name ".el"))
   ;; Personal keybindings (placeholder — to be customized).
   (global-set-key (kbd "C-c n") 'cleanup-buffer)
   (global-set-key (kbd "C-c r") 'rotate-buffers)))

(provide 'init)
;;; init.el ends here
