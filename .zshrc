# Download Znap, if it's not there yet.
[[ -f ${ZDOTDIR:-~}/.antidote/antidote.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

source ${ZDOTDIR:-~}/.antidote/antidote.zsh
antidote load

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=10000

unsetopt beep notify
bindkey -e

autoload -Uz compinit
compinit

autoload -Uz select-word-style
select-word-style bash

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

# key bindings
bindkey '^H' backward-kill-word
bindkey '5~' kill-word

alias update='sudo apt update && sudo apt full-upgrade'
alias dotupdate='yadm add -u && yadm commit -m update && yadm push'
alias gmt='go mod tidy'
alias dk='docker kill $(docker ps -q)'
alias dcu="docker compose up -d"
alias dcd="docker compose down"
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin/
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:/home/aludes/.local/bin"
