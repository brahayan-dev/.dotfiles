(local {: environment} (require :systems.library.common))

(fn check-string [s]
  (or (= s environment) (= s :all)))

(fn check-table [t]
  (var hit false)
  (each [_ s (ipairs t)]
    (when (check-string s)
      (set hit true)))
  hit)

(fn allowed? [allowed-on]
  (case (type allowed-on)
    :table (check-table allowed-on)
    :string (check-string allowed-on)))

(fn dispatch [{: allowed-on : handler}]
  (if (allowed? allowed-on)
      (handler)))

{: dispatch}
