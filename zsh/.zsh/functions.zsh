#
# ~/.zsh/functions.zsh
#
# User defined functions

function auradd {
    cp -L -t $AURREPODIR $1
    repo-add $AURREPO $AURREPODIR/$(basename $1)
}
