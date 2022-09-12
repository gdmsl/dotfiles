#!/bin/bash

if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "Installing Tmux TPM plugin"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
