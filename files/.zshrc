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

# >>> Nubank SSL Inspection CA — managed by: nu zscaler setup env >>>
# mode: baseline
NUBANK_CA_CERT="$HOME/dev/nu/.nu/certificates/zscaler/ca-bundle-with-zscaler.pem"


# BASELINE — Essential SSL/TLS trust
export SSL_CERT_FILE="$NUBANK_CA_CERT"
export SSL_CERT_DIR="/etc/ssl/certs"
export REQUESTS_CA_BUNDLE="$NUBANK_CA_CERT"              # Python requests, urllib3
export CURL_CA_BUNDLE="$NUBANK_CA_CERT"                  # curl, libcurl
export AWS_CA_BUNDLE="$NUBANK_CA_CERT"                   # AWS CLI, boto3, AWS SDKs
export NODE_EXTRA_CA_CERTS="$NUBANK_CA_CERT"             # Node.js, Bun, Claude Code, Cursor, VS Code, Copilot
# <<< Nubank SSL Inspection CA <<<
