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

autoload -U compinit

() {
  setopt extendedglob local_options

  if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
}

autoload -Uz select-word-style
select-word-style bash

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh --cmd cd)"
source <(kubectl completion zsh)
# source <(goreleaser completion zsh)
source /etc/profile.d/google-cloud-cli.sh


# key bindings
bindkey '^H' backward-kill-word
bindkey '5~' kill-word
bindkey '\t' menu-complete


alias update='sudo dnf update -y && flatpak update'
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
export PATH=$PATH:/home/aludes/.spicetify
