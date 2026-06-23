;;; init.el --- User Emacs configuration

;; Author: brahayan-dev
;; Commentary: Minimal vanilla Emacs configuration. Managed by Ansible
;; via symlink from ~/.dotfiles/files/emacs/.

;;; Code:

;; -----
;; UI
;; -----

(setq-default line-number-mode t)
(setq-default display-line-numbers-type 'relative)

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

;; Theme — built-in, no package required.
(load-theme 'modus-vivendi t)

;; Font — Fira Code, available on Linux/macOS via the system.
(setq default-frame-alist
      '((font . "Fira Code-14")))

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
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Smooth scrolling.
(setq scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position t)

(provide 'init)
;;; init.el ends here