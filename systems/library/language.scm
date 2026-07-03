(define-module (systems library language)
  #:export (install-scala
            install-clojure))

(define (install-scala)
  (let ((dir "~/.local/share/coursier/bin"))
    (system "coursier java --jvm temurin:17 --setup")
    (system "coursier setup --yes")
    (system (string-append "coursier install metals --install-dir " dir))))

(define (install-clojure)
  (let ((dir "~/.local/bin"))
    (system "coursier java --jvm temurin:21 --setup")
    (system (string-append
             "curl -s https://raw.githubusercontent.com/clojure-lsp/clojure-lsp/master/install"
             " | bash -s -- --dir " dir))))
