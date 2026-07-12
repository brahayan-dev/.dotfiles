(local os-name (let [handler (io.popen "uname -s")
                     raw (handler:read :*a)
                     _ (handler:close)
                     answer (raw:gsub "%s+$" "")]
                 answer))

(local working-day? false)

{: os-name : working-day?}
