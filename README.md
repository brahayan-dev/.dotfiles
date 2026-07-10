```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║   ~/.dotfiles  ▸  DAG  ▸  a directed acyclic deployment              ║
║                                                                      ║
║                                                                      ║
║                        ╔═════════╗                                   ║
║                        ║ workstn ║  ◀── entry point                  ║
║                        ╚════╤════╝                                   ║
║                             │                                        ║
║                      ┌──────┼──────┐                                 ║
║                      ▼      ▼      ▼                                 ║
║                   ┌────┐ ┌────┐ ┌─────┐                              ║
║                   │work│ │life│ │linux│   ◀── V(G), |V| = 3          ║
║                   └─┬──┘ └─┬──┘ └──┬──┘                              ║
║                     │      │       │                                 ║
║                     └──────┼───────┘                                 ║
║                            ▼                                         ║
║                      ╔═══════════╗                                   ║
║                      ║  Ansible  ║   ◀── orchestrator                ║
║                      ╚═════╤═════╝                                   ║
║                            ▼                                         ║
║                      ╔═══════════╗                                   ║
║                      ║ symlinks  ║ ──▶ $HOME · ~/.config             ║
║                      ╚═══════════╝                                   ║
║                                                                      ║
║         nodes: 5     edges: 7     χ(G) = 3     acyclic: ✓            ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

```
   §0  bootstrap         ▸  one-line ignition
   §1  V(G) · vertices   ▸  environments
   §2  E(G) · edges      ▸  commands
   §3  topology          ▸  directory layout
   §4  Σ secrets         ▸  vault & profile chain
```

---

## §0 · bootstrap

```
   $ git clone <repo> ~/.dotfiles
   $ cd ~/.dotfiles
   $ ./workstation setup
```

---

## §1 · V(G) · vertices

Three environments, partitioned by host signal:

```
              ┌─────────┐
              │  work   │   macOS · ~/.nurc exists
              ├─────────┤   Scala · Golang · Clojure · Neovim · Claude Code
              │         │
              └─────────┘

              ┌─────────┐
              │  life   │   macOS · default
              ├─────────┤   Golang · Neovim · Claude Code
              │         │
              └─────────┘

              ┌─────────┐
              │  linux  │   Linux · pacman detected
              ├─────────┤   Golang · Neovim · Claude Code
              │         │
              └─────────┘
```

Intersection ─ what every vertex inherits:

```
   work ∩ life ∩ linux  =  { Golang, Neovim, Claude Code, zsh, ~/.config }
```

---

## §2 · E(G) · edges

The command × environment adjacency:

```
            │ work    life    linux
   ─────────┼──────────────────────────
    setup   │  ●       ●       ●
    ping    │  ●       ●       ●
    install │  ●       ●       ●
    connect │  ·       ●       ●
    refresh │  ●       ·       ·
```

```
   ┌─ edges ──────────────────────────────────────────────────────────┐
   │                                                                  │
   │  setup   ──▶  run the Ansible playbook for the host              │
   │  ping    ──▶  sanity check (host reachable, deps installed)      │
   │  install ──▶  install a language toolchain                       │
   │              ↳ install clojure │ install scala                   │
   │  connect ──▶  authenticate with the remote forge                 │
   │  refresh ──▶  refresh work credentials                           │
   │                                                                  │
   └──────────────────────────────────────────────────────────────────┘
```

Usage:

```
   $ ./workstation <command> [entity]
   $ ./workstation install clojure
   $ ./workstation connect github
   $ ./workstation refresh nu
```

---

## §3 · topology

A single `main.scm` is the entry point; `common.scm` gates each command to
its environments at runtime (via `uname` + `~/.nurc`). `workstation` only
detects the OS to bootstrap deps, then hands off to Golang.

```
   ~/.dotfiles
   │
   ├── workstation                 ◀── shell entry · OS detection · deps
   │
   ├── systems/                    ◀── guile CLI · ansible config
   │   ├── main.scm                ◀── command registry · single entry
   │   ├── work.cfg    work.yml    work.md
   │   ├── life.cfg    life.yml    life.md
   │   ├── linux.cfg   linux.yml   linux.md
   │   └── library/
   │       ├── common.scm          command · environment gating
   │       ├── ansible.scm         ->ping · ->setup
   │       ├── language.scm        install-scala · install-clojure
   │       ├── work.scm            ->bom-dia · refresh (work only)
   │       └── interactive.lua     install · connect        (legacy)
   │
   ├── roles/                      ◀── ansible roles
   │   ├── common/                 all environments
   │   ├── macos/                  brew
   │   ├── work/                   internal toolchain
   │   ├── life/                   personal
   │   └── linux/                  pacman
   │
   └── files/                      ◀── managed dotfiles (symlinked)
       ├── nvim/        ghostty/     nvim/
       └── .zshrc       .zprofile    .life_profile    .linux_profile
```

Deployment invariant ─ files are **always** symlinked, never copied:

```
   ~/.dotfiles/files/X    ◂─────── ln -s ───────▸    $HOME/X
```

---

## §4 · Σ secrets

```
   ╭─ ansible vault ──────────────────────────────────────────────╮
   │                                                              │
   │   encrypted role vars  ◀── ansible-vault                     │
   │   vault password file  ◀── gitignored                        │
   │   become password file ◀── gitignored                        │
   │                                                              │
   ╰──────────────────────────────────────────────────────────────╯
```

The profile chain, sourced in order by `.zprofile`:

```
   ~/.life_profile  ▸  ~/.work_profile  ▸  ~/.linux_profile  ▸  ~/.private_profile
```

Each profile is environment-scoped; the private one holds anything that
should never enter the graph above.

