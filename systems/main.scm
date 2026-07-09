(define-module (systems main)
  #:use-module (systems library ansible)
  #:use-module (systems library common)
  #:use-module (systems library github)
  #:use-module (systems library language)
  #:use-module (systems library work))

(command 'refresh 'nu
         #:handler ->bom-dia
         #:environments '(work))

(command 'setup
         #:handler ->setup
         #:environments '(linux life work))

(command 'ping
         #:handler ->ping
         #:environments '(linux life work))

(command 'install 'scala
         #:environments '(work)
         #:handler install-scala)

(command 'install 'clojure
         #:environments '(linux)
         #:handler install-clojure)

(command 'connect 'github
         #:environments '(linux life)
         #:handler connect-github)
