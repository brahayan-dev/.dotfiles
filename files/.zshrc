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

# NOTE: Repositories
alias _kiln='cd "$HOME/Projects/kiln/"'
alias __kiln='cd "$HOME/Projects/kiln/" && nvim .'

alias _dotfiles='cd "$HOME/.dotfiles/"'
alias __dotfiles='cd "$HOME/.dotfiles/" && nvim .'

alias _workbook='cd "$HOME/Projects/workbook/"'
alias __workbook='cd "$HOME/Projects/workbook/" && nvim .'

alias _turing='cd "$HOME/Projects/turing/"'
alias __turing='cd "$HOME/Projects/turing/" && nvim .'

# NOTE: Repositories (Ak)
alias _max-neef='cd "$HOME/Projects/max-neef/"'
alias __max-neef='cd "$HOME/Projects/max-neef/" && nvim .'

alias _fengari-app='cd "$HOME/Projects/fengari-app/"'
alias __fengari-app='cd "$HOME/Projects/fengari-app/" && nvim .'

alias _fengari-api='cd "$HOME/Projects/fengari-api/"'
alias __fengari-api='cd "$HOME/Projects/fengari-api/" && nvim .'

alias _fengari-hub='cd "$HOME/Projects/fengari-hub/"'
alias __fengari-hub='cd "$HOME/Projects/fengari-hub/" && nvim .'

alias _fengari-box='cd "$HOME/Projects/fengari-box/"'
alias __fengari-box='cd "$HOME/Projects/fengari-box/" && nvim .'

alias _fengari-ops='cd "$HOME/Projects/fengari-ops/"'
alias __fengari-ops='cd "$HOME/Projects/fengari-ops/" && nvim .'
