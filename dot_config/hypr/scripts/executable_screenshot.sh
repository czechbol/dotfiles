#!/usr/bin/env sh

export confDir="${XDG_CONFIG_HOME:-$HOME/.config}"

# Restores the shader after screenshot has been taken
restore_shader() {
    if [ -n "$shader" ]; then
        hyprshade on "$shader"
    fi
}

# Saves the current shader and turns it off
save_shader() {
    shader=$(hyprshade current)
    hyprshade off
    trap restore_shader EXIT
}

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

    swpy_dir="${confDir}/swappy"
    save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
    save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
    temp_screenshot="/tmp/screenshot.png"

    mkdir -p "$save_dir"
    mkdir -p "$swpy_dir"
    printf "[Default]\nsave_dir=%s\nsave_filename_format=%s\n" "$save_dir" "$save_file" >"$swpy_dir/config"
}

# Function to handle different actions
handle_action() {
    case $1 in
        p) # print all outputs
            grimblast copysave screen "$temp_screenshot" && restore_shader && swappy -f "$temp_screenshot" ;;
        s) # drag to manually snip an area / click on a window to print it
            grimblast copysave area "$temp_screenshot" && restore_shader && swappy -f "$temp_screenshot" ;;
        sf) # frozen screen, drag to manually snip an area / click on a window to print it
            grimblast --freeze copysave area "$temp_screenshot" && restore_shader && swappy -f "$temp_screenshot" ;;
        m) # print focused monitor
            grimblast copysave output "$temp_screenshot" && restore_shader && swappy -f "$temp_screenshot" ;;
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
save_shader # Saving the current shader
setup_directories "$0" # Set up directories and filenames
handle_action "$1" # Handle the action based on the input argument
cleanup_temp_screenshot # Clean up temporary screenshot
notify_user # Notify user if the screenshot was saved
