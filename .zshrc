
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Define the path of the timestamp file
TIMESTAMP_FILE="$HOME/.zinit_last_update"

# If the timestamp file doesn't exist or it was modified more than 24 hours ago
if [[ ! -e "$TIMESTAMP_FILE" ]] || [[ "$(find "$TIMESTAMP_FILE" -mtime +1)" ]]; then
    zinit self-update
    zinit update --parallel

    # Update the timestamp file
    touch "$TIMESTAMP_FILE"
fi

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light peterhurford/up.zsh
zinit light mattmc3/zman

# Add in snippets
zinit snippet OMZP::ansible
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found
zinit snippet OMZP::dnf
zinit snippet OMZP::git
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::pre-commit
zinit snippet OMZP::sudo
zinit snippet OMZP::systemd

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[[A' fzf-history-widget
bindkey '^[w' kill-region
bindkey '^H' backward-kill-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[3;5~' kill-word


# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

unsetopt beep notify

autoload -Uz select-word-style
select-word-style bash


# Shell integrations
if command -v fzf >/dev/null; then
    eval "$(fzf --zsh)"
fi
if command -v oh-my-posh >/dev/null; then
    eval "$(oh-my-posh init zsh -c ${HOME}/.config/oh-my-posh/config.yaml)"
elif command -v starship >/dev/null; then
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
if command -v eza >/dev/null; then
    alias ls=eza
    alias ls='eza -h --group-directories-first'
else
    alias ls='ls -h --group-directories-first'
fi

alias vim='nvim'
alias c='clear'
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
NPM_PACKAGES="$HOME/.npm-packages"
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$NPM_PACKAGES/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:/home/aludes/.local/bin"
export PATH=$PATH:/home/aludes/.spicetify
