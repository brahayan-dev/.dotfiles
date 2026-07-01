(define-module (systems library ansible)
  #:export (->ping))

(define (->ping)
  (system "ansible -c local -m ping"))
