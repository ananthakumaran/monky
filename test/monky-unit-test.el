(require 'monky)
(require 'ert)

(ert-deftest monky--author-name ()
  (should
   (equal
    (monky--author-name "foo bar <foo@example.com>")
    "foo"))
  (should
   (equal
    (monky--author-name "bar@example.com")
    "bar"))
  (should
   (equal
    (monky--author-name "foo")
    "foo")))
