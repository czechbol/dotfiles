#!/bin/bash

# ask for sudo password
read -r -s -p "Enter your sudo password: " sudo_password
echo "$sudo_password" | sudo -S echo "Thank you!"

echo -e "Setting grub theme"
# sudo mkdir -p /boot/grub/themes/
sudo tar -xf ~/.config/yadm/data/catppuccin-mocha-grub-theme.tar.gz -C /boot/grub/themes/
sudo sed -i "/^GRUB_DEFAULT=/c\GRUB_DEFAULT=saved
/^GRUB_GFXMODE=/c\GRUB_GFXMODE=1920x1080x32,auto
/^GRUB_THEME=/c\GRUB_THEME=\"/boot/grub/themes/catppuccin-mocha-grub-theme/theme.txt\"
/^#GRUB_THEME=/c\GRUB_THEME=\"/boot/grub/themes/catppuccin-mocha-grub-theme/theme.txt\"
/^#GRUB_SAVEDEFAULT=true/c\GRUB_SAVEDEFAULT=true" /etc/default/grub


sudo grub-mkconfig -o /boot/grub/grub.cfg

# package list
communication="discord"
development_tools="visual-studio-code-bin kitty starship code-marketplace neovim audacity qbittorrent"
email_clients="thunderbird"
file_management_tools="jpegoptim nmon file-roller optipng pkgstats sshfs ufw unrar unzip usbutils qt5-imageformats ffmpegthumbs kde-cli-tools kservice5 libnotify dolphin ark"
fonts="ttf-ms-fonts noto-fonts noto-fonts-emoji noto-fonts-emoji-flags gnu-free-fonts noto-fonts-cjk ttf-ubuntu-font-family ttf-victor-mono ttf-fira-code"
gaming="steam-native-runtime gamemode"
graphics_design_tools="gimp inkscape krita pdfchain"
media_players="vlc ffmpeg"
network_system_tools="bolt zerotier-one python-psutil bind youtube-dl netdiscover cups cups-pdf"
office_suite="libreoffice-fresh libreoffice-extension-texmaths libreoffice-extension-writer2latex libreoffice-fresh-cs"
pipewire_packages="lib32-pipewire pipewire pipewire-alsa pipewire-jack pipewire-audio pipewire-pulse gst-plugin-pipewire wireplumber pasystray pavucontrol pamixer"
remote_access=" teamviewer"P
web_browsers="firefox vivaldi"
wine_packages="wine wine-mono wine-gecko winetricks"

window_manager_utils="autorandr feh picom maim python-xlib rofi-lbonn-wayland-git waybar cliphist swappy grimblast-git slurp wlogout swww viewnior network-manager-applet gnome-keyring nemo mangohud cava qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects sddm udiskie brightnessctl wireless_tools bmon numlockx lightdm-gtk-greeter-settings dunst polkit-gnome xdg-desktop-portal-hyprland nwg-look qt5ct qt6ct"

# essential packages
packages="xorg lightdm lightdm-gtk-greeter mesa zsh"

# desktop environments and window managers
# multiselect options of desktop environments and window managers
read -r -p "Do you want to install a desktop environment? (y/n): " install_desktop
if [[ $install_desktop == "y" ]]; then
    declare -A desktops=(
        [1]="gnome gnome-tweaks"
        [2]="plasma"
        [3]="xfce4 xfce4-goodies"
        [4]="cinnamon"
        [5]="hyprland hyprpicker hyprcursor hyprlock hypridle"
        [6]="i3-wm i3status i3lock"
        [7]="awesome"
        [8]="bspwm sxhkd"
        [9]="qtile"
    )
    
    echo "Select the desktop environment or window manager you want to install:"
    
    for key in $(echo "${!desktops[@]}" | tr ' ' '\n' | sort -n); do
        echo "$key) $(echo "${desktops[$key]}" | cut -d ' ' -f 1)"
    done
    
    read -r -p "Enter all numbers separated by spaces: " desktop_choices
    for choice in $desktop_choices; do
        packages+=" ${desktops[$choice]}"
    done
    
    if [[ " ${desktop_choices[*]} " =~ " 2 " ]]; then
        declare -A kde_apps=(
            [1]="kde-accessibility-meta"
            [2]="kde-education-meta"
            [3]="kde-games-meta"
            [4]="kde-graphics-meta"
            [5]="kde-multimedia-meta"
            [6]="kde-network-meta"
            [7]="kde-office-meta"
            [8]="kde-pim-meta"
            [9]="kde-sdk-meta"
            [10]="kde-system-meta"
            [11]="kde-utilities-meta"
            [12]="kdevelop-meta"
        )
        
        echo "Select the KDE applications you want to install:"
        for key in $(echo "${!kde_apps[@]}" | tr ' ' '\n' | sort -n); do
            echo "$key) $(echo "${kde_apps[$key]}" | cut -d ' ' -f 1)"
        done
        
        read -r -p "Enter all numbers separated by spaces: " kde_app_choices
        for choice in $kde_app_choices; do
            packages+=" ${kde_apps[$choice]}"
        done
    fi
    
    # if there is a at least one number higher than 4 in the desktop_choices array selected, then install additional packages
    if [[ " ${desktop_choices[*]} " =~ "5" ]] || [[ " ${desktop_choices[*]} " =~ "6" ]] || [[ " ${desktop_choices[*]} " =~ "7" ]] || [[ " ${desktop_choices[*]} " =~ "8" ]] || [[ " ${desktop_choices[*]} " =~ "9" ]]; then
        packages+=" $window_manager_utils"
    fi
    
fi

# programming languages
# multiselect options of programming languages
# python, golang, rust, node, java, zig, etc.
read -r -p "Do you want to install programming languages? (y/n): " install_languages
if [[ $install_languages == "y" ]]; then
    declare -A languages=(
        [1]="go gopls goreleaser delve golangci-lint"
        [2]="python python-pip ipython"
        [3]="rust"
        [4]="nodejs npm yarn"
        [5]="zig zls"
        [6]="dart"
        [7]="ghc"
        [8]="kotlin"
    )
    
    echo "Select the programming languages you want to install:"
    for key in $(echo "${!languages[@]}" | tr ' ' '\n' | sort -n); do
        echo "$key) $(echo "${languages[$key]}" | cut -d ' ' -f 1)"
    done
    
    read -r -p "Enter all numbers separated by spaces: " language_choices
    for choice in $language_choices; do
        if [[ $choice == "7" ]]; then
            packages+=" ghc cabal-install"
        fi
        packages+=" ${languages[$choice]}"
    done
fi

# virtual machines
read -r -p "Is this a virtual machine? (y/n): " is_vm
if [[ $is_vm == "y" ]]; then
    packages+=" spice-vdagent"
fi

# additional packages
packages+=" $pipewire_packages $network_system_tools $file_management_tools $fonts $wine_packages $media_players $web_browsers $communication $email_clients $remote_access $gaming $graphics_design_tools $development_tools $office_suite"

# download the selected packages
echo "Installing the selected packages..."
if ! yay -Syu --needed --noconfirm $packages; then
    echo "Command failed, retrying without --noconfirm"
    yay -Syu --needed $packages
fi

# sddm
curl -O https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip
sudo tar -xf ./catppuccin-mocha.zip -C /usr/share/sddm/themes/
rm catppuccin-mocha.zip
sudo rm /etc/sddm.conf.d/kde_settings.conf
sudo cp /usr/share/sddm/themes/catppuccin-mocha/kde_settings.conf /etc/sddm.conf.d/

sudo systemctl enable sddm.service
sudo systemctl enable zerotier-one.service

# change user shell to zsh
sudo chsh "$USER" -s "$(which zsh)"

# install complete
echo "Installation complete."

read -r -p "Continue? (y/n): "
# End of file
