# Start gnome keyring
if [ -n "$DESKTOP_SESSION" ]; then
    eval $(gnome-keyring-daemon --start)
    echo "STARTING GNOME KEYRING"
    export SSH_AUTH_SOCK
fi
