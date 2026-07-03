(define-module (systems library ansible)
  #:export (->ping))

(define (->ping file)
  (lambda ()
    (setenv "ANSIBLE_CONFIG" file)
    (system "ansible -c local -m ping -i systems/hosts.ini Workstation")))
