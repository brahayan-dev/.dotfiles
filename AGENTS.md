# AGENTS.md

This file provides guidance to opencode and other AI coding agents working in this repository.

## Architecture

Multi-environment dotfiles repository. A small Fennel entrypoint (`systems/core.fnl`) dispatches to environment-specific Ansible playbooks that deploy configs via symlinks from `~/.dotfiles/files/` into `$HOME` and `~/.config/`.

### Environments

Two environments, derived at runtime in `systems/library/common.fnl` from `os-name` (`uname -s`):

- **life** (macOS, default) — Personal dev: SSH, git, Ruby toolchain (mise + RuboCop/Ruby LSP via `install ruby`), Python runtime (mise via `install python`), Elm and JS toolchains (npm globals), API tokens (`GITHUB_TOKEN`, `ANTHROPIC_API_KEY`)
- **linux** (pacman-based Linux) — Same tooling as life (Ruby, Python, Elm and JS) with Linux-specific packages

### Entry Point

```
./workstation <command> [entity]
```

The `workstation` shell script detects the OS to bootstrap deps (`fennel` + `ansible` via brew/pacman), then `exec`s `fennel systems/core.fnl "$@"`. From there, all dispatch lives in Fennel; the versioned toolchains come from mise — Ruby 4 via `install ruby`, Python via `install python`.

### Commands

The command registry is the `register` function in `systems/core.fnl`. Each entry pairs a handler with an `:allowed-on` value (`:all` — only life and linux remain).

| Command            | life | linux |
| ------------------ | :--: | :---: |
| `ping`             |  ●   |   ●   |
| `setup`            |  ●   |   ●   |
| `install ruby`     |  ●   |   ●   |
| `install python`   |  ●   |   ●   |
| `connect github`   |  ●   |   ●   |
| `generate aliases` |  ●   |   ●   |

- `setup` runs the Ansible playbook for the host's environment (`library/ansible.fnl:setup`).
- `ping` runs `ansible -m ping` against localhost as a sanity check (`library/ansible.fnl:ping`).
- `install ruby` installs Ruby via mise (`mise use -g ruby@4`) then the RuboCop, Ruby LSP and htmlbeautifier gems under the mise Ruby (`mise x -- gem install ... --no-document`) (`library/interactive.fnl:install-ruby`, **life and linux only** — mise ships in those roles).
- `install python` installs the Python runtime via mise (`mise use -g python@latest`) (`library/interactive.fnl:install-python`). The pyright LSP and ruff formatter ship as global deps (npm), not under the mise Python.
- `connect github` authenticates with GitHub (SSH key + token + origin) (`library/interactive.fnl:connect-github`).
- `generate aliases` emits shell `cd`/`nvim` aliases for known repositories in `~/.dotfiles`, `~/Projects` (`library/repository.fnl:generate-aliases`).

When a command is run in an environment not in its `:allowed-on` list, `systems/library/logic.fnl`'s `dispatch` exits silently without invoking the handler.

### Directory Structure

```
workstation                    bash entry · OS detection · dep bootstrap
systems/
  core.fnl                     entrypoint + register table
  hosts.ini                    ansible inventory (Workstation → localhost)
  .vault_ .become_             vault and become password files (gitignored)

  library/                     Fennel libraries
    common.fnl                 os-name · environment · run
    logic.fnl                  allowed-on · dispatch  (gating primitive)
    ansible.fnl                ping · setup
    interactive.fnl            install ruby · install python · connect github
    repository.fnl             generate aliases

  life/
    ansible.cfg                Darwin ansible config (python3, roles_path)
    playbook.yml               macOS-life setup playbook
    AGENTS.md                  life env docs (symlinked to ~/.config/opencode/AGENTS.md)
  linux/
    ansible.cfg                Linux ansible config
    playbook.yml               Linux setup playbook
    AGENTS.md                  Linux env docs (symlinked to ~/.config/opencode/AGENTS.md)

roles/                         ansible roles: common, macos, life, linux
files/                         managed dotfiles (symlinked into $HOME / ~/.config)
```

### Ansible

Playbooks run against `localhost` via `hosts.ini`. The Fennel dispatcher sets `ANSIBLE_CONFIG=systems/life/ansible.cfg` (Darwin) or `ANSIBLE_CONFIG=systems/linux/ansible.cfg` (Linux), picks the playbook by host signal (`life`/`linux`), and passes `systems/.vault_` and `systems/.become_` as password files. The `common` role creates directories (`~/.ssh`, `~/.config`, `~/.config/ghostty`), installs `fennel` + `fennel-ls`, symlinks nvim/.zprofile/.zshrc, and installs global npm packages. Environment-specific roles create their own config directories (`~/.config/opencode` on life/linux) and add their own packages and symlinks. The `macos` role (Darwin) installs the shared Homebrew base.

`roles_path = ../../roles` in each `ansible.cfg` is relative to the `.cfg` location; ansible resolves it back to the repo's top-level `roles/` directory.

### Neovim

Plugin manager: lazy.nvim. Leader: Space, local leader: comma.

Source of truth is Fennel under `files/nvim/fnl/` (`settings.fnl` + `mappings.fnl` + `plugins/*.fnl`); the `lua/` tree is generated by nfnl on save and is gitignored (only `lua/plugins.lua` is committed as the bootstrap). `settings.fnl` defines vim options and explicitly invokes `(mappings.general)`, `(mappings.window)`, `(mappings.lsp)` so the keymaps are actually registered. `mappings.fnl` exports functions `general`, `window`, `lsp`, `telescope`, `oil`, `autocomplete`.

LSP uses the new `vim.lsp.config`/`vim.lsp.enable` API (not the old `lspconfig.setup`). Configured LSPs: html, sqls, ts_ls, lua_ls, yamlls, bashls, jsonls, tofu_ls, ansiblels, ruby_lsp, elm_ls, pyright, **fennel_ls**. Formatting is handled by conform.nvim (stylua for Lua, **fnlfmt for Fennel**, rubocop for Ruby, htmlbeautifier for ERB, prettier for JSON/markdown/JS/TS, ruff for Python, elm-format for Elm, LSP fallback for others). LSP provides diagnostics and code actions.

Treesitter parsers: lua, sql, css, bash, yaml, json, html, ruby, javascript, typescript, embedded_template, python, elm, **fennel**. ERB is covered by `embedded_template` plus the `html` tree registered for `mustache`. Completion via nvim-cmp with LuaSnip and cmp-nvim-lsp. Paredit is enabled for `fennel`.

#### Fennel gotchas

These cost real time during the migration, watch for them:

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
8. **`os.execute` returns tuples with different shapes per Lua** — 5.5 gives `(ok kind code)` and LuaJIT a single code; destructure with `(let [(ok _ code) ...] ...)` and treat `ok` as the only signal (fail-fast in `common.fnl`).

### Profile System

`.zprofile` sources up to three profile files in order: `~/.life_profile`, `~/.linux_profile`, `~/.private_profile`. Life and linux profiles are symlinked by Ansible; `.private_profile` is written in-place by Ansible using `lineinfile`. Profiles contain environment variables, PATH entries, and project aliases. Profiles carry the environment-specific tool setup: direnv hook, brew shellenv and `~/.local/bin` plus mise activation on life; direnv hook, opencode and mise activation on linux. `.zshrc` has no environment gating.

### Secrets

Ansible Vault encrypts `roles/life/vars/main.yml` and `roles/linux/vars/main.yml`. API tokens (GITHUB_TOKEN, ANTHROPIC_API_KEY) are written to `~/.private_profile` by the life role.

## Key Conventions

- Ansible task names use Title Case (e.g., `Install Dependencies`).
- Config deployment is always via symlinks — never copy files into `$HOME`.
- Ghostty has three configs: `built-in` (all macOS), `external` (unused), `linux`.
- Each environment's `systems/<env>/AGENTS.md` (life, linux) is symlinked into `~/.config/opencode/AGENTS.md` respectively by its corresponding role.
- The `workstation` script must be run from the repo root (`~/.dotfiles/`).
- The Fennel command registry in `systems/core.fnl` is the source of truth for which command runs in which environment. Update both `systems/core.fnl` and `AGENTS.md` together when changing it.
- Gating logic lives in `systems/library/logic.fnl` (`allowed?` + `dispatch`); keep it side-effect-free.
- Host signal (`uname -s`) resolves to a Fennel keyword (`:life` / `:linux`) in `systems/library/common.fnl`.
- Use `prettier . --write` to format Markdown files, `stylua .` for Lua, `ruff check --fix` for Python, and `fnlfmt` for Fennel (handled by `conform.nvim` in the editor).

## Direction

End state: Fennel + sh across the board. The Neovim config is fully in Fennel under `files/nvim/fnl/`. Remaining work lives in systems/library/ if Ansible playbooks grow.
