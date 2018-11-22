#!/bin/bash

i3-msg "workspace \"11: IM\"; append_layout $HOME/Variable/i3sessions/comm.json";

nohup termite --class="WeeChat" -e "zsh -c weechat" &
nohup telegram-desktop &
nohup skypeforlinux &

