# Work Environment

## Language Preferences

- When writing in Spanish, use Mexican (MX) or Colombian (CO) Spanish — never Argentine (AR) Spanish.
- Write all code, comments, and documentation in English, even if the prompt is in another language.
- All the Slack messages should be in English, even if the prompt is in another language.
- All the Slack messages should be set in draft mode, and should not be sent until the user explicitly sends them.

## Language Stack

| Language | Runtime                      | LSP                      | Formatter | Notes                                   |
| -------- | ---------------------------- | ------------------------ | --------- | --------------------------------------- |
| Scala    | coursier (JDK 11)            | Metals (via nvim-metals) | —         | Spark development                       |
| Clojure  | homebrew + coursier (JDK 11) | clojure-lsp              | cljfmt    | ClojureScript via aliases + shadow-cljs |
| Java     | coursier (temurin:11)        | —                        | —         | JDK via coursier                        |

## Wingman — Rollout Investigations

Use the wingman skill for any rollout investigation or failure diagnosis.
