#!/usr/bin/env sh
# Volume control for output/input devices and players, with notifications.

print_error ()
{
cat << "EOF"
    ./volumecontrol.sh -[device] <actions>
    ...valid device are...
        i   -- input decive
        o   -- output device
        p   -- player application
    ...valid actions are...
        i   -- increase volume [+5]
        d   -- decrease volume [-5]
        m   -- mute [x]
EOF
exit 1
}

vol_icon ()
{
    if [ "${vol}" -eq 0 ]; then echo "audio-volume-muted"
    elif [ "${vol}" -lt 34 ]; then echo "audio-volume-low"
    elif [ "${vol}" -lt 67 ]; then echo "audio-volume-medium"
    else echo "audio-volume-high"
    fi
}

notify_vol ()
{
    bar=$(seq -s "." $(($vol / 15)) | sed 's/[0-9]//g')
    notify-send -a "t2" -r 91190 -t 800 -i "$(vol_icon)" "${vol}${bar}" "${nsink}"
}

notify_mute ()
{
    mute=$(pamixer "${srce}" --get-mute | cat)
    [ "${srce}" = "--default-source" ] && dvce="microphone" || dvce="audio-volume"
    if [ "${mute}" = "true" ] ; then
        notify-send -a "t2" -r 91190 -t 800 -i "${dvce}-muted" "muted" "${nsink}"
    else
        notify-send -a "t2" -r 91190 -t 800 -i "${dvce}-high" "unmuted" "${nsink}"
    fi
}

action_pamixer ()
{
    pamixer "${srce}" -"${1}" "${step}"
    vol=$(pamixer "${srce}" --get-volume | cat)
}

action_playerctl ()
{
    [ "${1}" = "i" ] && pvl="+" || pvl="-"
    playerctl --player="${srce}" volume 0.0"${step}""${pvl}"
    vol=$(playerctl --player="${srce}" volume | awk '{ printf "%.0f\n", $0 * 100 }')
}

while getopts iop: DeviceOpt
do
    case "${DeviceOpt}" in
    i) nsink=$(pamixer --list-sources | awk -F '"' 'END {print $(NF - 1)}')
        [ -z "${nsink}" ] && echo "ERROR: Input device not found..." && exit 0
        ctrl="pamixer"
        srce="--default-source" ;;
    o) nsink=$(pamixer --get-default-sink | awk -F '"' 'END{print $(NF - 1)}')
        [ -z "${nsink}" ] && echo "ERROR: Output device not found..." && exit 0
        ctrl="pamixer"
        srce="" ;;
    p) nsink=$(playerctl --list-all | grep -w "${OPTARG}")
        [ -z "${nsink}" ] && echo "ERROR: Player ${OPTARG} not active..." && exit 0
        ctrl="playerctl"
        srce="${nsink}" ;;
    *) print_error ;;
    esac
done

shift $((OPTIND -1))
step="${2:-5}"

case "${1}" in
    i) action_${ctrl} i ;;
    d) action_${ctrl} d ;;
    m) "${ctrl}" "${srce}" -t && notify_mute && exit 0 ;;
    *) print_error ;;
esac

notify_vol
