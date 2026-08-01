(local {: run} (require :systems/library/common))

(local home (os.getenv :HOME))
(local user (os.getenv :USER))
(local host (os.getenv :HOST))

(fn install-fsharp []
  (run [:dotnet :tool :install :--global :fantomas])
  (run [:dotnet :tool :install :--global :fsautocomplete]))

(fn install-rust []
  (run [:rustup :component :add :clippy])
  (run [:rustup :component :add :rustfmt]))

(fn install-scala []
  (let [dir (.. home :/.local/share/coursier/bin)]
    (run [:coursier :java :--jvm "temurin:11" :--setup])
    (run [:coursier :install "sbt:1.9.9"])
    (run [:coursier :install "scalafmt:2.7.5"])
    (run [:coursier :install :metals :--install-dir dir])
    (run [:coursier :install "scala:2.12.19" "scalac:2.12.19"])))

(fn connect-github []
  (let [ssh-key-path (.. home :/.ssh/ user :_rsa.pub)
        repo "git@github.com:brahayan-dev/.dotfiles.git"]
    (run [:git :remote :set-url :origin repo])
    (run [:gh :auth :login])
    (run [:gh :auth :refresh :-h :github.com :-s "admin:ssh_signing_key"])
    (run [:gh :ssh-key :add ssh-key-path :-t host])))

{: install-fsharp : install-rust : install-scala : connect-github}
