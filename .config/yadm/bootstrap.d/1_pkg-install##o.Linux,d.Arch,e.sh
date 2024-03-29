echo "Installing yay"
sudo pacman -S --noconfirm go
git clone https://aur.archlinux.org/yay.git
(cd yay && makepkg -sic --noconfirm)

echo "Installing X, GPU drivers and LightDM"
yay -S --noconfirm xorg lightdm lightdm-gtk-greeter mesa
sudo systemctl enable lightdm

echo "Installing python and LaTeX"
yay -S --noconfirm python python-pip ipython go

echo "Installing fonts"
yay -S --noconfirm ttf-ms-fonts noto-fonts noto-fonts-emoji noto-fonts-emoji-flags gnu-free-fonts noto-fonts-cjk ttf-ubuntu-font-family ttf-victor-mono ttf-fira-code nerd-fonts-jetbrains-mono

echo "Setting up shell"
yay -S --noconfirm zsh ripgrep htop neofetch starship direnv

echo "Installing DEs/WMs and other relevant tools"
yay -S --noconfirm qtile bspwm openbox sxhkd awesome
yay -S --noconfirm autorandr feh picom kitty maim python-xlib rofi viewnior betterlockscreen gnome-keyring nemo brightnessctl wireless_tools bmon ntfs-3g gvfs-mtp numlockx lightdm-gtk-greeter-settings

echo "Installing Themes"
yay -S --noconfirm lxappearance vimix-cursors vimix-gtk-themes vimix-icon-theme redshift redshiftgui-bin

echo "Installing Pulseaudio"
yay -S --noconfirm sof-firmware alsa-card-profiles alsa-firmware alsa-lib alsa-plugins alsa-topology-conf alsa-ucm-conf alsa-utils lib32-pipewire pipewire pipewire-audio pipewire-pulse  wireplumber pasystray pavucontrol

echo "Installing various tools"
yay -S --noconfirm bolt ffmpeg zerotier-one python-psutil dnsutils brightnessctl youtube-dl netdiscover cups cups-pdf jpegoptim nmon openssh optipng pkgstats sshfs ufw unrar unzip usbutils wine wine-mono wine-gecko winetricks
yay -S --noconfirm vlc file-roller firefox vivaldi vivaldi-ffmpeg-codecs thunderbird discord teamviewer steam-native-runtime gimp inkscape krita pdfchain code code-marketplace neovim minecraft-launcher audacity qbittorrent libreoffice-fresh libreoffice-extension-texmaths libreoffice-extension-writer2latex libreoffice-fresh-cs

echo "Enabling services"
sudo systemctl enable lightdm.service
sudo systemctl enable zerotier-one.service

echo "Changing user shell to zsh"
sudo chsh $USER -s $(which zsh)
