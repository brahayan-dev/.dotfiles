(define-module (systems main)
  #:use-module (systems library ansible)
  #:use-module (systems library common)
  #:use-module (systems library work))

(command 'refresh 'nu
         #:handler ->bom-dia
         #:environments '(work))

(command 'setup
         #:environments '(linux life work)
         #:handler (lambda () (display "Setting up your workstation!")))

(command 'ping
         #:environments '(linux life work)
         #:handler (->ping "systems/life.cfg") )

(command 'install 'scala
         #:environments '(work)
         #:handler (lambda () (display "Installing Scala toolchain!")))

(command 'install 'clojure
         #:environments '(linux life work)
         #:handler (lambda () (display "Installing Clojure toolchain!")))

(command 'install 'python
         #:environments '(linux life)
         #:handler (lambda () (display "Installing Python toolchain!")))

(command 'connect 'github
         #:environments '(linux life)
         #:handler (lambda () (display "Connecting to GitHub!")))
