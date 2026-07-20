# AGENTS.md

This file provides guidance to opencode and other AI coding agents working in this repository.

## Architecture

Multi-environment dotfiles repository. A small Fennel entrypoint (`systems/core.fnl`) dispatches to environment-specific Ansible playbooks that deploy configs via symlinks from `~/.dotfiles/files/` into `$HOME` and `~/.config/`.

### Environments

Three environments, derived at runtime in `systems/library/common.fnl` from `os-name` (`uname -s`) and `working-day?` (`~/.nurc` presence):

- **work** (macOS + `~/.nurc`) — Clojure toolchain, Nu infrastructure
- **life** (macOS, default) — Personal dev: SSH, git, API tokens, claude-code cask
- **linux** (pacman-based Linux) — Similar to life with Linux-specific packages

### Entry Point

```
./workstation <command> [entity]
```

The `workstation` shell script detects the OS to bootstrap deps (`fennel` + `ansible` via brew/pacman), then `exec`s `fennel systems/core.fnl "$@"`. From there, all dispatch lives in Fennel.

### Commands

The command registry is the `register` function in `systems/core.fnl`. Each entry pairs a handler with an `:allowed-on` list (`:all`, `:work`, or `[:life :linux]`).

| Command            | work | life | linux | handler                           |
| ------------------ | :--: | :--: | :---: | --------------------------------- |
| `setup`            |  ●   |  ●   |   ●   | `systems/library/ansible.fnl`     |
| `ping`             |  ●   |  ●   |   ●   | `systems/library/ansible.fnl`     |
| `install scala`    |  ●   |  ·   |   ·   | `systems/library/interactive.fnl` |
| `connect github`   |  ·   |  ●   |   ●   | `systems/library/interactive.fnl` |
| `refresh nu`       |  ●   |  ·   |   ·   | `systems/library/work.fnl`        |
| `generate aliases` |  ●   |  ●   |   ●   | `systems/library/repository.fnl`  |

- `setup` runs the Ansible playbook for the host's environment (`library/ansible.fnl:setup`).
- `ping` runs `ansible -m ping` against localhost as a sanity check (`library/ansible.fnl:ping`).
- `install <lang>` installs a toolchain (scala) via coursier (`library/interactive.fnl:install-scala`).
- `connect github` authenticates with GitHub (SSH key + token + origin) (`library/interactive.fnl:connect-github`).
- `refresh nu` runs the five-step Nu refresh sequence (`library/work.fnl:bom-dia`, work only).
- `generate aliases` emits shell `cd`/`nvim` aliases for known repositories in `~/.dotfiles`, `~/Projects`, and (on work) `~/dev/nu` (`library/repository.fnl:generate-aliases`).

When a command is run in an environment not in its `:allowed-on` list, `systems/library/logic.fnl`'s `dispatch` exits silently without invoking the handler.

### Directory Structure

```
workstation                    bash entry · OS detection · dep bootstrap
systems/
  core.fnl                     entrypoint + register table
  hosts.ini                    ansible inventory (Workstation → localhost)
  .vault_ .become_             vault and become password files (gitignored)

  library/                     Fennel libraries
    common.fnl                 os-name · working-day? · environment · run
    logic.fnl                  allowed? · dispatch  (gating primitive)
    ansible.fnl                ping · setup
    interactive.fnl            install-scala · connect-github
    repository.fnl             generate-aliases
    work.fnl                   bom-dia  (Nu refresh sequence)

  macos/ansible.cfg            Darwin ansible config (python3, roles_path)
  linux/
    ansible.cfg                Linux ansible config
    playbook.yml               Linux setup playbook
    AGENTS.md                  Linux env docs (symlinked to ~/.config/opencode/AGENTS.md)
  life/
    playbook.yml               macOS-life setup playbook
    AGENTS.md                  life env docs (symlinked to ~/.config/opencode/AGENTS.md)
  work/
    playbook.yml               macOS-work setup playbook
    CLAUDE.md                  work env docs (symlinked to ~/.claude/CLAUDE.md)

roles/                         ansible roles: common, macos, life, work, linux
files/                         managed dotfiles (symlinked into $HOME / ~/.config)
```

### Ansible

Playbooks run against `localhost` via `hosts.ini`. The Fennel dispatcher sets `ANSIBLE_CONFIG=systems/macos/ansible.cfg` (Darwin) or `ANSIBLE_CONFIG=systems/linux/ansible.cfg` (Linux), picks the playbook by host signal (`work`/`life`/`linux`), and passes `systems/.vault_` and `systems/.become_` as password files. The `common` role creates directories (`~/.ssh`, `~/.config`, `~/.claude`, `~/.config/opencode`), installs `fennel` + `fennel-ls`, symlinks nvim/.zprofile/.zshrc, and installs global npm packages. Environment-specific roles add their own packages and symlinks.

`roles_path = ../../roles` in each `ansible.cfg` is relative to the `.cfg` location; ansible resolves it back to the repo's top-level `roles/` directory.

### Neovim

Plugin manager: lazy.nvim. Leader: Space, local leader: comma.

Source of truth is Fennel under `files/nvim/fnl/` (`settings.fnl` + `mappings.fnl` + `plugins/*.fnl`); the `lua/` tree is generated by nfnl on save and is gitignored (only `lua/plugins.lua` is committed as the bootstrap). `settings.fnl` defines vim options and explicitly invokes `(mappings.general)`, `(mappings.window)`, `(mappings.lsp)` so the keymaps are actually registered. `mappings.fnl` exports a module `(local M {})` with functions `M.general`, `M.window`, `M.lsp`, `M.telescope`, `M.oil`, `M.autocomplete`.

LSP uses the new `vim.lsp.config`/`vim.lsp.enable` API (not the old `lspconfig.setup`), plus nvim-metals for Scala. Configured LSPs: sqls, ts_ls, lua_ls, yamlls, bashls, jsonls, tofu_ls, ansiblels, clojure_lsp, Metals, **fennel_ls**. Formatting is handled by conform.nvim (stylua for Lua, **fnlfmt for Fennel**, cljfmt for Clojure, prettier for JSON/markdown, LSP fallback for others). LSP provides diagnostics and code actions.

Treesitter parsers: lua, sql, css, bash, yaml, json, html, scala, clojure, javascript, embedded_template, **fennel**. Completion via nvim-cmp with LuaSnip and cmp-nvim-lsp. Paredit is enabled for `clojure` and `fennel` filetypes.

#### Fennel style

Fennel conventions for the Neovim config. Use these for any new `.fnl` file.

Standards observed in `files/nvim/fnl/` (use these for any new `.fnl` file):

- 2-space indentation (matches `stylua`).
- Destructure with keywords: `(local {: setup} (require :foo))`.
- Top-level `(local ...)` for data tables and for `require` of in-repo modules (`:mappings`, `:nfnl.module`) only. **Do not** `require` lazy plugins at the top of a spec file — they are not on the runtimepath when lazy loads the spec.
- Assignment: `(set t.field val)` works even when `field` contains `/`, `-`, `#`, `.`, or other special characters — Fennel compiles that segment to bracket-string indexing automatically (e.g. `(set vim.g.conjure#mapping#doc_word :K)` compiles to `vim.g["conjure#mapping#doc_word"] = "K"`). Reach for `tset` only when the key is computed at runtime rather than a static symbol chain, or to patch several nested keys in one call.
- `:config` may use `#()` short lambdas or `(fn [] ...)`; nfnl compiles `#(a b c)` to a function that runs all statements and returns the last, so multi-statement bodies are safe. Prefer `#()` for single-expression bodies and `(fn [] ...)` when you want the multi-statement form to be visually distinct.
- Method calls on a freshly-required module need a double paren: `((. (require :foo) :method) args)`. `((require :foo) :method args)` compiles to a broken call.
- Property access: `(. tbl :field)`. Function call on a value: `(. obj :method args)`.
- Blocks: `(let [bindings...] body)`, `(when c ...)`, `(each [_ v (ipairs t)] ...)`, `(.. "a" b "c")`.
- No comments. If a comment is unavoidable, keep it to one short line.
- Format with `fnlfmt --fix <file>`. The formatter rewrites strings to keywords (and vice versa) and rewraps forms — let it, don't fight it.

Gotchas — these cost real time during the migration, watch for them:

1. **Top-level `require` of a lazy plugin fails** with `module 'X' not found` when lazy loads the spec. The plugin is not on the runtimepath yet. Move the `require` inside the `:config` lambda, or declare the spec with `:dependencies` so lazy loads it first.
2. **`cmp_nvim_lsp.default_capabilities` is a function, not a value.** Pass the result of calling it (`(require :cmp_nvim_lsp).default_capabilities()`), not the field. Otherwise `vim.tbl_deep_extend` raises `expected table, got function`.
3. **Never drop the leading `:` on a keyword.** A keyword like `:.git/` or `:ui-select` always compiles to the string `".git/"` / `"ui-select"`, special characters included — there's no need to write it as a quoted string. The real danger is _omitting_ the colon: a bare symbol like `ui-select` (no `:`) compiles to a reference to an undefined global variable instead of a string, and silently breaks lookups.
4. **Wildcard LSP config** — `(vim.lsp.config "*" {...})` applies to every LSP. When it touches `capabilities`, wrap the value in a function so it is computed lazily (otherwise `cmp_nvim_lsp` is required at load time and may not be ready).
5. **Empty function body** — `(fn [])` does not compile. Use `(fn [] nil)`.
6. **Keymaps defined in `mappings.fnl` are not registered automatically.** `M.general` etc. are just functions; `settings.fnl` must call them. Forgetting this silently breaks `<leader>q` and friends.
7. **Compiling outside a fennel buffer** — nfnl's ftplugin only triggers on buffer open. To compile a single file from a script or `--headless`:
   ```
   nvim --headless -c "lua require('nfnl.api')['compile-file']({ path = './fnl/x.fnl' })" -c "qa!"
   ```

### Profile System

`.zprofile` sources up to four profile files in order: `~/.life_profile`, `~/.work_profile`, `~/.linux_profile`, `~/.private_profile`. Life, work, and linux profiles are symlinked by Ansible; `.private_profile` is written in-place by Ansible using `lineinfile`. Profiles contain environment variables, PATH entries, and project aliases. The `work` profile adds Nu/Flutter/Python/Ruby/Go/Node/Coursier paths.

### Secrets

Ansible Vault encrypts `roles/life/vars/main.yml` and `roles/linux/vars/main.yml`. API tokens (GITHUB_TOKEN, GEMINI_API_KEY, ANTHROPIC_API_KEY) are written to `~/.private_profile` by the life role.

## Key Conventions

- Ansible task names use Title Case (e.g., `Install Dependencies`, `Configure Luarocks For LuaJIT`).
- Config deployment is always via symlinks — never copy files into `$HOME`.
- Ghostty has three configs: `built-in` (all macOS), `external` (unused), `linux`.
- Each environment's `systems/<env>/AGENTS.md` (life, linux) or `systems/<env>/CLAUDE.md` (work) is symlinked into `~/.config/opencode/AGENTS.md` or `~/.claude/CLAUDE.md` respectively by its corresponding role.
- The `workstation` script must be run from the repo root (`~/.dotfiles/`).
- The Fennel command registry in `systems/core.fnl` is the source of truth for which command runs in which environment. Update both `systems/core.fnl` and `AGENTS.md` together when changing it.
- Gating logic lives in `systems/library/logic.fnl` (`allowed?` + `dispatch`); keep it side-effect-free.
- Host signal (OS name + `~/.nurc` presence) resolves to a Fennel keyword (`:work` / `:life` / `:linux`) in `systems/library/common.fnl`.
- Use `prettier . --write` to format Markdown files, `stylua .` for Lua, `ruff . --fix` for Python, and `fnlfmt` for Fennel (handled by `conform.nvim` in the editor).
- Don't write comments. If you do, keep them brief.

## Direction

End state: Fennel + sh across the board. The Neovim config is now fully in Fennel under `files/nvim/fnl/`. Remaining work lives in `systems/library/` if Ansible playbooks grow.
