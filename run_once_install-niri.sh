#!/usr/bin/env bash

# Services bound to niri session (started when niri starts, stopped when it stops)
systemctl --user add-wants niri.service noctalia-shell.service
systemctl --user add-wants niri.service kanshi.service
systemctl --user add-wants niri.service hyprpolkitagent.service
systemctl --user add-wants niri.service vicinae.service
systemctl --user add-wants niri.service cliphist.service
systemctl --user add-wants niri.service niriswitcher.service
systemctl --user add-wants niri.service hypridle.service
