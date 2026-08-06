#!/usr/bin/env sh
# Backlight control with notifications.

print_error ()
{
cat << "EOF"
    ./brightnesscontrol.sh <action>
    ...valid actions are...
        i -- <i>ncrease brightness [+5%]
        d -- <d>ecrease brightness [-5%]
EOF
}

send_notification ()
{
    brightness=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)")
    brightinfo=$(brightnessctl info | awk -F "'" '/Device/ {print $2}')
    bar=$(seq -s "." $(($brightness / 15)) | sed 's/[0-9]//g')
    notify-send -a "t2" -r 91190 -t 800 -i "display-brightness" "${brightness}${bar}" "${brightinfo}"
}

get_brightness ()
{
    brightnessctl -m | grep -o '[0-9]\+%' | head -c-2
}

case $1 in
i)  if [ "$(get_brightness)" -lt 10 ] ; then
        # increase the backlight by 1% if less than 10%
        brightnessctl set +1%
    else
        brightnessctl set +5%
    fi
    send_notification ;;
d)  if [ "$(get_brightness)" -le 1 ] ; then
        # avoid 0% brightness
        brightnessctl set 1%
    elif [ "$(get_brightness)" -le 10 ] ; then
        brightnessctl set 1%-
    else
        brightnessctl set 5%-
    fi
    send_notification ;;
*)  print_error ;;
esac
