#
# ~/.bash/functions.bash
#
# User defined functions

function avestc {
    ave -s " " -k $@ | column -s, -t
}

export -f avestc

function aveez {
    ave $@ | column -s, -t
}

export -f aveez

