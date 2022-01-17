#!/usr/bin/env bash

compton --vsync opengl-swc --backend glx &
autorandr --change
source /etc/profile
export PATH="$HOME/.local/bin:$PATH"
feh --recursive --randomize --bg-fill --no-fehbg ~/Pictures/backgrounds/desktop/tokyo-night/
setxkbmap -layout cz -variant coder
