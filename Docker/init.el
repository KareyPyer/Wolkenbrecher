;; === Packages de base ===
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; === Thème ===
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; === Dashboard ===
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title "Data Analytics Environment")
  (setq dashboard-startup-banner 'official)
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)
                          (agenda . 5)
                          (registers . 5))))

;; === Python ===
(elpy-enable)
(use-package pyvenv
  :ensure t
  :config
  (setq pyvenv-mode-line-indicator "(pyenv)")
  (pyvenv-mode 1))

;; === Jupyter integration ===
(require 'ein)

;; === Graphviz ===
(require 'graphviz-dot-mode)

;; === SLIME pour Common Lisp ===
(setq inferior-lisp-program "/usr/local/bin/ccl")
(require 'slime)
(slime-setup)

;; === CIDER pour Clojure ===
(require 'cider)

;; === R via ESS ===
(require 'ess)

;; === Julia ===
(require 'julia-mode)

;; === LSP (Language Server Protocol) ===
(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  ((python-mode . lsp)
   (clojure-mode . lsp)
   (julia-mode . lsp)
   (ess-mode . lsp))
  
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(use-package company-lsp
  :ensure t
  :config
  (push 'company-lsp company-backends))

;; === Org-mode literate programming ===
(require 'org)
(require 'ob)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (lisp . t)
   (clojure . t)
   (R . t)
   (julia . t)))

(setq org-confirm-babel-evaluate nil)

;; === Markdown support ===
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode))

;; === Améliorations visuelles ===
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(setq org-hide-emphasis-markers t)
(setq org-pretty-entities t)

;; === Interface ===
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(global-display-line-numbers-mode 1)

;; === FastAPI snippets ===
(define-skeleton fastapi-endpoint
  "Insert a FastAPI endpoint template"
  nil
  "@app." (skeleton-read "Method (get/post/put/delete): ") "('/" (skeleton-read "Endpoint path: ") "')" \n
  "async def " (skeleton-read "Function name: ") "(" (skeleton-read "Parameters: ") "):" \n
  > \n
  "return " (skeleton-read "Return value: ") \n)
