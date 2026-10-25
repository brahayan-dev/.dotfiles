(local os-name (let [handler (io.popen "uname -s")
                     raw (handler:read :*a)
                     _ (handler:close)
                     answer (raw:gsub "%s+$" "")]
                 answer))

(local environment (if (= os-name :Linux) :linux :life))

(fn run-string [cmd]
  (print "-->>" cmd)
  (let [(ok _ code) (os.execute cmd)]
    (when (not ok)
      (io.stderr:write (.. "\nCommand failed (exit " (or code 1) "): " cmd "\n"))
      (os.exit (or code 1)))))

(fn run [v]
  (run-string (table.concat v " ")))

{: run : run-string : os-name : environment}
