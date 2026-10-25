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

The `workstation` shell script detects the OS, installs `fennel` and `ansible` if missing (brew on macOS, pacman on Linux), then `exec`s `fennel systems/core.fnl "$@"`. All dispatch lives in Fennel from that point on; the versioned toolchains come from mise — Ruby 4 via `./workstation install ruby`, Python via `./workstation install python`.

## §1 · environments

Two environments, partitioned by host signal (see `systems/library/common.fnl`):

| env     | host signal              | toolchain                                                  |
| ------- | ------------------------ | ---------------------------------------------------------- |
| `life`  | macOS, default           | Personal dev (SSH, git, Ruby, Python, Elm, JS, API tokens) |
| `linux` | Linux, `pacman` detected | Same tooling as `life`, Linux pkgs                         |

## §2 · commands

The dispatcher is the `register` function in `systems/core.fnl`. Each entry pairs a handler with an `:allowed-on` value (`:all` — only life and linux remain). Side-effectful commands fail fast through `run` (non-zero exit code propagation).

| command            | life | linux |
| ------------------ | :--: | :---: |
| `ping`             |  ●   |   ●   |
| `setup`            |  ●   |   ●   |
| `install ruby`     |  ●   |   ●   |
| `install python`   |  ●   |   ●   |
| `connect github`   |  ●   |   ●   |
| `generate aliases` |  ●   |   ●   |

Usage:

```
$ ./workstation <command> [entity]
```

## §3 · topology

```
~/.dotfiles
├── workstation                  ◀── bash entry · OS detection · dep bootstrap
│
├── systems/                     ◀── Fennel CLI · ansible config
│   ├── core.fnl                 ◀── entrypoint + register table
│   ├── hosts.ini                ◀── ansible inventory
│   │
│   ├── library/                 ◀── Fennel libraries
│   │   ├── common.fnl           ◀── os-name · environment · run
│   │   ├── logic.fnl            ◀── allowed-on · dispatch  (gating primitive)
│   │   ├── ansible.fnl          ◀── ping · setup
│   │   ├── interactive.fnl      ◀── install ruby · install python · connect github
│   │   └── repository.fnl       ◀── generate aliases
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
