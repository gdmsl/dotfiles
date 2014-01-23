# Setting $PATH envirorment variable.
# TODO: move latex path to be avaiable system-wide
typeset -U path
path=(~/Bin ~/.local/bin /usr/local/texlive/2013/bin/x86_64-linux $path)

# Experience tell me that it's rather impossible to make vdpau
# .. work with my discrete nvidia with OPTIMUS. So maybe i can make use
# .. of hardware acceleration with my Intel card
export VDPAU_DRIVER=va_gl

# Enabling AntiAliasing for applications using the
# .. java virtual machine.
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'
