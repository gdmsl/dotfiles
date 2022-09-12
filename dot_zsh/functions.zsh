#
# ~/.zsh/functions.zsh
#
# User defined functions

# swap two files
function swap() {
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE && mv "$2" "$1" && mv $TMPFILE $2
}

# cd 
function cdclip() {
    dir=$(xclip -o)
    if read -q REPLY\?"Change directory to $dir? [y/N] "; then
        cd "$dir"
    fi
}
