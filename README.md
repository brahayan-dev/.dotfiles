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

The entry script auto-detects the host and routes through the matching
`systems/<env>.lua` dispatcher. No flags, no prompts ─ just the graph.

---

## §1 · V(G) · vertices

Three environments, partitioned by host signal:

```
              ┌─────────┐
              │  work   │   macOS · ~/.nurc exists
              ├─────────┤   Scala · Clojure · Neovim/Emacs · Claude Code
              │         │
              └─────────┘

              ┌─────────┐
              │  life   │   macOS · default
              ├─────────┤   Scala · Ruby · Neovim · Claude Code
              │         │
              └─────────┘

              ┌─────────┐
              │  linux  │   Linux · pacman detected
              ├─────────┤   Arch-family · life-equivalent toolchain
              │         │
              └─────────┘
```

Intersection ─ what every vertex inherits:

```
   work ∩ life ∩ linux  =  { Scala, Neovim, Claude Code, zsh, ~/.config }
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
   │              ↳ install scala  │ install java                     │
   │              ↳ install ruby   │ install dotnet  │ install lua    │
   │  connect ──▶  authenticate with the remote forge                 │
   │  refresh ──▶  refresh work credentials                           │
   │                                                                  │
   └──────────────────────────────────────────────────────────────────┘
```

Usage:

```
   $ ./workstation <command> [entity]
   $ ./workstation install scala
   $ ./workstation connect github
   $ ./workstation refresh nu
```

---

## §3 · topology

```
   ~/.dotfiles
   │
   ├── workstation                 ◀── shell entry · OS detection
   │
   ├── systems/                    ◀── lua CLI · ansible config
   │   ├── work.lua    work.cfg    work.yml
   │   ├── life.lua    life.cfg    life.yml
   │   ├── linux.lua   linux.cfg   linux.yml
   │   └── library/
   │       ├── common.lua          shell() · set_ansible_cfg()
   │       ├── interactive.lua     install · connect · ping · setup
   │       ├── language.lua        toolchain installers
   │       └── work.lua            refresh (work only)
   │
   ├── roles/                      ◀── ansible roles
   │   ├── common/                 all environments
   │   ├── macos/                  brew
   │   ├── work/                   internal toolchain
   │   ├── life/                   personal
   │   └── linux/                  pacman
   │
   └── files/                      ◀── managed dotfiles (symlinked)
       ├── nvim/        ghostty/     doom/
       ├── emacs-plus/  profiles/
       └── .zshrc       .zprofile
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

---

```
                                   ┌────────────┐
                                   │   fin.     │
                                   └────────────┘
                          Q.E.D. · the graph is consistent
```
