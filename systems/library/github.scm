(define-module (systems library github)
  #:export (connect-github))

(define origin "git@github.com:brahayan-dev/.dotfiles.git")

(define (set-origin)
  (system (string-append "git remote set-url origin " origin)))

(define (authenticate)
  (system "gh auth login"))

(define (refresh-token)
  (system "gh auth refresh -h github.com -s admin:ssh_signing_key"))

(define (set-ssh-key)
  (let ([home (getenv "HOME")]
        [host (getenv "HOST")]
        [user (getenv "USER")])
    (system (string-append
             "gh ssh-key add " home "/.ssh/" user "_rsa.pub -t Ak " host))))

(define (connect-github)
  (set-origin)
  (authenticate)
  (refresh-token)
  (set-ssh-key))
