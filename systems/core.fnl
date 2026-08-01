(local ansible (require :systems.library.ansible))
(local interactive (require :systems.library.interactive))
(local repository (require :systems.library.repository))
(local work (require :systems.library.work))

(local {: dispatch} (require :systems.library.logic))

(local usage
       ["usage: ./workstation <command> [entity]"
        ""
        "commands:"
        "    ping                ansible -m ping (sanity check)"
        "    setup               run the ansible playbook for the host"
        "    install rust        install the rust toolchain via rustup"
        "    install scala       install the scala toolchain via coursier"
        "    install fsharp      install the fsharp toolchain via dotnet"
        "    clone repositories  clone repositories used in work"
        "    generate aliases    generate aliases for each repository"
        "    connect github      authenticate with the remote forge"
        "    refresh nu          refresh work credentials (work only)"])

(local ping {:allowed-on :all :handler ansible.ping})
(local setup {:allowed-on :all :handler ansible.setup})
(local refresh-nu {:allowed-on :work :handler work.bom-dia})
(local generate-aliases {:allowed-on :all :handler repository.generate-aliases})
(local install-scala {:allowed-on :work :handler interactive.install-scala})
(local install-rust {:allowed-on :all :handler interactive.install-rust})

(local install-fsharp
       {:allowed-on [:life :linux] :handler interactive.install-fsharp})

(local connect-github
       {:allowed-on [:life :linux] :handler interactive.connect-github})

(local clone-repositories
       {:allowed-on :work :handler repository.clone-repositories})

(local default
       {:allowed-on :all :handler #(each [_ line (ipairs usage)] (print line))})

(fn register [{: command : entity}]
  (case [command entity]
    [:ping _] ping
    [:setup _] setup
    [:refresh :nu] refresh-nu
    [:install :rust] install-rust
    [:install :scala] install-scala
    [:install :fsharp] install-fsharp
    [:connect :github] connect-github
    [:clone :repositories] clone-repositories
    [:generate :aliases] generate-aliases
    [_ _] default))

(-> {:command (. arg 1) :entity (. arg 2)}
    register
    dispatch)
