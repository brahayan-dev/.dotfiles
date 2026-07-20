(local os-name (let [handler (io.popen "uname -s")
                     raw (handler:read :*a)
                     _ (handler:close)
                     answer (raw:gsub "%s+$" "")]
                 answer))

(local exists-nurc? (let [home (os.getenv :HOME)
                          path (.. home :/.nurc)
                          answer (os.rename path path)]
                      (not= nil answer)))

(local environment (case [os-name exists-nurc?]
                     [:Linux _] :linux
                     [:Darwin true] :work
                     [:Darwin false] :life))

(fn run [v]
  (let [cmd (table.concat v " ")]
    (print "-->>" cmd)
    (os.execute cmd)))

{: run : os-name : environment}
