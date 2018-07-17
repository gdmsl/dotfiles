# needed because of leaking emulate -L sh on the cluster
emulate -R zsh

# username to hide for themes
DEFAULT_USER="gdmsl"

# ignore certain commands from history
export HISTORY_IGNORE="cd:cd ..:ls:la:make"

# eval dircolors for ls
eval $(dircolors ~/.dircolors)

# color scheme for console theme
if [ "$TERM" = "linux" ]; then
    source $HOME/.vconsole_theme
    clear
fi

# Default SSH_ASKPASS
export SSH_ASKPASS="/usr/bin/ksshaskpass"

# show time for every program which run for more than 10 seconds
export REPORTTIME=10

# init screen
if ! timeout 5s ping -w 1 -W 1 -c 1 mail.google.com &> /dev/null; then
    fortune -s
else
    timeout 5s curl wttr.in/\?0
fi

echo "$fg[red]Last -Syu:$reset_color $(grep "pacman -Syu" /var/log/pacman.log | tail -n1 | cut -c 2- | cut -c-16)"
echo "$reset_color"

# include files in zsh folder
for file in `ls $HOME/.zsh/`; do
    [ -f $file ] && source $file
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

# Oh my zsh
zplug "lib/completion", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/jump", from:oh-my-zsh
zplug "plugins/archlinux", from:oh-my-zsh
zplug "plugins/cp", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/fasd", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/github", from:oh-my-zsh
zplug "plugins/vi-mode", from:oh-my-zsh

zstyle :omz:plugins:ssh-agent agent-forwarding on
zplug "plugins/ssh-agent", from:oh-my-zsh

# Async for zsh, used by pure
zplug "mafredri/zsh-async", from:github, defer:0

# Theme!
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# Syntax highlighting for commands, load last
zplug "zsh-users/zsh-history-substring-search", from:github
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
