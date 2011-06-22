;;; monky.el -- control Hg from Emacs.

;; Copyright (C) 2011 Anantha Kumaran.

;; Author: Anantha kumaran <ananthakumaran@gmail.com>
;; Keywords: tools

;; Monky is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Monky is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(defgroup monky nil
  "Controlling Hg from Emacs."
  :prefix "monky-"
  :group 'tools)

(defcustom monky-hg-executable "hg"
  "The name of the Hg executable."
  :group 'monky
  :type 'string)

(defcustom monky-hg-standard-options '("--pager=no")
  "Standard options when running Hg."
  :group 'monky
  :type '(repeat string))

;; TODO
(defcustom monky-save-some-buffers t
  "Non-nil means that \\[monky-status] will save modified buffers before running.
Setting this to t will ask which buffers to save, setting it to 'dontask will
save all modified buffers without asking."
  :group 'monky
  :type '(choice (const :tag "Never" nil)
		 (const :tag "Ask" t)
		 (const :tag "Save without asking" dontask)))

;; TODO
(defcustom monky-revert-item-confirm t
  "Require acknowledgment before reverting an item."
  :group 'monky
  :type 'boolean)

(defcustom monky-process-popup-time -1
  "Popup the process buffer if a command takes longer than this many seconds."
  :group 'monky
  :type '(choice (const :tag "Never" -1)
		 (const :tag "Immediately" 0)
		 (integer :tag "After this many seconds")))


(defgroup monky-faces nil
  "Customize the appearance of Monky"
  :prefix "monky-"
  :group 'faces
  :group 'monky)

(defface monky-header
  '((t))
  "Face for generic header lines.

Many Monky faces inherit from this one by default."
  :group 'monky-faces)

(defface monky-section-title
  '((t :weight bold :inherit monky-header))
  "Face for section titles."
  :group 'monky-faces)

(defface monky-branch
  '((t :weight bold :inherit monky-header))
  "Face for the current branch."
  :group 'monky-faces)

(defface monky-diff-file-header
  '((t :inherit monky-header))
  "Face for diff file header lines."
  :group 'monky-faces)

(defface monky-diff-hunk-header
  '((t :slant italic :inherit monky-header))
  "Face for diff hunk header lines."
  :group 'monky-faces)

(defface monky-diff-add
  '((((class color) (background light))
     :foreground "blue1")
    (((class color) (background dark))
     :foreground "white"))
  "Face for lines in a diff that have been added."
  :group 'monky-faces)

(defface monky-diff-none
  '((t))
  "Face for lines in a diff that are unchanged."
  :group 'monky-faces)

(defface monky-diff-del
  '((((class color) (background light))
     :foreground "red")
    (((class color) (background dark))
     :foreground "OrangeRed"))
  "Face for lines in a diff that have been deleted."
  :group 'monky-faces)

(defface monky-log-graph
  '((((class color) (background light))
     :foreground "grey11")
    (((class color) (background dark))
     :foreground "grey80"))
  "Face for the graph element of the log output."
  :group 'monky-faces)

(defface monky-log-sha1
  '((((class color) (background light))
     :foreground "firebrick")
    (((class color) (background dark))
     :foreground "tomato"))
  "Face for the sha1 element of the log output."
  :group 'monky-faces)

(defface monky-log-message
  '((t))
  "Face for the message element of the log output."
  :group 'monky-faces)

(defface monky-item-highlight
  '((((class color) (background light))
     :background "gray95")
    (((class color) (background dark))
     :background "dim gray"))
  "Face for highlighting the current item."
  :group 'monky-faces)

(defface monky-item-mark
  '((((class color) (background light))
     :foreground "red")
    (((class color) (background dark))
     :foreground "orange"))
  "Face for highlighting marked item."
  :group 'monky-faces)

(defface monky-log-tag-label
  '((((class color) (background light))
     :background "LightGoldenRod")
    (((class color) (background dark))
     :background "DarkGoldenRod"))
  "Face for hg tag labels shown in log buffer."
  :group 'monky-faces)

(defface monky-log-head-label-bisect-good
  '((((class color) (background light))
     :box t
     :background "light green"
     :foreground "dark olive green")
    (((class color) (background dark))
     :box t
     :background "light green"
     :foreground "dark olive green"))
  "Face for good bisect refs"
  :group 'monky-faces)

(defface monky-log-head-label-bisect-bad
  '((((class color) (background light))
     :box t
     :background "IndianRed1"
     :foreground "IndianRed4")
    (((class color) (background dark))
     :box t
     :background "IndianRed1"
     :foreground "IndianRed4"))
  "Face for bad bisect refs"
  :group 'monky-faces)

(defface monky-log-head-label-remote
  '((((class color) (background light))
     :box t
     :background "Grey85"
     :foreground "OliveDrab4")
    (((class color) (background dark))
     :box t
     :background "Grey11"
     :foreground "DarkSeaGreen2"))
  "Face for remote branch head labels shown in log buffer."
  :group 'monky-faces)

(defface monky-log-head-label-tags
  '((((class color) (background light))
     :box t
     :background "LemonChiffon1"
     :foreground "goldenrod4")
    (((class color) (background dark))
     :box t
     :background "LemonChiffon1"
     :foreground "goldenrod4"))
  "Face for tag labels shown in log buffer."
  :group 'monky-faces)

(defface monky-log-head-label-patches
  '((((class color) (background light))
     :box t
     :background "IndianRed1"
     :foreground "IndianRed4")
    (((class color) (background dark))
     :box t
     :background "IndianRed1"
     :foreground "IndianRed4"))
  "Face for Stacked Hg patches"
  :group 'monky-faces)


(defface monky-log-head-label-local
  '((((class color) (background light))
     :box t
     :background "Grey85"
     :foreground "LightSkyBlue4")
    (((class color) (background dark))
     :box t
     :background "Grey13"
     :foreground "LightSkyBlue1"))
  "Face for local branch head labels shown in log buffer."
  :group 'monky-faces)

(defface monky-log-head-label-default
  '((((class color) (background light))
     :box t
     :background "Grey50")
    (((class color) (background dark))
     :box t
     :background "Grey50"))
  "Face for unknown ref labels shown in log buffer."
  :group 'monky-faces)

(defface monky-menu-selected-option
  '((((class color) (background light))
     :foreground "red")
    (((class color) (background dark))
     :foreground "orange"))
  "Face for selected options on monky's menu"
  :group 'monky-faces)

;;; Compatibilities

(defalias 'monky-start-process
  (if (functionp 'start-file-process)
      'start-file-process
    'start-process))

(eval-when-compile
  (when (< emacs-major-version 23)
    (defvar line-move-visual nil)))

;;; Utilities

(defvar monky-bug-report-url "http://github.com/ananthakumaran/monky/issues")
(defun monky-bug-report (str)
  (message "Unknown error: %s\nPlease file a bug at %s"
	   str monky-bug-report-url))

(defun monky-string-starts-with-p (string prefix)
  (eq (compare-strings string nil (length prefix) prefix nil nil) t))

(defun monky-trim-line (str)
  (if (string= str "")
      nil
    (if (equal (elt str (- (length str) 1)) ?\n)
	(substring str 0 (- (length str) 1))
      str)))

(defun monky-put-line-property (prop val)
  (put-text-property (line-beginning-position) (line-beginning-position 2)
		     prop val))

(defun monky-concat-with-delim (delim seqs)
  (cond ((null seqs)
	 nil)
	((null (cdr seqs))
	 (car seqs))
	(t
	 (concat (car seqs) delim (monky-concat-with-delim delim (cdr seqs))))))

(defun monky-prefix-p (prefix list)
  "Returns non-nil if PREFIX is a prefix of LIST.  PREFIX and LIST should both be
lists.

If the car of PREFIX is the symbol '*, then return non-nil if the cdr of PREFIX
is a sublist of LIST (as if '* matched zero or more arbitrary elements of LIST)"
  (or (null prefix)
      (if (eq (car prefix) '*)
	  (or (monky-prefix-p (cdr prefix) list)
	      (and (not (null list))
		   (monky-prefix-p prefix (cdr list))))
	(and (not (null list))
	     (equal (car prefix) (car list))
	     (monky-prefix-p (cdr prefix) (cdr list))))))

(defun monky-wash-sequence (func)
  "Run FUNC until end of buffer is reached

FUNC should leave point at the end of the modified region"
  (while (and (not (eobp))
	      (funcall func))))

(defun monky-goto-line (line)
  "Like `goto-line' but doesn't set the mark."
  (save-restriction
    (widen)
    (goto-char 1)
    (forward-line (1- line))))

;;; Key bindings

(setq monky-mode-map
      (let ((map (make-keymap)))
	(suppress-keymap map t)
	(define-key map (kbd "RET") 'monky-visit-item)
	(define-key map (kbd "TAB") 'monky-toggle-section)
	(define-key map (kbd "g") 'monky-refresh)
	(define-key map (kbd "$") 'monky-display-process)
	(define-key map (kbd ":") 'monky-hg-command)
	map))

(setq monky-status-mode-map
      (let ((map (make-keymap)))
	(define-key map (kbd "s") 'monky-stage-item)
	(define-key map (kbd "S") 'monky-stage-all)
	(define-key map (kbd "u") 'monky-unstage-item)
	(define-key map (kbd "U") 'monky-unstage-all)
	(define-key map (kbd "c") 'monky-log-edit)
	(define-key map (kbd "p") 'monky-push)
	(define-key map (kbd "f") 'monky-fetch)
	map))

;;; Sections

(defvar monky-top-section nil
  "The top section of the current buffer.")
(make-variable-buffer-local 'monky-top-section)
(put 'monky-top-section 'permanent-local t)

(defvar monky-old-top-section nil)
(defvar monky-section-hidden-default nil)

;; A buffer in monky-mode is organized into hierarchical sections.
;; These sections are used for navigation and for hiding parts of the
;; buffer.
;;
;; Most sections also represent the objects that Monky works with,
;; such as files, diffs, hunks, commits, etc.  The 'type' of a section
;; identifies what kind of object it represents (if any), and the
;; parent and grand-parent, etc provide the context.

(defstruct monky-section
  parent children beginning end type title hidden info
  needs-refresh-on-show)

(defun monky-set-section-info (info &optional section)
  (setf (monky-section-info (or section monky-top-section)) info))


(defun monky-new-section (title type)
  "Create a new section with title TITLE and type TYPE in current buffer.

If not `monky-top-section' exist, the new section will be the new top-section
otherwise, the new-section will be a child of the current top-section.

If TYPE is nil, the section won't be highlighted."
  (let* ((s (make-monky-section :parent monky-top-section
				:title title
				:type type
				:hidden monky-section-hidden-default))
	 (old (and monky-old-top-section
		   (monky-find-section (monky-section-path s)
				       monky-old-top-section))))
    (if monky-top-section
	(push s (monky-section-children monky-top-section))
      (setq monky-top-section s))
    (if old
	(setf (monky-section-hidden s) (monky-section-hidden old)))
    s))

(defmacro monky-with-section (title type &rest body)
  "Create a new section of title TITLE and type TYPE and evaluate BODY there.

Sections create into BODY will be child of the new section.
BODY must leave point at the end of the created section.

If TYPE is nil, the section won't be highlighted."
  (declare (indent 2))
  "doc."
  (let ((s (make-symbol "*section*")))
    `(let* ((,s (monky-new-section ,title ,type))
	    (monky-top-section ,s))
       (setf (monky-section-beginning ,s) (point))
       ,@body
       (setf (monky-section-end ,s) (point))
       (setf (monky-section-children ,s)
	     (nreverse (monky-section-children ,s)))
       ,s)))

(defmacro monky-create-buffer-sections (&rest body)
  "Empty current buffer of text and monky's section, and then evaluate BODY."
  (declare (indent 0))
  `(let ((inhibit-read-only t))
     (erase-buffer)
     (let ((monky-old-top-section monky-top-section))
       (setq monky-top-section nil)
       ,@body
       (when (null monky-top-section)
	 (monky-with-section 'top nil
	   (insert "(empty)\n")))
       (monky-propertize-section monky-top-section)
       (monky-section-set-hidden monky-top-section
				 (monky-section-hidden monky-top-section)))))

(defun monky-propertize-section (section)
  "Add text-property needed for SECTION."
  (put-text-property (monky-section-beginning section)
		     (monky-section-end section)
		     'monky-section section)
  (dolist (s (monky-section-children section))
    (monky-propertize-section s)))

(defun monky-find-section (path top)
  "Find the section at the path PATH in subsection of section TOP."
  (if (null path)
      top
    (let ((secs (monky-section-children top)))
      (while (and secs (not (equal (car path)
				   (monky-section-title (car secs)))))
	(setq secs (cdr secs)))
      (and (car secs)
	   (monky-find-section (cdr path) (car secs))))))

(defun monky-section-path (section)
  "Return the path of SECTION."
  (if (not (monky-section-parent section))
      '()
    (append (monky-section-path (monky-section-parent section))
	    (list (monky-section-title section)))))

(defun monky-insert-section (section-title-and-type buffer-title washer cmd &rest args)
  "Run CMD and put its result in a new section.

SECTION-TITLE-AND-TYPE is either a string that is the title of the section
or (TITLE . TYPE) where TITLE is the title of the section and TYPE is its type.

If there is no type, or if type is nil, the section won't be highlighted.

BUFFER-TITLE is the inserted title of the section

WASHER is a function that will be run after CMD.
The buffer will be narrowed to the inserted text.
It should add sectioning as needed for monky interaction

CMD is an external command that will be run with ARGS as arguments"
  (let* ((body-beg nil)
	 (section-title (if (consp section-title-and-type)
			    (car section-title-and-type)
			  section-title-and-type))
	 (section-type (if (consp section-title-and-type)
			   (cdr section-title-and-type)
			 nil))
	 (section (monky-with-section section-title section-type
		    (if buffer-title
			(insert (propertize buffer-title 'face 'monky-section-title) "\n"))
		    (setq body-beg (point))
		    (apply 'process-file cmd nil t nil args)
		    (if (not (eq (char-before) ?\n))
			(insert "\n"))
		    (if washer
			(save-restriction
			  (narrow-to-region body-beg (point))
			  (goto-char (point-min))
			  (funcall washer)
			  (goto-char (point-max)))))))
    (if (= body-beg (point))
	(monky-cancel-section section)
      (insert "\n"))
    section))

(defun monky-cancel-section (section)
  (delete-region (monky-section-beginning section)
		 (monky-section-end section))
  (let ((parent (monky-section-parent section)))
    (if parent
	(setf (monky-section-children parent)
	      (delq section (monky-section-children parent)))
      (setq monky-top-section nil))))

(defun monky-current-section ()
  "Return the monky section at point."
  (or (get-text-property (point) 'monky-section)
      monky-top-section))

(defun monky-section-context-type (section)
  (if (null section)
      '()
    (let ((c (or (monky-section-type section)
		 (if (symbolp (monky-section-title section))
		     (monky-section-title section)))))
      (if c
	  (cons c (monky-section-context-type
		   (monky-section-parent section)))
	'()))))

(defun monky-hg-section (section-title-and-type buffer-title washer &rest args)
  (apply #'monky-insert-section
	 section-title-and-type
	 buffer-title
	 washer
	 monky-hg-executable
	 (append monky-hg-standard-options args)))

(defun monky-set-section-needs-refresh-on-show (flag &optional section)
  (setf (monky-section-needs-refresh-on-show
	 (or section monky-top-section))
	flag))

(defun monky-section-set-hidden (section hidden)
  "Hide SECTION if HIDDEN is not nil, show it otherwise."
  (setf (monky-section-hidden section) hidden)
  (if (and (not hidden)
	   (monky-section-needs-refresh-on-show section))
      (monky-refresh)
    (let ((inhibit-read-only t)
	  (beg (save-excursion
		 (goto-char (monky-section-beginning section))
		 (forward-line)
		 (point)))
	  (end (monky-section-end section)))
      (if (< beg end)
          (put-text-property beg end 'invisible hidden)))
    (if (not hidden)
	(dolist (c (monky-section-children section))
	  (monky-section-set-hidden c (monky-section-hidden c))))))

(defun monky-section-hideshow (flag-or-func)
  "Show or hide current section depending on FLAG-OR-FUNC.

If FLAG-OR-FUNC is a function, it will be ran on current section
IF FLAG-OR-FUNC is a Boolean value, the section will be hidden if its true, shown otherwise"
  (let ((section (monky-current-section)))
    (when (monky-section-parent section)
      (goto-char (monky-section-beginning section))
      (if (functionp flag-or-func)
	  (funcall flag-or-func section)
	(monky-section-set-hidden section flag-or-func)))))

(defun monky-toggle-section ()
  "Toggle hidden status of current section."
  (interactive)
  (monky-section-hideshow
   (lambda (s)
     (monky-section-set-hidden s (not (monky-section-hidden s))))))

;;; Running commands

(defun monky-set-mode-line-process (str)
  (let ((pr (if str (concat " " str) "")))
    (save-excursion
      (monky-for-all-buffers (lambda ()
			       (setq mode-line-process pr))))))

;; TODO check
(defun monky-process-indicator-from-command (comps)
  (if (monky-prefix-p (cons monky-hg-executable monky-hg-standard-options)
		      comps)
      (setq comps (nthcdr (+ (length monky-hg-standard-options) 1) comps)))
  (cond ((or (null (cdr comps))
	     (not (member (car comps) '("remote"))))
	 (car comps))
	(t
	 (concat (car comps) " " (cadr comps)))))

(defvar monky-process nil)
(defvar monky-process-client-buffer nil)
(defvar monky-process-buffer-name "*monky-process*")

(defun monky-run* (cmd-and-args
		   &optional logline noerase noerror nowait input)
  (if (and monky-process
	   (get-buffer monky-process-buffer-name))
      (error "Hg is already running"))
  (let ((cmd (car cmd-and-args))
	(args (cdr cmd-and-args))
	(dir default-directory)
	(buf (get-buffer-create monky-process-buffer-name))
	(successp nil))
    (monky-set-mode-line-process
     (monky-process-indicator-from-command cmd-and-args))
    (setq monky-process-client-buffer (current-buffer))
    (with-current-buffer buf
      (view-mode 1)
      (set (make-local-variable 'view-no-disable-on-exit) t)
      (setq view-exit-action
	    (lambda (buffer)
	      (with-current-buffer buffer
		(bury-buffer))))
      (setq buffer-read-only t)
      (let ((inhibit-read-only t))
	(setq default-directory dir)
	(if noerase
	    (goto-char (point-max))
	  (erase-buffer))
	(insert "$ " (or logline
			 (monky-concat-with-delim " " cmd-and-args))
		"\n")
	(cond (nowait
	       (setq monky-process
		     (let ((process-connection-type nil))
		       (apply 'monky-start-process cmd buf cmd args)))
	       (set-process-sentinel monky-process 'monky-process-sentinel)
	       (set-process-filter monky-process 'monky-process-filter)
	       (when input
		 (with-current-buffer input
		   (process-send-region monky-process
					(point-min) (point-max))
		   (process-send-eof monky-process)
		   (sit-for 0.1 t)))
	       (cond ((= monky-process-popup-time 0)
		      (pop-to-buffer (process-buffer monky-process)))
		     ((> monky-process-popup-time 0)
		      (run-with-timer
		       monky-process-popup-time nil
		       (function
			(lambda (buf)
			  (with-current-buffer buf
			    (when monky-process
			      (display-buffer (process-buffer monky-process))
			      (goto-char (point-max))))))
		       (current-buffer))))
	       (setq successp t))
	      (input
	       (with-current-buffer input
		 (setq default-directory dir)
		 (setq monky-process
		       ;; Don't use a pty, because it would set icrnl
		       ;; which would modify the input (issue #20).
		       (let ((process-connection-type nil))
			 (apply 'monky-start-process cmd buf cmd args)))
		 (set-process-filter monky-process 'monky-process-filter)
		 (process-send-region monky-process
				      (point-min) (point-max))
		 (process-send-eof monky-process)
		 (while (equal (process-status monky-process) 'run)
		   (sit-for 0.1 t))
		 (setq successp
		       (equal (process-exit-status monky-process) 0))
		 (setq monky-process nil))
	       (monky-set-mode-line-process nil)
	       (monky-need-refresh monky-process-client-buffer)
	       )
	      (t
	       (setq successp
		     (equal (apply 'process-file cmd nil buf nil args) 0))
	       (monky-set-mode-line-process nil)
	       (monky-need-refresh monky-process-client-buffer))))
      (or successp
	  noerror
	  (error
	   (or (with-current-buffer (get-buffer monky-process-buffer-name)
		 (when (re-search-forward
			(concat "^abort: \\(.*\\)" paragraph-separate) nil t)
		   (match-string 1)))
	       "Hg failed")))
      successp)))

(defun monky-process-sentinel (process event)
  (let ((msg (format "Hg %s." (substring event 0 -1)))
	(successp (string-match "^finished" event)))
    (with-current-buffer (process-buffer process)
      (let ((inhibit-read-only t))
	(goto-char (point-max))
	(insert msg "\n")
	(message msg)))
    (setq monky-process nil)
    (monky-set-mode-line-process nil)
    (monky-with-refresh
      (monky-need-refresh monky-process-client-buffer))))

;; TODO password?

(defun monky-process-filter (proc string)
  (save-current-buffer
    (set-buffer (process-buffer proc))
    (let ((inhibit-read-only t))
      (goto-char (process-mark proc))
      (insert string)
      (set-marker (process-mark proc) (point)))))


(defun monky-run-hg (&rest args)
  (monky-with-refresh
    (monky-run* (append (cons monky-hg-executable
			      monky-hg-standard-options)
			args))))

(defun monky-run-hg-async (&rest args)
  (message "Running %s %s" monky-hg-executable (mapconcat 'identity args " "))
  (monky-run* (append (cons monky-hg-executable
			    monky-hg-standard-options)
		      args)
	      nil nil nil t))

(defun monky-run-async-with-input (input cmd &rest args)
  (monky-run* (cons cmd args) nil nil nil t input))

(defun monky-display-process ()
  "Display output from most recent git command."
  (interactive)
  (unless (get-buffer monky-process-buffer-name)
    (error "No Hg commands have run"))
  (display-buffer monky-process-buffer-name))

(defun monky-hg-command (command)
  "Perform arbitrary Hg COMMAND."
  (interactive "sRun hg like this: ")
  (require 'pcomplete)
  (let ((args (car (with-temp-buffer
		     (insert command)
		     (pcomplete-parse-buffer-arguments))))
	(monky-process-popup-time 0))
    (monky-with-refresh
      (monky-run* (append (cons monky-hg-executable
				monky-hg-standard-options)
			  args)
		  nil nil nil t))))

;;; Actions

(defmacro monky-section-action (head &rest clauses)
  (declare (indent 1))
  `(monky-with-refresh
     (monky-section-case ,head ,@clauses)))

(defmacro monky-section-case (head &rest clauses)
  "Make different action depending of current section.

HEAD is (SECTION INFO &optional OPNAME),
  SECTION will be bind to the current section,
  INFO will be bind to the info's of the current section,
  OPNAME is a string that will be used to describe current action,

CLAUSES is a list of CLAUSE, each clause is (SECTION-TYPE &BODY)
where SECTION-TYPE describe section where BODY will be run.

This returns non-nil if some section matches. If the
corresponding body return a non-nil value, it is returned,
otherwise it return t.

If no section matches, this returns nil if no OPNAME was given
and throws an error otherwise."

  (declare (indent 1))
  (let ((section (car head))
	(info (cadr head))
	(type (make-symbol "*type*"))
	(context (make-symbol "*context*"))
	(opname (caddr head)))
    `(let* ((,section (monky-current-section))
	    (,info (monky-section-info ,section))
	    (,type (monky-section-type ,section))
	    (,context (monky-section-context-type ,section)))
       (cond ,@(mapcar (lambda (clause)
			 (let ((prefix (car clause))
			       (body (cdr clause)))
			   `(,(if (eq prefix t)
				  `t
				`(monky-prefix-p ',(reverse prefix) ,context))
			     (or (progn ,@body)
				 t))))
		       clauses)
	     ,@(when opname
		 `(((not ,type)
		    (error "Nothing to %s here" ,opname))
		   (t
		    (error "Can't %s as %s"
			   ,opname
			   ,type))))))))

(defun monky-visit-item (&optional other-window)
  "Visit current item.
With a prefix argument, visit in other window."
  (interactive (list current-prefix-arg))
  (monky-section-action (item info "visit")
    ((file)
     (funcall (if other-window 'find-file-other-window 'find-file)
	      info))
    ((diff)
     (find-file (monky-diff-item-file item)))
    ((hunk)
     (let ((file (monky-diff-item-file (monky-hunk-item-diff item)))
	   (line (monky-hunk-item-target-line item)))
       (find-file file)
       (goto-char (point-min))
       (forward-line (1- line))))))

(defun monky-stage-all ()
  "Add all items in changes to the staging area"
  (interactive)
  (monky-with-refresh
    (setq monky-staged-all-files t)
    (monky-refresh-buffer)))

(defun monky-stage-item ()
  "Add the item at point to the staging area."
  (interactive)
  (monky-section-action (item info "stage")
    ((untracked file)
     (monky-run-hg "add" info))
    ((untracked)
     (monky-run-hg "add"))
    ((missing file)
     (monky-run-hg "remove" info))
    ((changes diff)
     (monky-stage-file (monky-section-title item))
     (monky-refresh-buffer))
    ((changes)
     (monky-stage-all))
    ((staged diff)
     (error "Already staged"))))

(defun monky-unstage-all ()
  "Remove all items from the staging area"
  (interactive)
  (monky-with-refresh
    (setq monky-staged-files '())
    (monky-refresh-buffer)))

(defun monky-unstage-item ()
  "Remove the item at point from the staging area."
  (interactive)
  (monky-section-action (item info "unstage")
    ((staged diff)
     (monky-unstage-file (monky-section-title item))
     (monky-refresh-buffer))
    ((staged)
     (monky-unstage-all))
    ((changes diff)
     (error "Already unstaged"))))

;;; Updating

(defun monky-fetch ()
  (interactive)
  (monky-run-hg-async "fetch"))

(defun monky-push ()
  (interactive)
  (monky-run-hg-async "push"))


;;; Refresh

(defun monky-revert-buffers (dir &optional ignore-modtime)
  (dolist (buffer (buffer-list))
    (when (and buffer
	       (buffer-file-name buffer)
	       (file-readable-p (buffer-file-name buffer))
	       (monky-string-starts-with-p (buffer-file-name buffer) dir)
	       (or ignore-modtime (not (verify-visited-file-modtime buffer)))
	       (not (buffer-modified-p buffer)))
      (with-current-buffer buffer
	(condition-case var
	    (revert-buffer t t nil)
	  (error (let ((signal-data (cadr var)))
		   (cond (t (monky-bug-report signal-data))))))))))

(defvar monky-refresh-needing-buffers nil)
(defvar monky-refresh-pending nil)

(defmacro monky-with-refresh (&rest body)
  (declare (indent 0))
  `(monky-refresh-wrapper (lambda () ,@body)))

(defun monky-refresh-wrapper (func)
  (if monky-refresh-pending
      (funcall func)
    (let* ((dir default-directory)
	   (status-buffer (monky-find-status-buffer dir))
	   (monky-refresh-needing-buffers nil)
	   (monky-refresh-pending t))
      (unwind-protect
	  (funcall func)
	(when monky-refresh-needing-buffers
	  (monky-revert-buffers dir)
	  (dolist (b (adjoin status-buffer
			     monky-refresh-needing-buffers))
	    (monky-refresh-buffer b)))))))

(defun monky-need-refresh (&optional buffer)
  (let ((buffer (or buffer (current-buffer))))
    (setq monky-refresh-needing-buffers
	  (adjoin buffer monky-refresh-needing-buffers))))

(defun monky-refresh ()
  "Refresh current buffer to match repository state.
Also revert every unmodified buffer visiting files
in the corresponding directory."
  (interactive)
  (monky-with-refresh
    (monky-need-refresh)))

(defun monky-refresh-buffer (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (let* ((old-line (line-number-at-pos))
	   (old-section (monky-current-section))
	   (old-path (and old-section
			  (monky-section-path old-section)))
	   (section-line (and old-section
			      (count-lines
			       (monky-section-beginning old-section)
			       (point)))))
      (if monky-refresh-function
	  (apply monky-refresh-function
		 monky-refresh-args))
      (let ((s (and old-path (monky-find-section old-path monky-top-section))))
	(cond (s
	       (goto-char (monky-section-beginning s))
	       (forward-line section-line))
	      (t
	       (monky-goto-line old-line)))
	(dolist (w (get-buffer-window-list (current-buffer)))
	  (set-window-point w (point)))))))

(defvar last-point)

(defun monky-remember-point ()
  (setq last-point (point)))

(defun monky-invisible-region-end (pos)
  (while (and (not (= pos (point-max))) (invisible-p pos))
    (setq pos (next-char-property-change pos)))
  pos)

(defun monky-invisible-region-start (pos)
  (while (and (not (= pos (point-min))) (invisible-p pos))
    (setq pos (1- (previous-char-property-change pos))))
  pos)

(defun monky-correct-point-after-command ()
  "Move point outside of invisible regions.

Emacs often leaves point in invisible regions, it seems.  To fix
this, we move point ourselves and never let Emacs do its own
adjustments.

When point has to be moved out of an invisible region, it can be
moved to its end or its beginning.  We usually move it to its
end, except when that would move point back to where it was
before the last command."
  (if (invisible-p (point))
      (let ((end (monky-invisible-region-end (point))))
	(goto-char (if (= end last-point)
		       (monky-invisible-region-start (point))
		     end))))
  (setq disable-point-adjustment t))

(defun monky-post-command-hook ()
  (monky-correct-point-after-command))

;;; Monky mode

(defun monky-mode ()
  (kill-all-local-variables)
  (buffer-disable-undo)
  (setq buffer-read-only t)
  (make-local-variable 'line-move-visual)
  (setq major-mode 'monky-mode
	mode-name "Monky"
	mode-line-process ""
	truncate-lines t
	line-move-visual nil)
  (add-hook 'pre-command-hook #'monky-remember-point nil t)
  (add-hook 'post-command-hook #'monky-post-command-hook t t)
  (use-local-map monky-mode-map))

(defun monky-mode-init (dir submode refresh-func &rest refresh-args)
  (setq default-directory dir
	monky-submode submode
	monky-refresh-function refresh-func
	monky-refresh-args refresh-args)
  (monky-mode)
  (monky-refresh-buffer))


;;; Hg utils

(defun monky-hg-insert (args)
  (apply #'process-file
	 monky-hg-executable
	 nil (list t nil) nil
	 (append monky-hg-standard-options args)))

(defun monky-hg-output (args)
  (with-output-to-string
    (with-current-buffer standard-output
      (monky-hg-insert args))))

(defun monky-hg-string (&rest args)
  (monky-trim-line (monky-hg-output args)))


(defun monky-get-root-dir ()
  (let ((root (monky-hg-string "root")))
    (if root
	(concat root "/")
      (error "Not inside a hg repo"))))

(defun monky-find-buffer (submode &optional dir)
  (let ((rootdir (or dir (monky-get-root-dir))))
    (find-if (lambda (buf)
	       (with-current-buffer buf
		 (and default-directory
		      (equal (expand-file-name default-directory) rootdir)
		      (eq major-mode 'monky-mode)
		      (eq monky-submode submode))))
	     (buffer-list))))

(defun monky-find-status-buffer (&optional dir)
  (monky-find-buffer 'status dir))

(defun monky-for-all-buffers (func &optional dir)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (if (and (eq major-mode 'monky-mode)
	       (or (null dir)
		   (equal default-directory dir)))
	  (funcall func)))))


;;; Washers

(defmacro monky-with-wash-status (status file &rest body)
  (declare (indent 2))
  `(lambda ()
     (if (looking-at "\\([A-Z!? ]\\) \\([^\t\n]+\\)$")
	 (let ((,status (case (string-to-char (match-string-no-properties 1))
			  (?M 'modified)
			  (?A 'new)
			  (?R 'removed)
			  (?C 'clean)
			  (?! 'missing)
			  (?? 'untracked)
			  (?I 'ignored)
			  (?U 'unresolved)
			  (t nil)))
	       (,file (match-string-no-properties 2)))
	   (delete-region (point) (+ (line-end-position) 1))
	   ,@body
	   t)
       nil)))

;; File

(defun monky-wash-files ()
  (monky-wash-sequence
   (monky-with-wash-status status file
     (monky-with-section file 'file
       (monky-set-section-info file)
       (insert "\t" file "\n")))))

;; Hunk

(defun monky-hunk-item-diff (hunk)
  (let ((diff (monky-section-parent hunk)))
    (or (eq (monky-section-type diff) 'diff)
	(error "Huh?  Parent of hunk not a diff"))
    diff))

(defun monky-hunk-item-target-line (hunk)
  (save-excursion
    (beginning-of-line)
    (let ((line (line-number-at-pos)))
      (if (looking-at "-")
	  (error "Can't visit removed lines"))
      (goto-char (monky-section-beginning hunk))
      (if (not (looking-at "@@+ .* \\+\\([0-9]+\\),[0-9]+ @@+"))
	  (error "Hunk header not found"))
      (let ((target (string-to-number (match-string 1))))
	(forward-line)
	(while (< (line-number-at-pos) line)
	  ;; XXX - deal with combined diffs
	  (if (not (looking-at "-"))
	      (setq target (+ target 1)))
	  (forward-line))
	target))))

(defun monky-wash-hunk ()
  (if (looking-at "\\(^@+\\)[^@]*@+")
      (let ((n-columns (1- (length (match-string 1))))
	    (head (match-string 0)))
	(monky-with-section head 'hunk
	  (add-text-properties (match-beginning 0) (match-end 0)
			       '(face monky-diff-hunk-header))
	  (forward-line)
	  (while (not (or (eobp)
			  (looking-at "^diff\\|^@@")))
	    (let ((prefix (buffer-substring-no-properties
			   (point) (min (+ (point) n-columns) (point-max)))))
	      (cond ((string-match "\\+" prefix)
		     (monky-put-line-property 'face 'monky-diff-add))
		    ((string-match "-" prefix)
		     (monky-put-line-property 'face 'monky-diff-del))
		    (t
		     (monky-put-line-property 'face 'monky-diff-none))))
	    (forward-line))))
    nil))

;; Diff

(defvar monky-hide-diffs nil)

(defun monky-diff-item-kind (diff)
  (car (monky-section-info diff)))

(defun monky-diff-item-file (diff)
  (cadr (monky-section-info diff)))

(defun monky-diff-line-file ()
  (cond ((looking-at "^diff --git ./\\(.*\\) ./\\(.*\\)$")
	 (match-string-no-properties 2))
	((looking-at "^diff --cc +\\(.*\\)$")
	 (match-string-no-properties 1))
	(t
	 nil)))

(defun monky-wash-diff-section ()
  (if (looking-at "^diff")
      (let ((file (monky-diff-line-file))
	    (end (save-excursion
		   (forward-line)
		   (if (search-forward-regexp "^diff\\|^@@" nil t)
		       (goto-char (match-beginning 0))
		     (goto-char (point-max)))
		   (point-marker))))
	(let* ((status (cond
			((looking-at "^diff --cc")
			 'unmerged)
			((save-excursion
			   (search-forward-regexp "^new file" end t))
			 'new)
			((save-excursion
			   (search-forward-regexp "^deleted" end t))
			 'deleted)
			((save-excursion
			   (search-forward-regexp "^copy" end t))
			 'renamed)
			(t
			 'modified)))
	       (file2 (cond
		       ((save-excursion
			  (search-forward-regexp "^copy from \\(.*\\)"
						 end t))
			(match-string-no-properties 1)))))
	  (monky-set-section-info (list status file file2))
	  (monky-insert-diff-title status file file2)
	  (goto-char end)
	  (let ((monky-section-hidden-default nil))
	    (monky-wash-sequence #'monky-wash-hunk))))
    nil))

;; TODO cleanup
(defun monky-insert-diff (file)
  (let ((p (point)))
    (monky-hg-insert (list "diff" "--git" file))
    (if (not (eq (char-before) ?\n))
	(insert "\n"))
    (save-restriction
      (narrow-to-region p (point))
      (goto-char p)
      (monky-wash-diff-section)
      (goto-char (point-max)))))

(defun monky-insert-diff-title (status file file2)
  (let ((status-text (case status
		       (modified (format "Modified %s" file))
		       (new (format "New      %s" file))
		       (deleted (format "Deleted  %s" file))
		       (renamed (format "Renamed %s (from %s)"
					file file2))
		       (t (format "?        %s" file)))))
    (insert "\t" status-text "\n")))

;;; Untracked files

(defun monky-insert-untracked-files ()
  (monky-hg-section 'untracked "Untracked files" #'monky-wash-files
		    "status" "--unknown"))

;;; Missing files

(defun monky-insert-missing-files ()
  (monky-hg-section 'missing "Missing files" #'monky-wash-files
		    "status" "--deleted"))

;;; Changes

(defun monky-wash-changes ()
  (monky-wash-sequence
   (monky-with-wash-status status file
     (let ((monky-section-hidden-default monky-hide-diffs))
       (if (or monky-staged-all-files
	       (member file monky-old-staged-files))
	   (monky-stage-file file)
	 (monky-with-section file 'diff
	   (monky-insert-diff file)))))))


(defun monky-insert-changes ()
  (let ((monky-hide-diffs t))
    (setq monky-old-staged-files (copy-list monky-staged-files))
    (setq monky-staged-files '())
    (monky-hg-section 'changes "Changes:" #'monky-wash-changes
		      "status" "--modified" "--added" "--removed")))

;; Staged Changes

(defvar monky-staged-all-files nil)
(defvar monky-old-staged-files '())
(defvar monky-staged-files '()
  "List of staged files")

(make-variable-buffer-local 'monky-staged-files)
(put 'monky-staged-files 'permanent-local t)

(defun monky-stage-file (file)
  (if (not (member file monky-staged-files))
      (setq monky-staged-files (cons file monky-staged-files))))

(defun monky-unstage-file (file)
  (setq monky-staged-files (delete file monky-staged-files)))

(defun monky-insert-staged-changes ()
  (when monky-staged-files
    (monky-with-section 'staged nil
      (insert (propertize "Staged changes:" 'face 'monky-section-title) "\n")
      (let ((monky-section-hidden-default t))
	(dolist (file monky-staged-files)
	  (monky-with-section file 'diff
	    (monky-insert-diff file))))))
  (setq monky-staged-all-files nil))


;;; Parents

(defvar monky-parents '())
(defvar monky-unresolved-files '())

(defun monky-wash-parent ()
  (if (looking-at "changeset:\s*\\([0-9]+\\):\\([0-9a-z]+\\)")
      (let ((changeset (match-string 2)))
	(add-to-list 'monky-parents changeset)
	(forward-line)
	(while (not (or (eobp)
			(looking-at "changeset:\s*\\([0-9]+\\):\\([0-9a-z]+\\)")))
	  (forward-line))
	t)
    nil))

(defun monky-wash-parents ()
  (monky-wash-sequence #'monky-wash-parent))

(defun monky-insert-parents ()
  (monky-hg-section 'parents "Parents:"
		    #'monky-wash-parents "parents"))

;;; UnResolved Files

(defun monky-wash-unresolved-files ()
  (monky-wash-sequence
   (monky-with-wash-status status file
     (let ((monky-section-hidden-default monky-hide-diffs))
       (add-to-list 'monky-unresolved-files file)
       (monky-with-section file 'diff
	 (monky-insert-diff file))))))

(defun monky-insert-unresolved-files ()
  (let ((monky-hide-diffs t))
    (setq monky-unresolved-files '())
    (monky-hg-section 'unresolved "Unresolved Files:" #'monky-wash-unresolved-files
		      "resolve" "--list")))

;;; Resolved Files

(defun monky-wash-resolved-files ()
  (monky-wash-sequence
   (monky-with-wash-status status file
     (let ((monky-section-hidden-default monky-hide-diffs))
       (when (not (member file monky-unresolved-files))
	 (monky-with-section file 'diff
	   (monky-insert-diff file)))))))

(defun monky-insert-resolved-files ()
  (let ((monky-hide-diffs t))
    (monky-hg-section 'resolved "Resolved Files:" #'monky-wash-resolved-files
		      "status" "--modified" "--added" "--removed")))
;;; Status mode

(defun monkey-refresh-status ()
  (let ((monky-parents '())
	(monky-unresolved-files '()))
    (monky-create-buffer-sections
      (monky-with-section 'status nil
	(monky-insert-parents)
	(if (> (length monky-parents) 1)
	    (progn
	      (monky-insert-unresolved-files)
	      (monky-insert-resolved-files))
	  (monky-insert-untracked-files)
	  (monky-insert-missing-files)
	  (monky-insert-changes)
	  (monky-insert-staged-changes))))))

(define-minor-mode monky-status-mode
  "Minor mode for hg status."
  :group monky
  :init-value ()
  :lighter ()
  :keymap monky-status-mode-map)

(defun monky-status ()
  (interactive)
  (let* ((rootdir (monky-get-root-dir))
	 (buf (or (monky-find-status-buffer rootdir)
		  (generate-new-buffer
		   (concat "*monky: "
			   (file-name-nondirectory
			    (directory-file-name rootdir)) "*")))))
    (pop-to-buffer buf)
    (monky-mode-init rootdir 'status #'monkey-refresh-status)
    (monky-status-mode t)))

;;; Log edit mode

(defvar monky-pre-log-edit-window-configuration nil)

(defvar monky-log-edit-buffer-name "*monky-edit-log*"
  "Buffer name for composing commit messages.")

(setq monky-log-edit-mode-map
      (let ((map (make-sparse-keymap)))
	(define-key map (kbd "C-c C-c") 'monky-log-edit-commit)
	map))

(define-derived-mode monky-log-edit-mode text-mode "Monky Log Edit")

(defun monky-log-edit-commit ()
  "Finish edit and commit."
  (interactive)
  (when (= (buffer-size) 0)
    (error "No commit message"))
  (let ((commit-buf (current-buffer)))
    (with-current-buffer (monky-find-status-buffer default-directory)
      (apply #'monky-run-async-with-input commit-buf
	     monky-hg-executable
	     (append monky-hg-standard-options
		     (list "commit" "-l" "/dev/stdin")
		     monky-staged-files))))
  (erase-buffer)
  (bury-buffer)
  (when monky-pre-log-edit-window-configuration
    (set-window-configuration monky-pre-log-edit-window-configuration)
    (setq monky-pre-log-edit-window-configuration nil)))

(defun monky-pop-to-log-edit (operation)
  (let ((dir default-directory)
	(buf (get-buffer-create monky-log-edit-buffer-name)))
    (setq monky-pre-log-edit-window-configuration
	  (current-window-configuration))
    (pop-to-buffer buf)
    (setq default-directory dir)
    (monky-log-edit-mode)
    (message "Type C-c C-c to %s (C-c C-k to cancel)." operation)))

(defun monky-log-edit ()
  "Brings up a buffer to allow editing of commit messages."
  (interactive)
  (if (not monky-staged-files)
      (error "Nothing staged.")
    (monky-pop-to-log-edit "commit")))

(provide 'monky)
