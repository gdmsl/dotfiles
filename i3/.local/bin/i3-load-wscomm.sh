#!/bin/bash

i3-msg "workspace \"11: -\"; append_layout $HOME/var/i3sessions/comm.json";

nohup termite --class="WeeChat" -e "zsh -c weechat" &
nohup telegram-desktop &
nohup skypeforlinux &

