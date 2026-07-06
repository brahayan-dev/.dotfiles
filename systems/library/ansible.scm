(define-module (systems library ansible)
  #:use-module (systems library common)
  #:use-module (ice-9 match)
  #:export (->ping
            ->setup))

(define setup-file
  (if (string=? os "Darwin")
      "systems/macos.cfg" "systems/linux.cfg"))

(define host-file " -i systems/hosts.ini")

(define (->ping)
  (setenv "ANSIBLE_CONFIG" setup-file)
  (system (string-append "ansible -c local -m ping" host-file " Workstation")))

(define playbook
  (match (list os marked?)
    ['("Darwin" #t) " systems/work.yml"]
    ['("Darwin" #f) " systems/life.yml"]
    ['("Linux" _) " systems/linux.yml"]))

(define (->setup)
  (let* ([vault-file " --vault-password-file systems/.vault_"]
         [become-file " --become-password-file systems/.become_"]
         [command (string-append "ansible-playbook -c local"
                                 host-file vault-file become-file playbook)])
    (setenv "ANSIBLE_CONFIG" setup-file)
    (system command)))
