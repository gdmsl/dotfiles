#!/usr/bin/env bash

# Enable services for Hyprland session (WantedBy=graphical-session.target)
systemctl --user enable noctalia-shell.service
systemctl --user enable vicinae.service
systemctl --user enable cliphist.service
systemctl --user enable kanshi.service
systemctl --user enable hypridle.service
systemctl --user enable hyprpaper.service
systemctl --user enable hyprpolkitagent.service
