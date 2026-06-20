# Linux Environment

## Language Preferences

- When writing in Spanish, use Mexican (MX) or Colombian (CO) Spanish — never Argentine (AR) Spanish.
- Write all code, comments, and documentation in English, even if the prompt is in another language.

## Language Stack

| Language | Runtime                    | LSP                 | Formatter              |
| -------- | -------------------------- | ------------------- | ---------------------- |
| Python   | mise python@3              | basedpyright + ruff | conform → ruff_format  |
| Lua      | LuaJIT (pacman)            | lua_ls              | conform → stylua       |
| Scala    | coursier (JDK 17)          | Metals              | conform → LSP fallback |
| Clojure  | pacman + coursier (JDK 17) | clojure-lsp         | conform → LSP fallback |

### Install commands

```
./workstation install python   # mise use -g python@3 + pip install duckdb basedpyright debugpy ruff pytest
./workstation install lua      # luarocks install busted
./workstation install scala    # cs java --jvm temurin:17 --setup + cs setup --yes + cs install metals
./workstation install clojure  # cs java --jvm temurin:17 --setup + clojure-lsp install script
```
