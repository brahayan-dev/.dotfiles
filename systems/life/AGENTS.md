# Life Environment

## Language Preferences

- When writing in Spanish, use Mexican (MX) or Colombian (CO) Spanish — never Argentine (AR) Spanish.
- Write all code, comments, and documentation in English, even if the prompt is in another language.

## Language Stack

| Language | Runtime                | LSP        | Formatter                 | Notes           |
| -------- | ---------------------- | ---------- | ------------------------- | --------------- |
| Just     | static binary          | just-lsp   | just --fmt                | workstation CLI |
| Lua      | LuaJIT (homebrew)      | lua_ls     | conform → stylua          | nvim config     |
| Python   | mise (`python@latest`) | pyright    | ruff                      | dev             |
| JS/TS    | node                   | ts_ls      | prettier                  | dev             |
| Astro    | node                   | astro-ls   | LSP fallback              | dev             |
| ReScript | node                   | rescriptls | conform → rescript-format | dev             |
| SQL      | —                      | sqls       | —                         | dev             |
