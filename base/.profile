#
# ~/.profile
#

# setting the PATH envirorment variable
export PATH="$HOME/.local/bin:/usr/local/texlive/2015/bin/x86_64-linux:$HOME/.local/bin:/usr/local/texlive/2014/bin/x86_64-linux:$HOME/.cabal/bin:$PATH"

# Experience tell me that it's rather impossible to make vdpau
# .. work with my discrete nvidia with OPTIMUS. So maybe i can make use
# .. of hardware acceleration with my Intel card
if [ "$HOST" = "rubick" ]; then
    export VDPAU_DRIVER=va_gl
elif [ "$HOST" = "spectre" ]; then
    export VDPAU_DRIVER=nvidia
elif [ "$HOST" = "qop" ]; then
    export VDPAU_DRIVER=va_gl
fi

# I dunno.... :)
export GDK_USE_XFT=1

# Enabling AntiAliasing for applications using the
# .. java virtual machine and use gtk default look and feel
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

# Default text editor
export EDITOR="nvim"

# Default browser
export BROWSER="chromium"

# Default terminal emulator
export TERMINAL="termite"

# SSH Askpass
export SSH_ASKPASS=/usr/lib/ssh/x11-ssh-askpass

# QT5 style
export QT_STYLE_OVERRIDE='gtk2'

# Ruby
export GEM_HOME=$(ruby -e 'print Gem.user_dir')
export PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"


# usefull paths
export TOOLSPATH=$HOME/Develop/tools
export I3SESSIONS=$HOME/Arch/i3sessions
