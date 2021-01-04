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

MAILDIR="$HOME/Mail"

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

if [ $? -ne 0 ]; then
    notify-send -u critical "Error on afew move"
    exit
fi

# Fetch new mail.
mbsync -a

if [ $? -ne 0 ]; then
    notify-send -u critical "Error on syncing emails with mbsync"
    exit
fi

# fetch gmail email
(
cd $MAILDIR/account.gmail

gmi sync

if [ $? -ne 0 ]; then
    notify-send -u critical "Error on syncing emails with gmi"
    exit
fi
)

# Import new mail into the notmuch database.
notmuch new

if [ $? -ne 0 ]; then
    notify-send -u critical "Error on updating notmuch database"
    exit
fi

# Run afew tag
afew --tag --new -v

if [ $? -ne 0 ]; then
    notify-send -u critical "Error on tagging new messages"
    exit
fi

# Desktop notifications
notifymuch

# Here you can process the mail in any way you see fit. See the following link
# for examples:
# https://github.com/astroidmail/astroid/wiki/Processing-mail
