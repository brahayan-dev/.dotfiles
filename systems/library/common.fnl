(fn os-name []
  (let [handler (io.popen "uname -s")
        raw (handler:read :*a)
        _ (handler:close)
        answer (raw:gsub "%s+$" "")]
    answer))

(local marked? false)

{: os-name : marked?}
