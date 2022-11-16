#!/usr/bin/env bash

autorandr --change && \
picom & \
pasystray & \
/usr/lib/geoclue-2.0/demos/agent & \
redshift-gtk & \


source /etc/profile
export PATH="$HOME/.local/bin:$PATH"
export TERM=kitty
setxkbmap -layout cz -variant coder
brightnessctl --device='tpacpi::kbd_backlight' -q set 2



