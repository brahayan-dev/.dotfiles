(local os-name (let [handler (io.popen "uname -s")
                     raw (handler:read :*a)
                     _ (handler:close)
                     answer (raw:gsub "%s+$" "")]
                 answer))

(local working-day? (let [home (os.getenv :HOME)
                          path (.. home :/.nurc)
                          answer (os.rename path path)]
                      (not= nil answer)))

{: os-name : working-day?}
