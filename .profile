#
# ~/.profile
#

# setting the PATH envirorment variable
export PATH="$HOME/.local/bin:usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/core_perl:$PATH"

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
export BROWSER="firefox"

# Default terminal emulator
export TERMINAL="urxvtc"

# SSH Askpass
export SSH_ASKPASS=ssh-askpass

