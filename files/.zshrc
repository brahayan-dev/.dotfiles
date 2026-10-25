#!/usr/bin/env zsh

# -----
# Zsh
# -----
export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"

plugins=(git)
[ -s $ZSH/oh-my-zsh.sh ] && source $ZSH/oh-my-zsh.sh

zsource() {
    source ~/.zshrc
    source ~/.zprofile
    return 0
}

# ------
# Alias
# ------
alias lg='lazygit'
alias llm='ollama launch opencode'
alias setup='cd "$HOME/.dotfiles/" && ./workstation setup'

# ---------
# Settings
# ---------
source ~/.zprofile
# NOTE: Local binaries
export PATH="$HOME/.local/bin:$PATH"
# NOTE: Direnv
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
# NOTE: Editor
export EDITOR=nvim
# NOTE: Repositories
eval "$(~/.dotfiles/workstation generate-aliases)"
# NOTE: Mise
command -v mise >/dev/null && eval "$(mise activate zsh)"

