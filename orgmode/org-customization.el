;; ========================================================================================
;; orgmode customization begin
;; ========================================================================================

;; org-mode
(add-to-list 'load-path org_install_path)
(add-to-list 'load-path (concat org_install_path "/current/lisp")) ;; the variable must be defined
(setq org-root "~/org") ;; orgmode root dir
(add-to-list 'auto-mode-alist '("\\.\\(org\\  |org_archive\\|txt\\)$" . org-mode))
(require 'org-install)
(require 'org-habit)

(global-set-key "\C-cl" 'org-store-link) ;; useful for referring to sections within a file
(transient-mark-mode 1) ;; highlighting selected text

;; org-mode experimental stuffs
(setenv "TMPDIR" ".") ;; a work-around for bibtex2html
(add-to-list 'load-path (concat org_install_path "/current/contrib/lisp"))

;; Bibliography: org-bibnote-exp
(require 'org-bibnote-exp)

;; org babel: display source code for different languages
(org-babel-do-load-languages
 (quote org-babel-load-languages)
 (quote ((emacs-lisp . t)
	 (dot . t)
	 (ditaa . t)
	 (R . t)
	 (python . t)
	 (sh . t)
	 (org . t)
	 (latex . t))))

					; Do not prompt to confirm evaluation
					; This may be dangerous - make sure you understand the consequences
					; of setting this -- see the docstring for details
(setq org-confirm-babel-evaluate nil)    

;; ========================================================================================
;; orgmode customization done 
;; ========================================================================================
