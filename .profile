#
# ~/.profile
#

# setting the PATH envirorment variable
export PATH="$HOME/Bin:$HOME/.local/bin:/usr/local/texlive/2013/bin/x86_64-linux:$PATH"

# Experience tell me that it's rather impossible to make vdpau
# .. work with my discrete nvidia with OPTIMUS. So maybe i can make use
# .. of hardware acceleration with my Intel card
export VDPAU_DRIVER=va_gl

# Enabling AntiAliasing for applications using the
# .. java virtual machine.
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'

# Default text editor
export EDITOR="vim"

# Default browser
export BROWSER="firefox"

# Default terminal emulator
export TERMINAL="uxterm"

