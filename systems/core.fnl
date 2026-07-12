(local ansible (require :systems.library.ansible))

(fn main [{: command : entity}]
  (case [command entity]
    [:ping _] (ansible.ping {:environments [:work :life :linux]})
    [:setup _] (ansible.setup {:environments [:work :life :linux]})
    [:install :clojure] (print :ok!)
    [:install :scala] (print :done!)
    [:connect :github] (print :connected!)
    [:refresh :nu] (print :working!)
    [_ _] (print :cli!)))

(main {:command (. arg 1) :entity (. arg 2)})
