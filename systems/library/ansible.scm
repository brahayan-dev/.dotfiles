(define-module (systems library ansible)
  #:use-module (systems library common)
  #:export (->ping))

(define file
  (if (string=? os "Darwin")
      "systems/macos.cfg" "systems/linux.cfg"))

(define (->ping)
  (setenv "ANSIBLE_CONFIG" file)
  (system "ansible -c local -m ping -i systems/hosts.ini Workstation"))
