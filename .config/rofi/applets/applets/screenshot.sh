#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

style="$($HOME/.config/rofi/applets/applets/style.sh)"

dir="$HOME/.config/rofi/applets/applets/configs/$style"
rofi_command="rofi -theme $dir/screenshot.rasi"

# Error msg
msg() {
	rofi -theme "$HOME/.config/rofi/applets/styles/message.rasi" -e "Please install 'scrot' first."
}

# Options
screen=""
area=""
window=""

# Variable passed to rofi
options="$screen\n$area\n$window"

chosen="$(echo -e "$options" | $rofi_command -p 'maim' -dmenu -selected-row 1)"
case $chosen in
    $screen)
		if [[ -f /usr/bin/maim ]]; then
			filename=$(date +Screenshot_%Y-%m-%d_%H:%M:%S)
			path="$(xdg-user-dir PICTURES)/screenshots/$filename"
			maim -d 1 $path.png; viewnior $path.png
		else
			msg
		fi
        ;;
    $area)
		if [[ -f /usr/bin/maim ]]; then
			filename=$(date +Screenshot_%Y-%m-%d_%H:%M:%S)
			path="$(xdg-user-dir PICTURES)/screenshots/$filename"
			maim -s $path.png; viewnior $path.png
		else
			msg
		fi
        ;;
    $window)
		if [[ -f /usr/bin/maim ]]; then
			filename=$(date +Screenshot_%Y-%m-%d_%H:%M:%S)
			path="$(xdg-user-dir PICTURES)/screenshots/$filename"
			maim -d 1 -u -B -i "$(xdotool getactivewindow)" $path.png; viewnior $path.png
		else
			msg
		fi
        ;;
esac

