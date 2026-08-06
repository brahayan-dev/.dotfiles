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

plugins=(git direnv)
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
alias setup='cd "$HOME/.dotfiles/" && ./workstation setup'

# ---------
# Settings
# ---------
source ~/.zprofile
# NOTE: Editor
export EDITOR=nvim
# NOTE: Repositories
eval "$(~/.dotfiles/workstation generate aliases)"
# NOTE: Direnv
eval "$(direnv hook zsh)"
if [[ "$(uname -a)" =~ Darwin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$PATH:$HOME/.local/bin"
fi

# opencode
export PATH=/home/bxsr/.opencode/bin:$PATH
