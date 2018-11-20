(require 'package)
(add-to-list 'package-archives '("elpy" . "http://jorgenschaefer.github.io/packages"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))


;; Startup optimizations
(setq gc-cons-threshold-original gc-cons-threshold)
(setq gc-cons-threshold (* 1024 1024 100))

(setq file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)

(run-with-idle-timer
 5 nil
 (lambda ()
   (setq gc-cons-threshold gc-cons-threshold-original)
   (setq file-name-handler-alist file-name-handler-alist-original)
   (makunbound 'gc-cons-threshold-original)
   (makunbound 'file-name-handler-alist-original)))

(unless package-archive-contents
  (package-refresh-contents))

(eval-when-compile
  (require 'use-package))
(require 'cc-mode)

(require 'ansi-color)
(defun my/colorize-compilation-buffer ()
  (read-only-mode 1)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (read-only-mode nil))

(defun my/disable-scroll-bars (frame)
  (modify-frame-parameters frame
                           '((vertical-scroll-bars . nil)
                             (horizontal-scroll-bars . nil))))
(add-hook 'after-make-frame-functions 'my/disable-scroll-bars)
(add-hook 'compilation-filter-hook 'my/colorize-compilation-buffer)

(defvar compilation-scroll-output t)

(add-to-list
 'command-switch-alist
 '("-cwd" . (lambda (x) (setq default-directory (or x (getenv "PWD"))))))

(defun my/toggle-show-trailing-whitespace ()
  "Toggle 'show-trailing-whitespace' between t and nil."
  (interactive)
  (setq show-trailing-whitespace (not show-trailing-whitespace)))

(add-hook 'after-save-hook (lambda () (whitespace-cleanup)))

;; Backup config
(setq backup-directory-alist '(("." . "~/.saves")))
(setq backup-by-copying t)
(desktop-save-mode 1)

(global-set-key (kbd "<f12>") 'whitespace-mode)

;; Fix C-n/C-p stutter
(setq auto-window-vscroll nil)

;; Disable menu bar,tool bar and scroll bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Indentation
(defun my/c-mode-hook ()
  (defvar c-indent-level 4)
  (setq c-basic-offset 4)
  (setq c-default-style "bsd"))
(add-hook 'c-mode-common-hook 'my/c-mode-hook)
(setq c-default-style "bsd")

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(defun my/back-to-indentation-or-beginning ()
  "If at the beginning of line go to indentation.
   If at the indentation go to the beginning of line.
   Go to indentation otherwise."
  (interactive)
  (if (bolp) (back-to-indentation) (beginning-of-line)))

(global-set-key (kbd "<home>") 'my/back-to-indentation-or-beginning)
(global-set-key (kbd "C-a") 'my/back-to-indentation-or-beginning)

(add-to-list 'auto-mode-alist '("'\\.h\\'" . c++-mode))

(use-package diminish :ensure t)
(use-package restart-emacs :ensure t)
(use-package magit :ensure t)
(use-package git-timemachine :ensure t)
(use-package which-key :ensure t :diminish which-key-mode :config (which-key-mode))
(use-package hl-todo :ensure t :config (global-hl-todo-mode 1))
(use-package rainbow-delimiters :ensure t :hook ((prog-mode . rainbow-delimiters-mode)))
(use-package neotree :ensure t :bind (([f8] . neotree-toggle)))
(use-package ace-window :ensure t :bind ("M-o" . ace-window))

(diminish abbrev-mode)
(diminish eldoc-mode)
(diminish auto-revert-mode)

(use-package org
  :ensure t
  :bind
  ("C-c l" . org-store-link)
  ("C-c a" . org-agenda)
  ("C-c c" . org-capture)
  ("C-c b" . org-swhichb))

(use-package org-bullets
  :ensure t
  :hook ((org-mode . (lambda () (org-bullets-mode 1)))))

(use-package semantic
  :ensure t
  :config
  (global-semanticdb-minor-mode 1)
  (global-semantic-idle-scheduler-mode 1)
  (global-semantic-idle-summary-mode 1)
  (semantic-mode -1))

(use-package async
  :ensure t
  :config
  (dired-async-mode 1)
  (async-bytecomp-package-mode 1))

;; (use-package solarized-theme
;;   :ensure t
;;   :init
;;   (setq solarized-height-minus-1 1.0)
;;   (setq solarized-height-plus-1 1.0)
;;   (setq solarized-height-plus-2 1.0)
;;   (setq solarized-height-plus-3 1.0)
;;   (setq solarized-height-plus-4 1.0)
;;   (setq solarized-use-more-italic t)
;;   (setq x-underline-at-descent-line t)
;;   :config
;;   (load-theme 'solarized-dark t)
;;   (global-hl-line-mode 1))

(use-package zenburn-theme
  :ensure t
  :init
  (load-theme 'zenburn t)
  (global-hl-line-mode 1))

(use-package helm
  :ensure t
  :diminish helm-mode
  :config
  (progn
    (require 'helm-config)
    (require 'helm)
    (require 'helm-eshell)

    (define-key helm-map (kbd "C-c h") 'helm-execute-persistent-action)
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ;; Make TAB work in terminal
    (define-key helm-map (kbd "C-z") 'helm-select-action)
    ;;(define-key shell-mode-map (kbd "C-c C-l") 'helm-comint-input-ring)
    (define-key minibuffer-local-map (kbd "C-c C-l") 'helm-minibuffer-history)
    (add-hook 'eshell-mode-hook #'(lambda ()
                                    (define-key eshell-mode-map (kbd "C-c C-l") 'helm-eshell-history)))

    ;; Open helm buffer inside current window
    (setq helm-split-window-inside-p t)
    ;; Move to end or beginning of source when reaching top/bottom
    (setq helm-move-to-line-cycle-in-source t)
    ;; Search for library in require and declare-function sexp
    (setq helm-ff-search-library-in-sexp t)
    ;; Scroll 8 lines other window using M-/M-
    (setq helm-scroll-amount 8)
    (setq helm-ff-file-name-history-use-recentf t)
    (setq helm-echo-input-in-header-line t)

    (setq helm-autoresize-max-height 0)
    (setq helm-autoresize-min-height 20)
    (helm-autoresize-mode 1)

    (global-set-key (kbd "M-x") 'helm-M-x)
    (global-set-key (kbd "C-x r b") 'helm-filtered-bookmarks)
    (global-set-key (kbd "C-x C-f") 'helm-find-files)
    (global-set-key (kbd "M-y") 'helm-show-kill-ring)
    (global-set-key (kbd "C-x b") 'helm-mini)
    (global-set-key (kbd "C-c h o") 'helm-occur)
    (global-set-key (kbd "C-c h") 'helm-command-prefix)
    (global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)
    (global-set-key (kbd "C-c h x") 'helm-register)
    (global-set-key (kbd "C-c h M-:") 'helm-eval-expression-with-eldoc)
    (global-set-key (kbd "C-x g") 'magit-status)
    (global-unset-key (kbd "C-x c"))

    (add-to-list 'helm-sources-using-default-as-input 'helm-source-man-pages)
    (setq helm-buffers-fuzzy-matching t)
    (setq helm-recentf-fuzzy-match t)
    (setq helm-M-x-fuzzy-match t)
    (setq helm-semantic-fuzzy-match t)
    (setq helm-imenu-fuzzy-match t)
    (setq helm-locate-fuzzy-match t)
    (setq helm-apropos-fuzzy-match t)
    (setq helm-lisp-fuzzy-completion t)
    (helm-mode 1)))

(use-package helm-gtags
  :ensure t
  :diminish helm-gtags-mode
  :hook ((c-mode . helm-gtags-mode)
         (c++-mode . helm-gtags-mode)
         (asm-mode . helm-gtags-mode)))

(use-package helm-projectile
  :ensure t
  :config (helm-projectile-on))

(use-package helm-ag
  :ensure t
  :config
  (when (executable-find "ack-grep")
    (setq helm-grep-default-command "ack-grep -Hn -no-group --no-color %e %p %f")
    (setq helm-grep-default-recurse-command "ack-grep -H --no-group --no-color %e %p %f")))

(use-package projectile
  :ensure t
  :defer t
  :diminish projectile-mode
  :init
  (setq projectile-enable-caching t)
  (setq projectile-completion-system 'helm)
  (setq projectile-switch-project-action 'helm-projectile)
  ;;(setq-projectile-indexing-method 'alien) ;; Enable if on windows
  :config (projectile-mode))

(with-eval-after-load 'projectile
  (setq projectile-project-root-files-top-down-recurring
        (append ;;'("compile_commands.json"
         ;;".cquery")
         projectile-project-root-files-top-down-recurring)))

(use-package golden-ratio
  :ensure t
  :diminish golden-ratio-mode
  :config
  (defun pl/helm-alive-p()
    (if (boundp 'helm-alive-p)
        (symbol-value 'helm-alive-p)))
  (golden-ratio-mode 1)
  (setq golden-ratio-auto-scale t)
  (add-to-list 'golden-ratio-inhibit-functions 'pl/helm-alive-p))

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode 1)
    (show-smartparens-global-mode 1)))

;; (use-package company-jedi
;;   :ensure t
;;   :after company
;;   :init
;;   (defvar company-jedy-python-bin "python3")
;;   ;;(setq jedi:environment-virtualenv
;;   ;;(append python-environment-virtualenv '("--python" "/usr/bin/python3")))
;;   (setq py-python-command "/usr/bin/python3")
;;   (add-to-list 'company-backends 'company-jedi))

(use-package company-c-headers
  :ensure t)

(use-package company
  :ensure t
  :diminish company-mode
  :hook ((after-init . global-company-mode))
  :bind ([C-tab] . company-complete)
  :config
  (setq company-async-timeout 5)
  ;;(setq company-transformers nil company-lsp-async t company-lsp-cache-candidates nil)
  (setq company-backends (delete 'company-semantic company-backends))
  (add-to-list 'company-backends 'company-c-headers))

(use-package ede
  :ensure t
  :config (global-ede-mode t))

(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode
  :config (global-undo-tree-mode))

(use-package spaceline
  :ensure t
  :config
  (progn
    (require 'spaceline-config)
    (spaceline-spacemacs-theme)
    (spaceline-helm-mode)))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region)
  :init (pending-delete-mode t))

(use-package aggressive-indent
  :ensure t
  :diminish aggressive-indent-mode
  :init
  (global-aggressive-indent-mode 1)
  :config
  (add-to-list 'aggressive-indent-excluded-modes 'asm-mode 'haskell-mode))

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :init
  (yas-global-mode t))

(use-package ws-butler
  :ensure t
  :diminish ws-butler-mode
  :hook ((prog-mode . ws-butler-mode)))

(use-package anzu
  :ensure t
  :diminish anzu-mode
  :init
  (global-anzu-mode t))
