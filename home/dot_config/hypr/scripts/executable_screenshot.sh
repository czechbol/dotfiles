#!/usr/bin/env sh

export confDir="${XDG_CONFIG_HOME:-$HOME/.config}"

# Function to print error message
print_error() {
    cat <<"EOF"
    ./screenshot.sh <action>
    ...valid actions are...
        p  : print all screens
        s  : snip current screen
        sf : snip current screen (frozen)
        m  : print focused monitor
EOF
}

# Function to set up directories and filenames
setup_directories() {
    if [ -z "$XDG_PICTURES_DIR" ]; then
        XDG_PICTURES_DIR="$HOME/Pictures"
    fi

    save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
    save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
    temp_screenshot=$(mktemp -t screenshot_XXXXXX.png)

    mkdir -p "$save_dir"
}

setup_editor() {
    if command -v satty >/dev/null; then
        editor=satty
    elif command -v swappy >/dev/null; then
        editor=swappy
    else
        notify-send "Screenshot" "Editor missing\nInstall satty or swappy"
        exit 1
    fi
}

# Launch the editor only on a valid, non-empty capture; otherwise notify.
# grimblast can produce an empty/invalid PNG (e.g. --freeze race), which
# makes satty/swappy fail to load the image and exit without a window.
open_editor() {
    if [ -s "$temp_screenshot" ]; then
        "$editor" -f "$temp_screenshot"
    else
        notify-send "Screenshot" "Capture failed (empty grab)"
    fi
}

# Function to handle different actions
handle_action() {
    case $1 in
        p) # print all outputs
            grimblast save screen "$temp_screenshot" && open_editor ;;
        s) # drag to manually snip an area / click on a window to print it
            grimblast save area "$temp_screenshot" && open_editor ;;
        sf) # frozen screen, drag to manually snip an area / click on a window to print it
            grimblast --freeze save area "$temp_screenshot" && open_editor ;;
        m) # print focused monitor
            grimblast save output "$temp_screenshot" && open_editor ;;
        *) # invalid option
            print_error ;;
    esac
}

# Function to clean up temporary screenshot if it exists
cleanup_temp_screenshot() {
    if [ -f "$temp_screenshot" ]; then
        rm "$temp_screenshot"
    fi
}

# Function to notify user if the screenshot was saved
notify_user() {
    if [ -f "${save_dir}/${save_file}" ]; then
        save_dir=$(echo "$save_dir" | sed "s|$HOME|~|")
        notify-send -a "t1" -i "${save_dir}/${save_file}" "saved in ${save_dir}"
    fi
}

# Main script execution
# Clear leftovers from a previously killed grab so this run isn't wedged:
# grimblast's lock is only removed by its EXIT trap, which SIGKILL skips.
if ! pgrep -x grimblast >/dev/null 2>&1; then
    rm -f "${XDG_RUNTIME_DIR:-$HOME/.cache}/grimblast.lock"
    pkill -x hyprpicker 2>/dev/null # orphaned freeze layer
fi
setup_directories "$0" # Set up directories and filenames
setup_editor
handle_action "$1" # Handle the action based on the input argument
cleanup_temp_screenshot # Clean up temporary screenshot
notify_user # Notify user if the screenshot was saved
