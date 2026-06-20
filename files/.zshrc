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
alias setup='cd "$HOME/.dotfiles/" && ./workstation setup'

# NOTE: Repository
alias _kiln='cd "$HOME/Projects/kiln/"'
alias __kiln='cd "$HOME/Projects/kiln/" && nvim .'

# ---------
# Settings
# ---------
source ~/.zprofile
# NOTE: Workstation CLI
export PATH="$HOME/.dotfiles/:$PATH"
# NOTE: Editor
export EDITOR=nvim
# NOTE: Mise
eval "$(~/.local/bin/mise activate zsh)"
# NOTE: Direnv
eval "$(direnv hook zsh)"
if [[ "$(uname -a)" =~ Darwin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$PATH:$HOME/.local/bin"
    # NOTE: LuaJIT
    export LUA_DIR="/opt/homebrew/opt/luajit"
    export PATH="$LUA_DIR/bin:$PATH"
    export LDFLAGS="-L$LUA_DIR/lib"
    export CPPFLAGS="-I$LUA_DIR/include"
    export PKG_CONFIG_PATH="$LUA_DIR/lib/pkgconfig"
fi
