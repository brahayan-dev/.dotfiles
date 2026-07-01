(define-module (systems library common)
  #:use-module (srfi srfi-197)
  #:use-module (ice-9 match)
  #:export (command))

(define (valid? action entity)
  (let* ([params (cdr (command-line))]
         [safe-entity (and entity (symbol->string entity))]
         [safe-action (and action (symbol->string action))])
    (match params
      [(action')
       (string=? safe-action action')]
      [(action' entity')
       (and (string=? safe-action action')
            (string=? safe-entity entity'))]
      [_ #f])))

(define* (command action
                  #:optional entity
                  #:key handler
                  environments)
  (when (valid? action entity)
    (handler)))
