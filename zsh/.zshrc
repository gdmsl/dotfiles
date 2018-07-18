# needed because of leaking emulate -L sh on the cluster
emulate -R zsh

# source local definitions
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# ignore certain commands from history
export HISTORY_IGNORE="cd:cd ..:ls:la:make"
export HISTFILE="$HOME/.zsh_history"

eval "$(dircolors ~/.dircolors)"

# color scheme for console theme
if [ "$TERM" = "linux" ]; then
    source $HOME/.vconsole_theme
    clear
fi

# Default SSH_ASKPASS
if which ksshaskpass &> /dev/null; then
    export SSH_ASKPASS="$(which ksshaskpass)"
fi

# show time for every program which run for more than 10 seconds
export REPORTTIME=10

# init screen
if ! timeout 5s ping -w 1 -W 1 -c 1 mail.google.com &> /dev/null; then
    fortune -s
else
    timeout 5s curl wttr.in/\?0
fi

if which pacman &> /dev/null; then
    echo "$fg[red]Last -Syu:$reset_color $(grep "pacman -Syu" /var/log/pacman.log | tail -n1 | cut -c 2- | cut -c-16)"
    echo "$reset_color"
fi

# include files in zsh folder
for file in $HOME/.zsh/*; do
    if [ -e "$file" ]; then
        source $file
    fi
done

################################## zplug ######################################

# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

# use zplug
source ~/.zplug/init.zsh


# PACKAGES

# Oh my zsh libs
zplug "lib/*", from:oh-my-zsh

# oh my zsh plugins
zplug "plugins/git", from:oh-my-zsh, if:"which git"
zplug "plugins/git-extras", from:oh-my-zsh, if:"which git"
zplug "plugins/tmux", from:oh-my-zsh, if:"which tmux"
zplug "plugins/fasd", from:oh-my-zsh, if:"which fasd"
zplug "plugins/archlinux", from:oh-my-zsh, if:"which pacman"
zplug "plugins/cargo", from:oh-my-zsh, if:"which cargo"
zplug "plugins/vagrant", from:oh-my-zsh, if:"which vagrant"
zplug "plugins/rsync", from:oh-my-zsh, if:"which rsync"
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/common-aliases", from:oh-my-zsh
zplug "plugins/history", from:oh-my-zsh
zplug "plugins/jump", from:oh-my-zsh
zplug "plugins/cp", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/github", from:oh-my-zsh
zplug "plugins/vi-mode", from:oh-my-zsh

zstyle :omz:plugins:ssh-agent agent-forwarding on
zplug "plugins/ssh-agent", from:oh-my-zsh

# Async for zsh, used by pure
zplug "mafredri/zsh-async", from:github, defer:0

# Theme!
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# Syntax highlighting for commands, load last
zplug "plugins/history-substring-search", from:oh-my-zsh, defer:2
zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:3

# Install packages that have not been installed yet
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi

zplug load
