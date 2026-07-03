(define-module (systems library common)
  #:use-module (srfi srfi-1)
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

(define references
  '((linux . "Linux")
    (life . "Darwin")
    (work . "Darwin.nurc")))

(define exists?
  (file-exists? (string-append (getenv "HOME") "/.nurc")))

(define (allowed? environments)
  (let* ([os (chain (uname) (vector-ref _ 0))]
         [mark (if exists? ".nurc" "")]
         [marked-os (string-append os mark)]
         [items (map (lambda (e) (assq-ref references e)) environments)])
    (any (lambda (i) (string=? marked-os i)) items)))

(define* (command action
                  #:optional entity
                  #:key handler
                  environments)
  (let ([allowed (allowed? environments)]
        [valid (valid? action entity)])
    (when (and valid allowed)
      (handler))))
