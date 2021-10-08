#
# ~/.profile
#

# source global profile
source /etc/profile

# setting the PATH envirorment variable
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# library path
export LD_LIBRARY_PATH="$HOME/.local/lib64:$HOME/.local/lib:$LD_LIBRARYPATH"

# go path
export GOPATH="$HOME/Variable/go"
export PATH="$PATH:$GOPATH/bin"

# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# python path
#export PYTHONUSERBASE="$HOME/Variable/python3"
#export PYTHONPATH="$PYTHONUSERBASE/lib/python3.7/site-packages:$PYTHONPATH"
#export PATH="$PYTHONUSERBASE/bin:$PATH"

if [ "$HOST" = "rubick" ]; then
    export LIBVA_DRIVER_NAME=i965
    export VDPAU_DRIVER=va_gl
elif [ "$HOST" = "spectre" ]; then
    export LIBVA_DRIVER_NAME=vdpau
    export VDPAU_DRIVER=nvidia
elif [ "$HOST" = "tachanka" ]; then
    export LIBVA_DRIVER_NAME=i965
    export VDPAU_DRIVER=va_gl
fi

# Default text editor
export EDITOR="nvim"

# Default browser
export BROWSER="firefox"

# Default terminal emulator
export TERMINAL="alacritty"

# Ruby
export GEM_HOME=$(ruby -e 'print Gem.user_dir')
export PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"

# Rust Path, if any
[ -e "$HOME/.cargo/env" ] && source $HOME/.cargo/env

# Use binary release of julia
export PATH="$HOME/Software/julia-current/bin:$PATH"

# FASD
if which fasd &> /dev/null; then
    eval "$(fasd --init auto)"
fi

# keys for xmodmap
if [ -f $HOME/.Xmodmap ]; then
    xmodmap ~/.Xmodmap
fi

# Use ripgrep as default grep in fzf (and fzf.vim)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'

# Start the ssh-agent if there is no gnome-keyring started already
if ! pgrep -u "$USER" gnome-keyring-daemon > /dev/null; then
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
    fi
    if [[ ! "$SSH_AUTH_SOCK" ]]; then
        source "$XDG_RUNTIME_DIR/ssh-agent.env" > /dev/null
    fi
fi
