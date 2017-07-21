#
# ~/.zsh/functions.zsh
#
# User defined functions

function avestc {
    ave -s " " -k $@ | column -s, -t
}

export avestc

function aveez {
    ave $@ | column -s, -t
}

export aveez
