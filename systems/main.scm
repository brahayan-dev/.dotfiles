(use-module (systems library common))

(command 'refresh 'nu
         #:alias 'refresh
         #:environments '(work)
         #:handler (lambda () (display "Hi there!")))

(command 'setup
         #:environments '(linux life work)
         #:handler (lambda () (display "Hi there!")))

(command 'ping
         #:environments '(linux life work)
         #:handler (lambda () (display "Hi there!")))

(command 'install 'scala
         #:environments '(work)
         #:handler (lambda () (display "Hi there!")))

(command 'install 'clojure
         #:environments '(linux life work)
         #:handler (lambda () (display "Hi there!")))

(command 'install 'python
         #:environments '(linux life)
         #:handler (lambda () (display "Hi there!")))

(command 'connect 'github
         #:environments '(linux life)
         #:handler (lambda () (display "Hi there!")))
