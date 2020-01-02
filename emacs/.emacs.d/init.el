;;; init.el --- Emacs init file
;;; Author: Guido Masella <guido.masella@gmail.com>
;;; Code:
(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(setq package-enable-at-startup nil)
(package-initialize)

;; Setting up the package manager. Install if missing.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t))

;; Load main config file "./config.org"
(require 'org)
(org-babel-load-file (expand-file-name "~/.emacs.d/config.org"))

(provide 'init)
;;; init.el ends here
