(local clis [:nu-co :nu-mx :nu-ist :nu-data])
(local run #(-> $ (table.concat " ") os.execute))

(fn nu-update-proj []
  (run [:nu :proj :update :nudev])
  (run [:nu :proj :update :nucli])
  (run [:nu :proj :update :cljdev]))

(fn nu-dev-bd []
  (run [:nu :dev :bd :--countries "br,mx,co,data"]))

(fn nu-creds-br []
  (run [:nu
        :aws
        :shared-role-credentials
        :refresh
        :--account-alias
        :br-staging]))

(fn nu-certs []
  (each [_ cli (ipairs clis)]
    (run [cli :certs :setup :--env :prod])
    (run [cli :certs :setup :--env :staging])))

(fn nu-jwt []
  (each [_ cli (ipairs clis)]
    (run [cli :auth :jwt :--env :prod])
    (run [cli :auth :jwt :--env :staging])))

(fn nu-tokens-stg []
  (each [_ cli (ipairs clis)]
    (run [cli :auth :get-refresh-token :--env :staging :--force])
    (run [cli :auth :get-access-token :--env :staging])))

(local steps [nu-update-proj
              nu-dev-bd
              nu-creds-br
              nu-certs
              nu-jwt
              nu-tokens-stg])

(fn bom-dia []
  (each [_ step (ipairs steps)]
    (step)))

{: bom-dia}
