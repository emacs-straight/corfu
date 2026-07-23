;;; corfu-mouse.el --- Mouse support -*- lexical-binding: t -*-

;; Copyright (C) 2026 Free Software Foundation, Inc.

;; Author: Daniel Mendler <mail@daniel-mendler.de>
;; Maintainer: Daniel Mendler <mail@daniel-mendler.de>
;; Created: 2026
;; Version: 2.11
;; Package-Requires: ((emacs "29.1") (compat "31") (corfu "2.11"))
;; URL: https://github.com/minad/corfu

;; This file is part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package is a Corfu extension, which adds mouse support if
;; enabled via `corfu-mouse-mode'.

;;; Code:

(require 'corfu)
(eval-when-compile
  (require 'cl-lib))

(defface corfu-mouse
  '((t :inherit highlight))
  "Face used for mouse highlighting."
  :group 'corfu-faces)

(defvar-keymap corfu-mouse-map
  :doc "Additional keymap activated by `corfu-mouse-mode'."
  :parent corfu--mouse-ignore-map
  "<mouse-1>" #'corfu-mouse-complete
  "<mouse-2>" #'corfu-mouse-complete
  "<wheel-up>" #'corfu-previous
  "<wheel-down>" #'corfu-next)

;;;###autoload
(define-minor-mode corfu-mouse-mode
  "Mouse support, scrolling and clickable candidates."
  :global t :group 'corfu)

(defun corfu-mouse-complete ()
  "Call `corfu-complete' with candidate at mouse position."
  (declare (completion ignore))
  (interactive)
  (when-let* ((row (cdr (posn-col-row (event-end last-input-event))))
              ((fixnump row))
              (index (+ corfu--scroll row))
              ((and (>= index 0) (< index corfu--total))))
    (corfu--goto index)
    (corfu-complete)))

(cl-defmethod corfu--popup-show :around (pos off width lines
                                             &context (corfu-mouse-mode (eql t))
                                             &rest args)
  (apply #'cl-call-next-method pos off width
         (cl-loop
          for line in lines
          for padded = (concat line #(" " 0 1 (display (space :align-to right))))
          do (put-text-property 0 (length padded) 'mouse-face 'corfu-mouse padded)
          collect padded)
         args)
  (with-current-buffer (get-buffer " *corfu*")
    (use-local-map corfu-mouse-map)))

(provide 'corfu-mouse)
;;; corfu-mouse.el ends here
