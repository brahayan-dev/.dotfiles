# dotfiles workstation · just as the task runner

cfg := if os() == "macos" { "systems/life/ansible.cfg" } else { "systems/linux/ansible.cfg" }
playbook := if os() == "macos" { "systems/life/playbook.yml" } else { "systems/linux/playbook.yml" }
repos := "workbook turing frapelle nullstellensatz box toy zen hub"

@default:
    @just --list

alias p := ping
alias s := setup

# ansible -m ping (sanity check)
@ping:
    ANSIBLE_CONFIG={{ cfg }} ansible -c local -m ping -i systems/hosts.ini Workstation

# run the ansible playbook for the host
@setup:
    ANSIBLE_CONFIG={{ cfg }} ansible-playbook -c local -i systems/hosts.ini \
      --vault-password-file systems/.vault_ --become-password-file systems/.become_ {{ playbook }}

# install the Python runtime via mise
@install:
    mise use -g "python@latest"

@connect-github:
    gh auth login
    gh auth refresh -h github.com -s admin:ssh_signing_key
    gh ssh-key add "$HOME/.ssh/$(whoami)_rsa.pub" -t "$(hostname)"

@generate-aliases:
    printf "alias _.dotfiles='cd %s'\n" "$HOME/.dotfiles"; printf "alias __.dotfiles='cd %s && nvim .'\n" "$HOME/.dotfiles"; for repo in {{ repos }}; do printf "alias _%s='cd %s/Projects/%s'\n" "$repo" "$HOME" "$repo"; printf "alias __%s='cd %s/Projects/%s && nvim .'\n" "$repo" "$HOME" "$repo"; done
