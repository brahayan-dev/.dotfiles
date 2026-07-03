(define-module (systems library work)
  #:export (->bom-dia))

(define clis '("nu-co" "nu-mx" "nu-ist" "nu-data"))

(define (nu-update-proj)
  (system "nu proj update nudev")
  (system "nu proj update nucli")
  (system "nu proj update cljdev"))

(define (nu-dev-bd)
  (system "nu dev bd --countries br,mx,co,data"))

(define (nu-creds-br)
  (system "nu aws shared-role-credentials refresh --account-alias br-staging"))

(define (nu-certs)
  (for-each
   (lambda (cli)
     (system (string-append cli " certs setup --env prod"))
     (system (string-append cli " certs setup --env staging")))
   clis))

(define (nu-jwt)
  (for-each
   (lambda (cli)
     (system (string-append cli " auth jwt --env prod"))
     (system (string-append cli " auth jwt --env staging")))
   clis))

(define (nu-tokens-stg)
  (for-each
   (lambda (cli)
     (system (string-append cli " auth get-refresh-token --env staging --force")))
   clis)
  (for-each
   (lambda (cli)
     (system (string-append cli " auth get-access-token --env staging")))
   clis))

(define (->bom-dia)
  (nu-update-proj)
  (nu-dev-bd)
  (nu-creds-br)
  (nu-certs)
  (nu-jwt)
  (nu-tokens-stg))
