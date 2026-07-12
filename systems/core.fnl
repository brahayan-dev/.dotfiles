(local ansible (require :systems.library.ansible))

(fn main [{: command : entity}]
  (case [command entity]
    [:ping _] (ansible.ping)
    [:setup _] (ansible.setup)
    [:install :clojure] (print :ok!)
    [:install :scala] (print :done!)
    [:connect :github] (print :connected!)
    [:refresh :nu] (print :working!)
    [_ _] (print :cli!)))

(main {:command (. arg 1) :entity (. arg 2)})
