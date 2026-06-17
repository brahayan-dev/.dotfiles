# Life Environment

## Language Preferences

- When writing in Spanish, use Mexican (MX) or Colombian (CO) Spanish — never Argentine (AR) Spanish.
- Write all code, comments, and documentation in English, even if the prompt is in another language.

## Language Stack

| Language | Runtime | LSP | Formatter | DAP | Test Runner |
|----------|---------|-----|-----------|-----|-------------|
| Python | mise python@3 | basedpyright + ruff | conform → ruff | debugpy | neotest (pytest) |
| Lua | LuaJIT (homebrew) | lua_ls | conform → stylua | local-lua-debugger | neotest (busted) |

### Install commands

```
./workstation install python   # mise use -g python@3 + pip install basedpyright debugpy ruff pytest
./workstation install lua      # luarocks install busted cjson luaossl
```