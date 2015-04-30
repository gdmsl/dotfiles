#
# ~/.zsh/aliases.zsh
#
# User defined aliases

alias feh='feh --draw-tinted --force-aliasing --image-bg black --scale-down'
alias twitter="ttytter -ssl -dostream -readline -ansi -newline -exts=$HOME/.ttytter/ttytter-extension/oxhak_ttytter_output.pl"
alias :q='exit'

# Pacnam ehm.... Pamcan ..... ok.... pacman aliases
alias pacnam='pacman'
alias pamcan='pacman'
alias pacmna='pacman'

# funny
alias fuck='$(thefuck $(fc -ln -1))'
alias fuckoff='$(thefuck $(fc -ln -1))'
alias pls='$(thefuck $(fc -ln -1))'
alias please='$(thefuck $(fc -ln -1))'

#remote
alias onida='DISPLAY=192.168.0.194:0'
alias idampv='DISPLAY=192.168.0.194:0 mpv --mute=yes'


# git is a 3 letter word and so git-annex should be
alias anx='git-annex'
