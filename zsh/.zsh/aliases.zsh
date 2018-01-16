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

# git is a 3 letter word and so git-annex should be
alias anx='git-annex'

# shut down the system
alias ggwp='systemctl poweroff'
alias gg='systemctl reboot'

# download url from clipboard
alias downclip='wget $(xsel -b)'
alias videoclip='youtube-dl "$(xsel -b)"'

alias yolo='pacaur -Syua'

# jrnl skyp history
alias jrnl=' jrnl'

# neovim diff
alias nvimdiff='nvim -d'

# pqiv
alias pqiv="pqiv --bind-key='d { command(mkdir -p .pqiv-trash; mv \$1 .pqiv-trash); goto_earlier_file(); goto_file_relative(1) }'"

# config mimeapps.list
alias mimeconfig="nvim ~/.config/mimeapps.list ~/.local/share/applications/mimeapps.list"

