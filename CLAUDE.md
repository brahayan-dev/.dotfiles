# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

Multi-environment dotfiles repository with a Lua CLI layer on top of Ansible. Deploys configs via symlinks from `~/.dotfiles/files/` into `$HOME` and `~/.config/`.

### Environments

Three environments auto-detected by the `workstation` entry script:
- **work** (macOS, triggered by `~/.nurc` existing) — Clojure toolchain, Doom Emacs, Nu infrastructure
- **life** (macOS, default) — Personal dev: SSH, git, API tokens, claude-code cask
- **linux** (pacman-based Linux) — Similar to life with Linux-specific packages

### Entry Point

```
./workstation <command> [entity]
```

The `workstation` script bootstraps ansible+lua, then delegates to `systems/<env>.lua`.

### Commands per environment

| Command | work | life | linux |
|---------|------|------|-------|
| `setup`  | yes | yes | yes |
| `ping`   | yes | yes | yes |
| `install`| yes | yes | yes |
| `connect`| no  | yes | yes |
| `refresh`| yes | no  | no   |

- `setup` runs the Ansible playbook for the environment
- `install <language>` runs a language toolchain installer (python, lua)
- `connect github` authenticates with GitHub (SSH key + token)
- `refresh nu` refreshes Nu work credentials (work only)

### Directory Structure

- `workstation` — Shell entry point (OS detection, dependency bootstrap)
- `systems/` — Lua CLI entry points (`<env>.lua`), Ansible configs/playbooks (`<env>.cfg`, `<env>.yml`), shared library (`library/`)
- `systems/library/common.lua` — `shell()` (table→string→os.execute) and `set_ansible_cfg()`
- `systems/library/interactive.lua` — Command dispatch: `install`, `connect`, `ping`, `setup`
- `systems/library/language.lua` — Language toolchain installers
- `systems/library/work.lua` — Work-specific `refresh` command for Nu infrastructure
- `roles/` — Ansible roles: common (all), macos (brew), work, life, linux
- `files/` — Managed dotfiles: nvim, ghostty, doom, emacs-plus, .zshrc, .zprofile, profiles

### Ansible

Playbooks run against `localhost` via `hosts.ini`. Vault and become passwords stored in `systems/.vault_` and `systems/.become_` (gitignored). The common role creates directories (`~/.ssh`, `~/.config`, `~/.claude`), symlinks nvim/.zprofile/.zshrc, and installs mise + global npm packages. Environment-specific roles add their own packages and symlinks.

### Neovim

Plugin manager: lazy.nvim. Leader: Space, local leader: comma. Config split across `init.lua` → `settings.lua` + `keymaps.lua` + `plugins/`. Each plugin is a separate file returning a lazy spec table. LSP uses the new `vim.lsp.config`/`vim.lsp.enable` API (not the old `lspconfig.setup`). Formatting is handled by conform.nvim (ruff for Python, stylua for Lua). LSP provides diagnostics and code actions. Python organizes imports on save via basedpyright.

### Profile System

`.zprofile` sources up to four profile files in order: `~/.life_profile`, `~/.work_profile`, `~/.linux_profile`, `~/.private_profile`. Profiles are symlinked by Ansible and contain environment variables, PATH entries, and project aliases. The `work` profile adds Nu/Flutter/Python/Ruby/Go/Node/Clojure paths.

### Secrets

Ansible Vault encrypts `roles/life/vars/main.yml` and `roles/linux/vars/main.yml`. API tokens (GITHUB_TOKEN, GEMINI_API_KEY, ANTHROPIC_API_KEY) are written to `~/.private_profile` by the life role.

## Key Conventions

- Ansible task names use Title Case (e.g., `Install Dependencies`, `Configure Luarocks For LuaJIT`)
- Config deployment is always via symlinks — never copy files into `$HOME`
- Ghostty has three configs: `built-in` (work macOS), `external` (personal macOS), `linux`
- Each environment's CLAUDE.md is symlinked to `~/.claude/CLAUDE.md`
- The `workstation` script must be run from the repo root (`~/.dotfiles/`)
- Language installers in `language.lua` use `mise` for Python, `pip` for basedpyright/debugpy/ruff/pytest, `luarocks` for busted/cjson/luaossl
- `systems/library/common.lua` `shell()` joins a table with spaces and calls `os.execute` — arguments with spaces need quoting