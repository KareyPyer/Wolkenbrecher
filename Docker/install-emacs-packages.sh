#!/bin/bash
emacs --batch -l package --eval="(progn
  (require 'package)
  (add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t)
  (add-to-list 'package-archives '(\"gnu\" . \"https://elpa.gnu.org/packages/\") t)
  (package-initialize)
  (unless package-archive-contents (package-refresh-contents))
  (dolist (pkg '(elpy ein jupyter graphviz-dot-mode slime cider magit org
               org-bullets org-roam ob-clojure ob-python ob-lisp ob-R ob-julia
               lsp-mode lsp-ui company-lsp julia-mode ess pyvenv markdown-mode
               doom-themes dashboard))
    (unless (package-installed-p pkg)
      (ignore-errors (package-install pkg)))))"
