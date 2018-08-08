#
# ~/.zsh/functions.zsh
#
# User defined functions

# swap two files
function swap() {
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE && mv "$2" "$1" && mv $TMPFILE $2
}
