# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

Multi-environment dotfiles repository. A small Go CLI dispatches to environment-specific Ansible playbooks that deploy configs via symlinks from `~/.dotfiles/files/` into `$HOME` and `~/.config/`.

### Environments

Three environments, gated at runtime by host signal (`runtime.GOOS` + `~/.nurc`):

- **work** (macOS, triggered by `~/.nurc` existing) — Clojure toolchain, Nu infrastructure
- **life** (macOS, default) — Personal dev: SSH, git, API tokens, claude-code cask
- **linux** (pacman-based Linux) — Similar to life with Linux-specific packages

### Entry Point

```
./workstation <command> [entity]
```

The `workstation` shell script detects the OS to bootstrap deps (ansible + go via brew/pacman), then `exec`s `go run systems/main.go "$@"`. From there, all dispatch lives in Go.

### Commands

The command registry is a `map[string]Entry` at the top of `systems/main.go`. Each entry pairs a handler function with a list of allowed environments.

| Command           | work | life | linux |
| ----------------- | :--: | :--: | :---: |
| `setup`           |  ●   |  ●   |   ●   |
| `ping`            |  ●   |  ●   |   ●   |
| `install scala`   |  ●   |  ·   |   ·   |
| `install clojure` |  ●   |  ·   |   ·   |
| `connect github`  |  ·   |  ●   |   ●   |
| `refresh nu`      |  ●   |  ·   |   ·   |

- `setup` runs the Ansible playbook for the host's environment
- `ping` runs `ansible -m ping` against localhost as a sanity check
- `install <lang>` installs a toolchain (scala or clojure) via coursier
- `connect github` authenticates with GitHub (SSH key + token + origin)
- `refresh nu` refreshes Nu work credentials (work only)

When a command is run on an environment that is not in its `Environments` list, the dispatcher exits 0 silently.

### Directory Structure

```
workstation                  bash entry · OS detection · dep bootstrap
systems/
  main.go                    entrypoint + command registry (map[string]Entry)
  hosts.ini                  ansible inventory (Workstation → localhost)
  .vault_ .become_           vault and become password files (gitignored)
  command/
    guard.go                 Allowed(envs, os, marked) and Valid(action, entity, args)
    guard_test.go            table-driven tests for the env-gating logic
  ansible/ansible.go         Ping() and Setup() — wrap ansible/ansible-playbook
  github/connect.go          Connect() — origin, gh auth, refresh, ssh-key
  language/install.go        Install(tool) — dispatches to scala/clojure installers
  work/bom_dia.go            BomDia() — orchestrates the work-only `refresh nu` flow
  macos/ansible.cfg          Darwin ansible config (python3, roles_path)
  linux/
    ansible.cfg              Linux ansible config
    playbook.yml             Linux setup playbook
    CLAUDE.md                Linux env docs (symlinked to ~/.claude/CLAUDE.md)
  life/
    playbook.yml             macOS-life setup playbook
    CLAUDE.md                life env docs
  work/
    playbook.yml             macOS-work setup playbook
    CLAUDE.md                work env docs
roles/                       ansible roles: common, macos, life, work, linux
files/                       managed dotfiles (symlinked into $HOME / ~/.config)
```

### Ansible

Playbooks run against `localhost` via `hosts.ini`. The Go dispatcher sets `ANSIBLE_CONFIG=systems/macos/ansible.cfg` (Darwin) or `ANSIBLE_CONFIG=systems/linux/ansible.cfg` (Linux), picks the playbook by host signal (`work`/`life`/`linux`), and passes `systems/.vault_` and `systems/.become_` as password files. The `common` role creates directories (`~/.ssh`, `~/.config`, `~/.claude`), symlinks nvim/.zprofile/.zshrc, and installs mise + global npm packages. Environment-specific roles add their own packages and symlinks.

`roles_path = ../../roles` in each `ansible.cfg` is relative to the `.cfg` location; ansible resolves it back to the repo's top-level `roles/` directory.

### Neovim

Plugin manager: lazy.nvim. Leader: Space, local leader: comma. Config split across `init.lua` → `settings.lua` + `keymaps.lua` + `plugins/`. Each plugin is a separate file returning a lazy spec table.

LSP uses the new `vim.lsp.config`/`vim.lsp.enable` API (not the old `lspconfig.setup`), plus nvim-metals for Scala. Configured LSPs: basedpyright, ruff, lua_ls, sqls, ts_ls, yamlls, bashls, jsonls, tofu_ls, ansiblels, clojure_lsp, Metals. Formatting is handled by conform.nvim (ruff_format for Python, stylua for Lua, cljfmt for Clojure, LSP fallback for others). LSP provides diagnostics and code actions. Python and Scala organize imports on save.

Treesitter parsers: lua, sql, css, bash, yaml, json, html, python, scala, clojure, javascript, embedded_template. Completion via nvim-cmp with LuaSnip and cmp-nvim-lsp. Copilot integration via copilot.lua.

### Profile System

`.zprofile` sources up to four profile files in order: `~/.life_profile`, `~/.work_profile`, `~/.linux_profile`, `~/.private_profile`. Life, work, and linux profiles are symlinked by Ansible; `.private_profile` is written in-place by Ansible using `lineinfile`. Profiles contain environment variables, PATH entries, and project aliases. The `work` profile adds Nu/Flutter/Python/Ruby/Go/Node/Coursier paths.

### Secrets

Ansible Vault encrypts `roles/life/vars/main.yml` and `roles/linux/vars/main.yml`. API tokens (GITHUB_TOKEN, GEMINI_API_KEY, ANTHROPIC_API_KEY) are written to `~/.private_profile` by the life role.

## Key Conventions

- Ansible task names use Title Case (e.g., `Install Dependencies`, `Configure Luarocks For LuaJIT`).
- Config deployment is always via symlinks — never copy files into `$HOME`.
- Ghostty has three configs: `built-in` (all macOS), `external` (unused), `linux`.
- Each environment's `systems/<env>/CLAUDE.md` is symlinked to `~/.claude/CLAUDE.md` by its corresponding role.
- The `workstation` script must be run from the repo root (`~/.dotfiles/`).
- The Go command registry is the source of truth for which command runs in which environment. Update both `systems/main.go` and `CLAUDE.md` together when changing it.
- `systems/command/guard.go` holds the pure gating logic (`Allowed`, `Valid`) — keep it side-effect-free so `guard_test.go` can cover it with `go test ./systems/command/...`.
- `systems/command/guard.go`'s `Allowed` expects the OS name in TitleCase (`"Darwin"`, `"Linux"`), matching the Go `runtime.GOOS` values after normalization. `systems/main.go`'s `osName()` normalizes `runtime.GOOS` to TitleCase before passing it in.
- Use `prettier . --write` to format Markdown files, `stylua .` for Lua, and `ruff . --fix` for Python.
- Don't write comments. If you do, keep them brief.
