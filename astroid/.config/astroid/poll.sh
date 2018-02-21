#!/usr/bin/env bash
#
# poll.sh - An example poll script for astroid.
#
# Intended to be run by astroid. See the following link for more information:
# https://github.com/astroidmail/astroid/wiki/Polling
#
# In particular, in order for this script to be run by astroid, it needs to be
# located at ~/.config/astroid/poll.sh
#

MAILDIR="$HOME/var/mail"

# Exit as soon as one of the commands fail.
set -e

# check if we have a connection
if ! ping -w 1 -W 1 -c 1 mail.google.com; then
    echo "there is no internet connection"
    exit
fi

# check if .mail is mounted
if [ ! -d $MAILDIR ]; then
    echo "$MAILDIR does not seem to be mounted"
    exit
fi

# move the email
afew --move --all -v

# Fetch new mail.
mbsync -a

# Import new mail into the notmuch database.
notmuch new

# Run afew tag
afew --tag --new -v

# Here you can process the mail in any way you see fit. See the following link
# for examples:
# https://github.com/astroidmail/astroid/wiki/Processing-mail
