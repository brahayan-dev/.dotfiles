(define-module (systems library ansible)
  #:use-module (systems library common)
  #:export (->ping))

(define file
  (if (string=? os "Darwin")
      "systems/macos.cfg" "systems/linux.cfg"))

(define (set-configuration)
  (setenv "ANSIBLE_CONFIG" file))

(define (->ping)
  (set-configuration)
  (system "ansible -c local -m ping -i systems/hosts.ini Workstation"))

(define (->setup)
  (set-configuration))
