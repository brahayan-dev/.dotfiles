# Work Environment

## Language Preferences

- When writing in Spanish, use Mexican (MX) or Colombian (CO) Spanish — never Argentine (AR) Spanish.
- Write all code, comments, and documentation in English, even if the prompt is in another language.
- All the Slack messages should be in English, even if the prompt is in another language.
- All the Slack messages should be set in draft mode, and should not be sent until the user explicitly sends them.

## Language Stack

| Language | Runtime                      | LSP                      | Formatter | Notes             |
| -------- | ---------------------------- | ------------------------ | --------- | ----------------- |
| Scala    | coursier (JDK 11)            | Metals (via nvim-metals) | —         | Spark development |
| Clojure  | homebrew + coursier (JDK 11) | clojure-lsp-native       | cljfmt    |                   |
| Java     | coursier (temurin:11)        | —                        | —         | JDK via coursier  |

## Fennel Style

Canonical reference: https://fennel-lang.org/style — defer to `fnlfmt --fix` for formatting.

### Formatting

- 2-space indentation, spaces not tabs, no trailing whitespace.
- Closing parens on the same line, never on their own line.
- Keep lines under ~80 columns.
- One blank line between top-level forms; group consecutive `local` calls without blanks.

### Names

- Lower-case with hyphens (`xml-http-request`, not `XMLHttpRequest`). CamelCase is forbidden.
- Predicates end with `?` (`pair?`); destructive ops end with `!` (`append!`); variants end with `*`; conversions use `->` (`bytes->table`).
- Underscore-prefixed names for ignored (`_`, `_foo`) or nilable params (`foo?`).
- When exporting fields to Lua consumers, use `snake_case` in the exported key only (`{:append_map append-map}`).

### Forms

- `when` is for side-effects only; use `if` for value-returning conditions.
- Prefer `partial` to `#()` hashfn shorthand; never use long-form `(hashfn)`. `#()` only for single-line bodies.
- Use `<` and `<=`, avoid `>` and `>=`.
- Destructure rather than `.` for field access: `(let [{: address} (get-label)] ...)`.
- Empty table check: `(= nil (next t))`, not `(= 0 (length t))`.
- `(. tbl :field)` and `(: obj :method)` only when the key is not a static symbol.
- Forbid `require-macros`, `eval-compiler`, and the `lua` special form (except as a temporary porting hack).

### Modules

- Top-level `require` calls at the top of the file, grouped.
- Build the module table at the bottom (`{: foo : bar}`), return always a table.
- Top-level `local` only at module scope; use `let` inside functions.
- Loading a module must have no side effects.

### Lambdas and calls

- `#()` for single-expression bodies; `(fn [] ...)` when multi-statement form should be visually distinct.
- Method calls on a freshly-required module need double paren: `((. (require :foo) :method) args)`.

### Comments (project override)

- No comments by default. If unavoidable, keep to one short line. The official guide's `;;;`/`;;`/`;` convention is acknowledged but not used here.

## Wingman — Rollout Investigations

Use the wingman skill for any rollout investigation or failure diagnosis.
