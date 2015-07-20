#
# ~/.profile
#

# setting the PATH envirorment variable
export PATH="$HOME/.local/bin:/usr/local/texlive/2014/bin/x86_64-linux:$HOME/.cabal/bin:$PATH"

# Experience tell me that it's rather impossible to make vdpau
# .. work with my discrete nvidia with OPTIMUS. So maybe i can make use
# .. of hardware acceleration with my Intel card
export VDPAU_DRIVER=va_gl

# I dunno.... :)
export GDK_USE_XFT=1

# Enabling AntiAliasing for applications using the
# .. java virtual machine and use gtk default look and feel
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

# Default text editor
export EDITOR="vim"

# Default browser
export BROWSER="chromium"

# Default terminal emulator
export TERMINAL="termite"

# SSH Askpass
export SSH_ASKPASS=/usr/lib/ssh/x11-ssh-askpass


# usefull paths
export TOOLSPATH=$HOME/Develop/tools
export I3SESSIONS=$HOME/Arch/i3sessions

