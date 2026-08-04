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

| env     | host signal               | toolchain                                      |
| ------- | ------------------------- | ---------------------------------------------- |
| `work`  | macOS, work-env available | Scala and Clojure, Work infrastructure         |
| `life`  | macOS, default            | Personal dev (SSH, git, API tokens), CL        |
| `linux` | Linux, `pacman` detected  | Similar to `life` with Linux-specific pkgs, CL |

## §2 · commands

The dispatcher is the `register` function in `systems/core.fnl`. Each entry pairs a handler with an `:allowed-on` list (`:all`, `:work`, or `[:life :linux]`).

| command               | work | life | linux |
| --------------------- | :--: | :--: | :---: |
| `ping`                |  ●   |  ●   |   ●   |
| `setup`               |  ●   |  ●   |   ●   |
| `install scala`       |  ●   |  ·   |   ·   |
| `install common-lisp` |  ·   |  ●   |   ●   |
| `connect github`      |  ·   |  ●   |   ●   |
| `refresh nu`          |  ●   |  ·   |   ·   |
| `clone repositories`  |  ●   |  ·   |   ·   |
| `generate aliases`    |  ●   |  ●   |   ●   |

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
│   │   ├── logic.fnl            ◀── allowed? · dispatch  (gating primitive)
│   │   ├── ansible.fnl          ◀── ping · setup
│   │   ├── interactive.fnl      ◀── install-* · connect-github
│   │   ├── repository.fnl       ◀── generate-aliases · clone-repositories
│   │   └── work.fnl             ◀── bom-dia  (Work refresh sequence)
│   │
│   ├── macos/ansible.cfg
│   ├── linux/
│   │   ├── ansible.cfg
│   │   ├── playbook.yml
│   │   └── AGENTS.md
│   ├── life/
│   │   ├── playbook.yml
│   │   └── AGENTS.md
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
