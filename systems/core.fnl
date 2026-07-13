(local ansible (require :systems.library.ansible))
(local {: dispatch} (require :systems.library.logic))

(local ->ping {:allowed-on :all :handler ansible.ping})
(local ->setup {:allowed-on :all :handler ansible.setup})
(local ->default {:allowed-on :all :handler #(print :cli!)})
(local ->refresh-nu {:allowed-on :work :handler #(print :working!)})
(local ->install-clojure {:allowed-on :work :handler #(print :installed!)})
(local ->install-scala {:allowed-on :work :handler #(print :installed!)})
(local ->connect-github {:allowed-on [:life :linux]
                         :handler #(print :connected!)})

(fn register [{: command : entity}]
  (case [command entity]
    [:ping _] ->ping
    [:setup _] ->setup
    [:install :scala] ->install-scala
    [:install :clojure] ->install-clojure
    [:connect :github] ->connect-github
    [:refresh :nu] ->refresh-nu
    [_ _] ->default))

(-> {:command (. arg 1) :entity (. arg 2)}
    register
    dispatch)
