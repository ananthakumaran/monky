;;; test-helper.el --- Helper for tests              -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Wilfred Hughes

;; Author:  <me@wilfred.me.uk>

;;; Code:

(require 'ert)
(require 'f)

(let ((monky-dir (f-parent (f-dirname (f-this-file)))))
  (add-to-list 'load-path monky-dir))

(require 'undercover)
(undercover "monky.el"
	    (:exclude "*-test.el")
	    (:report-file "/tmp/undercover-report.json"))

;;; test-helper.el ends here
