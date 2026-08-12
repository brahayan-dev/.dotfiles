(local {: environment &as common} (require :systems.library.common))

(local repos-dot [:.dotfiles])
(local repos-base [:kiln :workbook :turing :curriculum])
(local repos-akeptous [:risk-etl :risk-api :risk-web :risk-hub])
(local repos-fentari [:thalassa-air :thalassa-box :thalassa-hub])
(local repos-work [:babel
                   :agora
                   :earner
                   :kairos
                   :itaipu
                   :conrado
                   :wiseguy
                   :giovanni
                   :two-face
                   :thalassa
                   :underboss
                   :solar-wind
                   :controlinho
                   :optimus-prime
                   :arcadia-policies
                   :reference-data-registry
                   :lending-claude-workspace
                   :data-quality-custom-checks])

(local home (os.getenv :HOME))
(local dot {:repos repos-dot :base-path (.. home "/")})
(local work {:repos repos-work :base-path (.. home :/dev/nu/)})
(local base {:repos repos-base :base-path (.. home :/Projects/)})
(local fentari {:repos repos-fentari :base-path (.. home :/Projects/)})
(local akeptous {:repos repos-akeptous :base-path (.. home :/Projects/)})

(fn run [v]
  (-> v (table.concat " ") print))

(fn join-cmd [repo base-path]
  (let [part-cmd (.. repo "=" "'" :cd " " base-path repo)]
    {:cd-alias (.. "_" part-cmd "'")
     :nvim-alias (.. "__" part-cmd " && " "nvim ." "'")}))

(fn transformation [{: repos : base-path}]
  (icollect [_ repo (ipairs repos)]
    (join-cmd repo base-path)))

(fn ->aliases [v]
  (each [_ {: cd-alias : nvim-alias} (ipairs v)]
    (run [:alias cd-alias])
    (run [:alias nvim-alias])))

(fn load [k]
  (-> k transformation ->aliases))

(fn generate-aliases []
  (load dot)
  (load base)
  (case environment
    :work (load work)
    _ (do
        (load akeptous)
        (load fentari))))

(fn clone-repositories []
  (each [_ repo (ipairs repos-work)]
    (common.run [:nu :proj :clone repo])))

{: generate-aliases : clone-repositories}
