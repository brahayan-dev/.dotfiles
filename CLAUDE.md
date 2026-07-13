# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

| Command           | work | life | linux | handler                        |
| ----------------- | :--: | :--: | :---: | ------------------------------ |
| `setup`           |  ●   |  ●   |   ●   | `systems/library/ansible.fnl`  |
| `ping`            |  ●   |  ●   |   ●   | `systems/library/ansible.fnl`  |
| `install scala`   |  ●   |  ·   |   ·   | `systems/library/interactive.fnl` |
| `connect github`  |  ·   |  ●   |   ●   | `systems/library/interactive.fnl` |
| `refresh nu`      |  ●   |  ·   |   ·   | `systems/library/work.fnl`     |

- `setup` runs the Ansible playbook for the host's environment (`library/ansible.fnl:setup`).
- `ping` runs `ansible -m ping` against localhost as a sanity check (`library/ansible.fnl:ping`).
- `install <lang>` installs a toolchain (scala) via coursier (`library/interactive.fnl:install-scala`).
- `connect github` authenticates with GitHub (SSH key + token + origin) (`library/interactive.fnl:connect-github`).
- `refresh nu` runs the seven-step Nu refresh sequence (`library/work.fnl:bom-dia`, work only).

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
    work.fnl                   bom-dia  (Nu refresh sequence)

  macos/ansible.cfg            Darwin ansible config (python3, roles_path)
  linux/
    ansible.cfg                Linux ansible config
    playbook.yml               Linux setup playbook
    CLAUDE.md                  Linux env docs (symlinked to ~/.claude/CLAUDE.md)
  life/
    playbook.yml               macOS-life setup playbook
    CLAUDE.md                  life env docs
  work/
    playbook.yml               macOS-work setup playbook
    CLAUDE.md                  work env docs

roles/                         ansible roles: common, macos, life, work, linux
files/                         managed dotfiles (symlinked into $HOME / ~/.config)
```

### Ansible

Playbooks run against `localhost` via `hosts.ini`. The Fennel dispatcher sets `ANSIBLE_CONFIG=systems/macos/ansible.cfg` (Darwin) or `ANSIBLE_CONFIG=systems/linux/ansible.cfg` (Linux), picks the playbook by host signal (`work`/`life`/`linux`), and passes `systems/.vault_` and `systems/.become_` as password files. The `common` role creates directories (`~/.ssh`, `~/.config`, `~/.claude`), installs `fennel` + `fennel-ls`, symlinks nvim/.zprofile/.zshrc, and installs global npm packages. Environment-specific roles add their own packages and symlinks.

`roles_path = ../../roles` in each `ansible.cfg` is relative to the `.cfg` location; ansible resolves it back to the repo's top-level `roles/` directory.

### Neovim

Plugin manager: lazy.nvim. Leader: Space, local leader: comma. Config split across `init.lua` → `settings.lua` + `keymaps.lua` + `plugins/`. Each plugin is a separate file returning a lazy spec table.

LSP uses the new `vim.lsp.config`/`vim.lsp.enable` API (not the old `lspconfig.setup`), plus nvim-metals for Scala. Configured LSPs: basedpyright, ruff, lua_ls, sqls, ts_ls, yamlls, bashls, jsonls, tofu_ls, ansiblels, clojure_lsp, Metals, **fennel_ls**. Formatting is handled by conform.nvim (ruff_format for Python, stylua for Lua, cljfmt for Clojure, **fnlfmt for Fennel**, LSP fallback for others). LSP provides diagnostics and code actions. Python and Scala organize imports on save.

Treesitter parsers: lua, sql, css, bash, yaml, json, html, python, scala, clojure, javascript, embedded_template, **fennel**. Completion via nvim-cmp with LuaSnip and cmp-nvim-lsp. Paredit is enabled for `clojure` and `fennel` filetypes.

**Migration plan:** the Neovim config is on track to be rewritten in Fennel (`files/nvim/init.lua` and `lua/plugins/*.lua` → Fennel). The substrate (`fennel_ls`, `fnlfmt`, `treesitter-fennel`, `paredit`) is already wired.

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
- The Fennel command registry in `systems/core.fnl` is the source of truth for which command runs in which environment. Update both `systems/core.fnl` and `CLAUDE.md` together when changing it.
- Gating logic lives in `systems/library/logic.fnl` (`allowed?` + `dispatch`); keep it side-effect-free.
- Host signal (OS name + `~/.nurc` presence) resolves to a Fennel keyword (`:work` / `:life` / `:linux`) in `systems/library/common.fnl`.
- Use `prettier . --write` to format Markdown files, `stylua .` for Lua, `ruff . --fix` for Python, and `fnlfmt` for Fennel (handled by `conform.nvim` in the editor).
- Don't write comments. If you do, keep them brief.

## Direction

End state: Fennel + sh across the board, including the Neovim config. Remaining work:

- Rewrite `files/nvim/init.lua` and `files/nvim/lua/plugins/*.lua` in Fennel.
