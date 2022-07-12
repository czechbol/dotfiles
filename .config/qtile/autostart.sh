#!/usr/bin/env bash

autorandr --change
feh --recursive --randomize --bg-center --image-bg "#24283b" ~/Pictures/backgrounds/desktop/tokyo-night/**/1920x1080/
picom &
pasystray &
source /etc/profile
export PATH="$HOME/.local/bin:$PATH"
export TERM=kitty
setxkbmap -layout cz -variant coder
brightnessctl --device='tpacpi::kbd_backlight' -q set 2

/opt/piavpn/bin/pia-client %u --quiet &
