#!/usr/bin/env bash

if grep open /proc/acpi/button/lid/LID0/state; then
    hyprctl keyword monitor "eDP-1, 2560x1600@120, 0x0, 1.25"
    hyprctl keyword "device[elan901c:00-04f3:2f18]:enabled" true
else
    if [[ $(hyprctl monitors | grep -c "Monitor") != 1 ]]; then
        hyprctl keyword monitor "eDP-1, disable"
        hyprctl keyword "device[elan901c:00-04f3:2f18]:enabled" false
    fi
fi
