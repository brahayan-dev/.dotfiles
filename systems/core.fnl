(local ansible (require :systems.library.ansible))
(local interactive (require :systems.library.interactive))
(local repository (require :systems.library.repository))

(local {: dispatch} (require :systems.library.logic))

(local usage
       ["usage: ./workstation <command> [entity]"
        ""
        "commands:"
        "    ping                ansible -m ping (sanity check)"
        "    setup               run the ansible playbook for the host"
        "    install ruby        install the Ruby toolchain via mise"
        "    install python      install the Python runtime via mise"
        "    generate aliases    generate aliases for each repository"
        "    connect github      authenticate with the remote forge"])

(local ping {:allowed-on :all :handler ansible.ping})
(local setup {:allowed-on :all :handler ansible.setup})
(local generate-aliases {:allowed-on :all :handler repository.generate-aliases})
(local install-ruby {:allowed-on :all :handler interactive.install-ruby})
(local install-python {:allowed-on :all :handler interactive.install-python})
(local connect-github {:allowed-on :all :handler interactive.connect-github})

(local default
       {:allowed-on :all :handler #(each [_ line (ipairs usage)] (print line))})

(fn register [{: command : entity}]
  (case [command entity]
    [:ping _] ping
    [:setup _] setup
    [:install :ruby] install-ruby
    [:install :python] install-python
    [:connect :github] connect-github
    [:generate :aliases] generate-aliases
    [_ _] default))

(-> {:command (. arg 1) :entity (. arg 2)}
    register
    dispatch)
