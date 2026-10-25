(local {: run} (require :systems/library/common))

(local home (os.getenv :HOME))
(local user (os.getenv :USER))
(local host (os.getenv :HOST))

(fn install-ruby []
  (run [:mise :use :-g "ruby@4"])
  (run [:mise
        :x
        :--
        :gem
        :install
        :rubocop
        :ruby-lsp
        :htmlbeautifier
        :--no-document]))

(fn install-python []
  (run [:mise :use :-g "python@latest"]))

(fn connect-github []
  (let [ssh-key-path (.. home :/.ssh/ user :_rsa.pub)
        repo "git@github.com:brahayan-dev/.dotfiles.git"]
    (run [:git :remote :set-url :origin repo])
    (run [:gh :auth :login])
    (run [:gh :auth :refresh :-h :github.com :-s "admin:ssh_signing_key"])
    (run [:gh :ssh-key :add ssh-key-path :-t host])))

{: install-ruby : install-python : connect-github}
