#!/usr/bin/env bash

systemctl --user add-wants niri.service noctalia-shell.service
systemctl --user add-wants niri.service hyprpaper.service
systemctl --user add-wants niri.service hyprpolkitagent.service
