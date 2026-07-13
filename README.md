# `~/.dotfiles`

Multi-environment dotfiles repository. A small Fennel entrypoint (`systems/core.fnl`) dispatches to environment-specific Ansible playbooks that deploy configs via symlinks from `~/.dotfiles/files/` into `$HOME` and `~/.config/`.

```
$ git clone <repo> ~/.dotfiles
$ cd ~/.dotfiles
$ ./workstation setup
```

## §0 · bootstrap

```
$ ./workstation setup
```

The `workstation` shell script detects the OS, installs `fennel` and `ansible` if missing (brew on macOS, pacman on Linux), then `exec`s `fennel systems/core.fnl "$@"`. All dispatch lives in Fennel from that point on.

## §1 · environments

Three environments, partitioned by host signal (see `systems/library/common.fnl`):

| env     | host signal              | toolchain                                  |
| ------- | ------------------------ | ------------------------------------------ |
| `work`  | macOS, `~/.nurc` exists  | Scala, Clojure, Nu infrastructure          |
| `life`  | macOS, default           | Personal dev (SSH, git, API tokens)        |
| `linux` | Linux, `pacman` detected | Similar to `life` with Linux-specific pkgs |

Intersection — what every environment inherits:

```
work ∩ life ∩ linux = { Fennel, Neovim, Claude Code, zsh, ~/.config }
```

## §2 · commands

The dispatcher is the `register` function in `systems/core.fnl`. Each entry pairs a handler with an `:allowed-on` list (`:all`, `:work`, or `[:life :linux]`).

| command           | work | life | linux | handler                        |
| ----------------- | :--: | :--: | :---: | ------------------------------ |
| `setup`           |  ●   |  ●   |   ●   | `systems/library/ansible.fnl`  |
| `ping`            |  ●   |  ●   |   ●   | `systems/library/ansible.fnl`  |
| `install scala`   |  ●   |  ·   |   ·   | `systems/language/install.go` _(deprecated Go)_ |
| `install clojure` |  ●   |  ·   |   ·   | `systems/language/install.go` _(deprecated Go)_ |
| `connect github`  |  ·   |  ●   |   ●   | `systems/github/connect.go` _(deprecated Go)_ |
| `refresh nu`      |  ●   |  ·   |   ·   | `systems/library/work.fnl`     |

```
setup    ──▶  run the ansible playbook for the host
ping     ──▶  ansible -m ping (sanity check)
install  ──▶  install a language toolchain (scala or clojure)
connect  ──▶  authenticate with the remote forge (github only, today)
refresh  ──▶  refresh work credentials (work only)
```

Usage:

```
$ ./workstation <command> [entity]
$ ./workstation install clojure
$ ./workstation connect github
$ ./workstation refresh nu
```

When a command is run in an environment that is not in its `:allowed-on` list, `systems/library/logic.fnl`'s `dispatch` exits silently without invoking the handler.

## §3 · topology

```
~/.dotfiles
├── workstation                  ◀── bash entry · OS detection · dep bootstrap
│
├── systems/                     ◀── Fennel CLI · ansible config
│   ├── core.fnl                 ◀── entrypoint + register table
│   ├── hosts.ini                ◀── ansible inventory
│   ├── .vault_  .become_        ◀── gitignored password files
│   │
│   ├── library/                 ◀── Fennel libraries
│   │   ├── common.fnl           ◀── os-name · working-day? · environment
│   │   ├── logic.fnl            ◀── allowed? · dispatch  (gating primitive)
│   │   ├── ansible.fnl          ◀── ping · setup
│   │   └── work.fnl             ◀── bom-dia  (Nu refresh sequence)
│   │
│   ├── macos/ansible.cfg
│   ├── linux/
│   │   ├── ansible.cfg
│   │   ├── playbook.yml
│   │   └── CLAUDE.md
│   ├── life/
│   │   ├── playbook.yml
│   │   └── CLAUDE.md
│   └── work/
│       ├── playbook.yml
│       └── CLAUDE.md
│
├── roles/                       ◀── ansible roles
│   ├── common/                  all environments
│   ├── macos/                   brew
│   ├── work/                    internal toolchain
│   ├── life/                    personal
│   └── linux/                   pacman
│
└── files/                       ◀── managed dotfiles (symlinked)
    ├── nvim/        ghostty/
    └── .zshrc  .zprofile  .life_profile  .linux_profile  .work_profile
```

Deployment invariant — files are **always** symlinked, never copied:

```
~/.dotfiles/files/X    ◂─────── ln -s ───────▸    $HOME/X
```

## §4 · deprecated

The Go module is the previous runtime. It is kept in the tree during the Fennel migration but is no longer on the runtime path — `workstation` does not invoke `go run`. Files slated for removal:

- `go.mod` — module manifest, kept until Fennel replacements land.
- `systems/main.go` — was the Go entrypoint; superseded by `systems/core.fnl`.
- `systems/command/guard.go` + `guard_test.go` — gating primitive; superseded by `systems/library/logic.fnl`.
- `systems/language/install.go` — `install scala|clojure` Go handlers; will be rewritten as `systems/library/language.fnl`.
- `systems/github/connect.go` — `connect github` Go handler; will be rewritten as `systems/library/github.fnl`.

Do not reference these files from new code.

## §5 · direction

End state: Fennel + sh across the board, including the Neovim config (`files/nvim/init.lua` and `lua/plugins/*.lua` → Fennel). The Neovim substrate is already in place — `fennel_ls` LSP, `fnlfmt` via `conform.nvim`, `treesitter-fennel`, and `paredit` for `clojure` / `fennel` filetypes — so the rewrite is a translation, not a new toolchain.
