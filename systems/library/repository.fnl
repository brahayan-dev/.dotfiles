(local {: run} (require :systems/library/common))

(local repos-dot [:.dotfiles])
(local repos-base [:kiln :workbook :turing :frapelle :nullstellensatz])
(local repos-akeptous [:box :toy :zen :hub])
(local repos-fentari [:thalassa-air :thalassa-box :thalassa-hub])

(local home (os.getenv :HOME))
(local dot {:repos repos-dot :base-path (.. home "/")})
(local base {:repos repos-base :base-path (.. home :/Projects/)})
(local akeptous {:repos repos-akeptous :base-path (.. home :/Projects/)})
(local fentari {:repos repos-fentari :base-path (.. home :/Projects/)})

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
  (load fentari)
  (load akeptous))

{: generate-aliases}
