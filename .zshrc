# Download Znap, if it's not there yet.
if [[ ! -f ${ZDOTDIR:-~}/.antidote/antidote.zsh ]]; then
    git clone --depth 1 -- \
    https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
fi

source ${ZDOTDIR:-~}/.antidote/antidote.zsh
antidote load

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=10000

unsetopt beep notify
bindkey -e

autoload -U compinit

() {
    setopt extendedglob local_options
    
    if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
        antidote update
        compinit
    else
        compinit -C
    fi
}

autoload -Uz select-word-style
select-word-style bash

# init stuff
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
fi
if command -v direnv >/dev/null; then
    eval "$(direnv hook zsh)"
fi
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi
if command -v kubectl >/dev/null; then
    source <(kubectl completion zsh)
fi
if [[ -f /etc/profile.d/google-cloud-sdk.sh ]]; then
    source /etc/profile.d/google-cloud-sdk.sh
fi


# key bindings
bindkey '^H' backward-kill-word
bindkey '5~' kill-word
bindkey '\t' menu-complete


alias update='sudo dnf update -y && flatpak update'
# update dotfiles with yadm and autosquash commits that were made today
alias dotupdate='yadm add -u && yadm commit -m "update" && yadm push'
alias dotgit="GIT_WORK_TREE=~ GIT_DIR=~/.local/share/yadm/repo.git"

alias gmt='go mod tidy'
alias gcl='golangci-lint run'
alias dk='docker kill $(docker ps -q)'
alias dcu="docker compose up -d"
alias dcd="docker compose down"

export KUBE_EDITOR="code -w"
export EDITOR="code -w"

export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin/
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:/home/aludes/.local/bin"
export PATH=$PATH:/home/aludes/.spicetify
