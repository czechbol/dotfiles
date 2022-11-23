#!/usr/bin/env bash

source /etc/profile
export PATH="$HOME/.local/bin:$PATH"
export TERM=kitty
setxkbmap -layout cz -variant coder
brightnessctl --device='tpacpi::kbd_backlight' -q set 2

autorandr --change && \
qtile shell -c "reload_config()" & \
feh --recursive --randomize --bg-center --image-bg "#1e1e2e" ~/Pictures/backgrounds/desktop/catppuccin-wallpapers/* & \
picom & \
pasystray & \
/usr/lib/geoclue-2.0/demos/agent & \
redshift-gtk & \


