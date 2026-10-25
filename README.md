# `~/.dotfiles`

Multi-environment dotfiles repository. A small `justfile` dispatches to environment-specific Ansible playbooks that deploy configs via symlinks from `~/.dotfiles/files/` into `$HOME` and `~/.config/`.

```
$ git clone <repo> ~/.dotfiles
$ cd ~/.dotfiles
$ ./workstation setup
```

## §0 · bootstrap

```
$ ./workstation setup
```

The `workstation` shell script detects the OS, installs `just` and `ansible` if missing (brew on macOS, pacman on Linux), then `exec`s `just --justfile justfile`. All dispatch lives in the justfile from that point on; the versioned toolchains come from mise — Ruby 4 via `./workstation install ruby`, Python via `./workstation install python`.

## §1 · environments

Two environments, partitioned by `os()` in the justfile:

| env     | host signal              | toolchain                                                  |
| ------- | ------------------------ | ---------------------------------------------------------- |
| `life`  | macOS, default           | Personal dev (SSH, git, Ruby, Python, Elm, JS, API tokens) |
| `linux` | Linux, `pacman` detected | Same tooling as `life`, Linux pkgs                         |

## §2 · commands

The dispatcher is the `justfile` at the repo root — `just --list` documents every recipe and aliases (`p`, `s`) cover the daily ones. Side-effectful recipes stop at the first failing line with a non-zero exit code.

| command            | life | linux |
| ------------------ | :--: | :---: |
| `ping`             |  ●   |   ●   |
| `setup`            |  ●   |   ●   |
| `install ruby`     |  ●   |   ●   |
| `install python`   |  ●   |   ●   |
| `connect github`   |  ●   |   ●   |
| `generate-aliases` |  ●   |   ●   |

Usage:

```
$ ./workstation <command> [entity]
```

## §3 · topology

```
~/.dotfiles
├── workstation                  ◀── bash entry · OS detection · dep bootstrap
├── justfile                     ◀── command runner · ansible invocation
│
├── systems/                     ◀── ansible config
│   ├── hosts.ini                ◀── ansible inventory
│   │
│   ├── life/
│   │   ├── ansible.cfg          ◀── Darwin config
│   │   ├── playbook.yml
│   │   └── AGENTS.md
│   └── linux/
│       ├── ansible.cfg          ◀── Linux config
│       ├── playbook.yml
│       └── AGENTS.md
│
├── roles/                       ◀── ansible roles
│   ├── common/                  all environments
│   ├── macos/                   brew
│   ├── life/                    personal
│   └── linux/                   pacman
│
└── files/                       ◀── managed dotfiles (symlinked)
    ├── nvim/fnl/   ghostty/
    └── .zshrc  .zprofile  .life_profile  .linux_profile
```

Deployment invariant — files are **always** symlinked, never copied:

```
~/.dotfiles/files/X    ◂─────── ln -s ───────▸    $HOME/X
```
