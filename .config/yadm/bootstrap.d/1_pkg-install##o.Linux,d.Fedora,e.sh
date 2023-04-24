sudo dnf -y install \
    python3 python3-pip ipython texlive-scheme-basic texlive-cite texlive-latexindent latexmk cmake sqlite ansible podman \
    'google-roboto*' 'mozilla-fira*' fira-code-fonts \
    kitty neovim zsh ripgrep htop neofetch direnv unzip p7zip p7zip-plugins unrar tlp tlp-rdw ImageMagick dnf-utils wine winetricks \
    qdirstat blender gimp inkscape gparted vlc \
    gnome-extensions-app rpi-imager gnome-tweak-tool \
    codium vivaldi-stable

curl -sS https://starship.rs/install.sh | sh

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.spotify.Client com.discordapp.Discord

gsettings set org.gnome.desktop.input-sources show-all-sources true

sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
