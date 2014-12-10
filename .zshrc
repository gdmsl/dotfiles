# dircolors for TERMITE
eval $(dircolors ~/.dircolors)

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="bureau"
ZSH_THEME="robbyrussell"

HIST_STAMPS="yyyy-mm-dd"

plugins=(jump git archlinux cp tmux github history history-substring-search)

source $ZSH/oh-my-zsh.sh
source $HOME/.zsh/aliases.zsh
source $HOME/.profile
source $ZSH/plugins/history-substring-search/history-substring-search.zsh

# completition system
autoload -Uz compinit zcalc
compinit
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==02=01}:${(s.:.)LS_COLORS}")'
zstyle ':completion:*' menu select
zstyle '*:processes-names' command 'ps -e -o comm='
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle ':completion:*' file-sort modification reverse
autoload -U colors && colors
zstyle ':completion:*' list-colors "=(#b) #([0-9]#)*=31=36"

# start gnome keyring
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start --components=ssh)
    export SSH_AUTH_SOCK
fi

# Startup message
echo -n "$fg[yellow]"
fortune -a -s
echo -n "$reset_color"
echo "$fg[red]Last -Syu:$reset_color $(grep "pacman -Syu" /var/log/pacman.log | tail -n1 | cut -c 2- | cut -c-16)"
echo ""
