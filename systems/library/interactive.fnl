(local {: run} (require :systems/library/common))

(local home (os.getenv :HOME))
(local user (os.getenv :USER))
(local host (os.getenv :HOST))

(fn install-scala []
  (let [dir (.. home :/.local/share/coursier/bin)]
    (run [:coursier :java :--jvm "temurin:17" :--setup])
    (run [:coursier :setup :--yes])
    (run [:coursier :install :metals :--install-dir dir])))

(fn connect-github []
  (let [ssh-key-path (.. home :/.ssh/ user :_rsa.pub)
        repo "git@github.com:brahayan-dev/.dotfiles.git"]
    (run [:git :remote :set-url :origin repo])
    (run [:gh :auth :login])
    (run [:gh :auth :refresh :-h :github.com :-s "admin:ssh_signing_key"])
    (run [:gh :ssh-key :add ssh-key-path :-t host])))

{: install-scala : connect-github}
