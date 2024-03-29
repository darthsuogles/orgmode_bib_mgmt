;;; org-bibnote-exp.el --- major mode for bibtex note management 

;; Copyright (C) 2012 - 2014 Free Software Foundation, Inc.
;;
;; Author: Philip Yang
;; Email: phi@cs.umd.edu
;; Keywords: languages
;; Version: 0.1

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Major mode for managing bibtex library and reading note
;; This work is based on the work by many others 
;; The author is in-debt to their contributions.
;; 1. Olivier Berger (rtcite) http://bit.ly/WW9dYv
;; 2. Nick Dokos http://bit.ly/Tp53VO
;; 3. tincman (RefTeX) http://bit.ly/eAIhY6

;;; Research paper management workflow
;; Assume you are working on a project call "proj".
;; 1. Maintain the following files
;;    - proj_notes.org (organizing papers)
;;    - proj.bib (contains bibtex entries of your references)
;; 
;; 2. For each paper in proj.bib, add a note entry in proj_notes.org.
;;    Find the bib_key of the paper, press C-c C-x p to insert a
;;    CUSTOM_ID entry with the bib_key
;;
;; 3. When referring to the paper, type C-c C-g and a menu will prompt
;;    you for a choice of citing format, choose "note". Then find the 
;;    paper entry in the bibtex library by the authors (using RefTeX)
;; 
;; When editing the file in org-mode, the citations will link to the notes
;; you have for that paper. When exported to html or pdf, those citations
;; will be converted to citation links.

;;; Installation:

;; This file requires Emacs-23 or higher and package org-mode 7.9.1 (or higher)
;; To work with bibtex html export, do the followings. 
;; 1. Download the latest org-mode
;; 2. Add these lines to your .emacs
;;     (setenv "TMPDIR" ".")
;;     (add-to-list 'load-path "path/to/org-mode/install/dir/contrib/lisp")
;;     (require 'org-exp-bibtex)
;; 3. Add the this line in the back of your proj_notes.org
;;     #+BIBLIOGRAPHY: proj.bib IEEEtran option:-d limit:t
;; 4. Add these lines to the begining of any write-ups referring to the papers
;;     #+LINK: note rtcite:path/to/proj_notes.org::#%s
;;     #+LINK: bib rtcite:path/to/proj.bib::%s
;; 4. C-c C-g to search the bib-entry

;;; Known bugs:
;; 1. If citations cross two lines, it will not be processed successfully.

;;; Code:

;; rcite addition taken from http://bit.ly/WW9dYv
(defun my-rtcite-export-handler (path desc format)
  ;;(message "my-rtcite-export-handler is called : path = %s, desc = %s, format = %s"
  ;;   path desc format)
  (let* ((search (when (string-match "::#?\\(.+\\)\\'" path)
		   (match-string 1 path)))
	 (path (substring path 0 (match-beginning 0))))
    ;;(message "path prefix = %s" path) 
    (cond ((eq format 'latex)
	   (if (or (not desc) 
		   (equal 0 (search "rtcite:" desc)))
	       (format "\\cite{%s}" search)
	     (format "\\cite[%s]{%s}" desc search)))
	  ((eq format 'html)
	   (format "\\cite{%s}" search))
	  )))

(require 'org)
(require 'reftex)
(add-hook 'org-mode-hook 'turn-on-reftex)     ; with orgmode 

;; Adding hyperlink types
;; http://orgmode.org/manual/Adding-hyperlink-types.html
(org-add-link-type "rtcite" 
		   'org-bibtex-open
		   'my-rtcite-export-handler)

;; Setup RefTeX  http://bit.ly/eAIhY6
(defun org-mode-reftex-setup ()
  (load-library "reftex")
  (and (buffer-file-name) (file-exists-p (buffer-file-name))
       (progn
	 ;enable auto-revert-mode to update reftex when bibtex file changes on disk
	 (global-auto-revert-mode t)
	 (reftex-parse-all)
	 ;add a custom reftex cite format to insert links
	 (reftex-set-cite-format
	  '((?b . "[[bib:%l][%l-bib]]")
	    (?n . "[[note:%l][%l-notes]]")
	    (?p . "[[paper:%l][%l-paper]]")
	    (?t . "%t")
	    (?h . "** %t\n:PROPERTIES:\n:Custom_ID: %l\n:END:\n[[papers:%l][%l-paper]]")))))
  (define-key org-mode-map (kbd "C-c C-g") 'reftex-citation)
  (define-key org-mode-map (kbd "C-c C-p") 'org-mode-reftex-search))

(add-hook 'org-mode-hook 'org-mode-reftex-setup)

(defun org-mode-reftex-search ()
  ;;jump to the notes for the paper pointed to at from reftex search
  (interactive)
  (org-open-link-from-string (format "[[note:%s]]" (reftex-citation t))))


;; Process the special links before hand
;; TODO: process the "desc" part into more meaningful citation format
(defun my-rtcite-export-preprocess()
  "Export all BibTeX."
  ;;(message "org-rtcite-export-preprocess > exporting all to bibtex")     
  (interactive)
  (save-window-excursion
    (setq oebp-cite-plist '())
    (goto-char (point-min)) ;; goto head of file
    (while (re-search-forward 
	    "\\[\\[\\(note\\|bib\\):\\(\\S-+\\)]\\[\\(.*?\\)\\]\\]"
	    nil t)
      
      (let ((desc (match-string 3))
	    (bibent  (match-string 2)))
	;;(message "%s\\cite{%s}" desc bibent) 
	(replace-match (format "%s \\\\cite{%s}" desc bibent) nil nil) 
	)
      )
    )
  )

(add-hook 'org-export-preprocess-hook 'my-rtcite-export-preprocess)

(setq org-latex-pdf-process
      '("pdflatex -interaction nonstopmode -output-directory %o %f"
        "biber %b"
        "pdflatex -interaction nonstopmode -output-directory %o %f"
        "pdflatex -interaction nonstopmode -output-directory %o %f"))

(provide 'org-bibnote-exp)
