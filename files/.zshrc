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
}

# ------
# Alias
# ------
alias lg='lazygit'

# ---------
# Settings
# ---------
# NOTE: Workstation CLI
export PATH="$HOME/.dotfiles/:$PATH"
# NOTE: Editor
export EDITOR=nvim
export PATH="$HOME/.config/emacs/bin/:$PATH"
# NOTE: Dotnet
export PATH="$PATH:$HOME/.dotnet/tools"
# NOTE: Ruby
eval "$(~/.local/bin/mise activate zsh)"
# NOTE: Direnv
eval "$(direnv hook zsh)"
if [[ "$(uname -a)" =~ Darwin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$PATH:$HOME/.local/bin"
    # NOTE: Lua
    export PATH="/opt/homebrew/opt/lua@5.4/bin:$PATH"
    export LDFLAGS="-L/opt/homebrew/opt/lua@5.4/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/lua@5.4/include"
    export PKG_CONFIG_PATH="/opt/homebrew/opt/lua@5.4/lib/pkgconfig"
fi

# NOTE: Repository
alias _kiln='cd "$HOME/Projects/kiln/"'
alias __kiln='cd "$HOME/Projects/kiln/" && nvim .'

