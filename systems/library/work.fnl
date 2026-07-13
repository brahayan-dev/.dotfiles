(fn run [command]
  (-> command (table.concat " ") os.execute))

(fn bom-dia []
  (run [:nu :dev :bd :--countries "br,mx,co,data"]))

{: bom-dia}
