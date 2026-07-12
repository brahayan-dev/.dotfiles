# `~/.dotfiles`

Multi-environment dotfiles repository. A small Go CLI dispatches to environment-specific Ansible playbooks that deploy configs via symlinks.

```
$ git clone <repo> ~/.dotfiles
$ cd ~/.dotfiles
$ ./workstation setup
```

## §0 · bootstrap

```
$ ./workstation setup
```

The `workstation` shell script detects the OS, installs `go` and `ansible` if missing (brew on macOS, pacman on Linux), then `exec`s `go run systems/main.go` with the rest of the args. All dispatch lives in Go from that point on.

## §1 · environments

Three environments, partitioned by host signal:

| env     | host signal              | toolchain                                  |
| ------- | ------------------------ | ------------------------------------------ |
| `work`  | macOS, `~/.nurc` exists  | Scala, Clojure, Nu infrastructure          |
| `life`  | macOS, default           | Personal dev (SSH, git, API tokens)        |
| `linux` | Linux, `pacman` detected | Similar to `life` with Linux-specific pkgs |

Intersection — what every environment inherits:

```
work ∩ life ∩ linux = { Golang, Neovim, Claude Code, zsh, ~/.config }
```

## §2 · commands

The dispatcher is a `map[string]Entry` in `systems/main.go`. Each entry pairs a handler with a list of allowed environments.

| command           | work | life | linux |
| ----------------- | :--: | :--: | :---: |
| `setup`           |  ●   |  ●   |   ●   |
| `ping`            |  ●   |  ●   |   ●   |
| `install scala`   |  ●   |  ·   |   ·   |
| `install clojure` |  ●   |  ·   |   ·   |
| `connect github`  |  ·   |  ●   |   ●   |
| `refresh nu`      |  ●   |  ·   |   ·   |

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

When a command is run in an environment that is not in its allowlist, the dispatcher exits 0 silently.

## §3 · topology

```
~/.dotfiles
├── workstation                  ◀── shell entry · OS detection · dep bootstrap
│
├── systems/                     ◀── Go CLI · ansible config
│   ├── main.go                  ◀── entrypoint + command registry
│   ├── hosts.ini                ◀── ansible inventory
│   ├── .vault_  .become_        ◀── gitignored password files
│   ├── command/
│   │   ├── guard.go             ◀── Allowed() · Valid() — pure gating logic
│   │   └── guard_test.go
│   ├── ansible/ansible.go       ◀── Ping() · Setup()
│   ├── github/connect.go        ◀── Connect()
│   ├── language/install.go      ◀── Install(scala|clojure)
│   ├── work/bom_dia.go          ◀── BomDia() — work-only refresh
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
