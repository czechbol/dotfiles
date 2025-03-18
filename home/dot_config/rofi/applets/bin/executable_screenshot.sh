#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Save and restore shader functions
restore_shader() {
    if [ -n "$shader" ]; then
        hyprshade on "$shader"
    fi
}

save_shader() {
    shader=$(hyprshade current)
    hyprshade off
    trap restore_shader EXIT
}

save_shader # Saving the current shader

# Set up directories and filenames
if [ -z "$XDG_PICTURES_DIR" ]; then
    XDG_PICTURES_DIR="$HOME/Pictures"
fi

swpy_dir="$HOME/.config/swappy"
save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
temp_screenshot="/tmp/screenshot.png"

mkdir -p $save_dir
mkdir -p $swpy_dir
echo -e "[Default]\nsave_dir=$save_dir\nsave_filename_format=$save_file" >$swpy_dir/config

# Theme Elements
prompt='Screenshot'
mesg="DIR: $save_dir"

if [[ "$theme" == *'type-1'* ]]; then
    list_col='1'
    list_row='5'
    win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
    list_col='1'
    list_row='5'
    win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
    list_col='1'
    list_row='5'
    win_width='520px'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
    list_col='5'
    list_row='1'
    win_width='670px'
fi

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
    option_1=" Capture Desktop"
    option_2=" Capture Area"
    option_3=" Capture Window"
    option_4=" Capture in 5s"
    option_5=" Capture in 10s"
    option_6=" Capture All Screens"
    option_7=" Capture Area (Frozen)"
    option_8=" Capture Focused Monitor"
else
    option_1=""
    option_2=""
    option_3=""
    option_4=""
    option_5=""
    option_6=""
    option_7=""
    option_8=""
fi

# Rofi CMD
rofi_cmd() {
    rofi -theme-str "window {width: $win_width;}" \
        -theme-str "listview {columns: $list_col; lines: $list_row;}" \
        -theme-str 'textbox-prompt-colon {str: "";}' \
        -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        -markup-rows \
        -theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6\n$option_7\n$option_8" | rofi_cmd
}

# notify and view screenshot
notify_view() {
    notify_cmd_shot='notify-send -u low'
    ${notify_cmd_shot} "Copied to clipboard."
    viewnior ${dir}/"$file"
    if [[ -e "$dir/$file" ]]; then
        ${notify_cmd_shot} "Screenshot Saved."
    else
        ${notify_cmd_shot} "Screenshot Deleted."
    fi
}

# Copy screenshot to clipboard
copy_shot () {
    tee "$file" | xclip -selection clipboard -t image/png
}

# countdown
countdown () {
    for sec in `seq $1 -1 1`; do
        notify-send -t 1000 "Taking shot in : $sec"
        sleep 1
    done
}

# take shots
shotnow () {
    cd ${dir} && sleep 0.5 && grimblast save screen "$file" && grimblast copy screen
    notify_view
}

shot5 () {
    countdown '5'
    sleep 1 && cd ${dir} && grimblast save screen "$file" && grimblast copy screen
    notify_view
}

shot10 () {
    countdown '10'
    sleep 1 && cd ${dir} && grimblast save screen "$file" && grimblast copy screen
    notify_view
}

shotwin () {
    cd ${dir} && grimblast save active "$file" && grimblast copy active
    notify_view
}

shotarea () {
    cd ${dir} && grimblast save area "$file" && grimblast copy area
    notify_view
}

shotallscreens () {
    cd ${dir} && grimblast copysave screen $temp_screenshot && restore_shader && swappy -f $temp_screenshot
    notify_view
}

shotareafrozen () {
    cd ${dir} && grimblast --freeze copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot
    notify_view
}

shotfocusedmonitor () {
    cd ${dir} && grimblast copysave output $temp_screenshot && restore_shader && swappy -f $temp_screenshot
    notify_view
}

# Execute Command
run_cmd() {
    if [[ "$1" == '--opt1' ]]; then
        shotnow
    elif [[ "$1" == '--opt2' ]]; then
        shotarea
    elif [[ "$1" == '--opt3' ]]; then
        shotwin
    elif [[ "$1" == '--opt4' ]]; then
        shot5
    elif [[ "$1" == '--opt5' ]]; then
        shot10
    elif [[ "$1" == '--opt6' ]]; then
        shotallscreens
    elif [[ "$1" == '--opt7' ]]; then
        shotareafrozen
    elif [[ "$1" == '--opt8' ]]; then
        shotfocusedmonitor
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
        run_cmd --opt1
        ;;
    $option_2)
        run_cmd --opt2
        ;;
    $option_3)
        run_cmd --opt3
        ;;
    $option_4)
        run_cmd --opt4
        ;;
    $option_5)
        run_cmd --opt5
        ;;
    $option_6)
        run_cmd --opt6
        ;;
    $option_7)
        run_cmd --opt7
        ;;
    $option_8)
        run_cmd --opt8
        ;;
esac

# Clean up temporary screenshot if it exists
if [ -f "$temp_screenshot" ]; then
    rm "$temp_screenshot"
fi

if [ -f "${save_dir}/${save_file}" ]; then
    save_dir="${save_dir/$HOME/"~"}"
    notify-send -a "t1" -i "${save_dir}/${save_file}" "saved in ${save_dir}"
fi
