#!/bin/bash

export VCPKG_ROOT="$HOME/.local/share/vcpkg"

if [ ! -d "$VCPKG_ROOT" ]; then
    echo "Installing VCPKG files"
    git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
fi
