sudo dnf -y install \
    python3 python3-pip ipython texlive-scheme-basic texlive-cite texlive-latexindent latexmk cmake sqlite rust cargo ansible podman git-delta \
    'google-roboto*' 'mozilla-fira*' fira-code-fonts \
    kitty neovim zsh ripgrep htop neofetch direnv unzip p7zip p7zip-plugins unrar tlp tlp-rdw ImageMagick dnf-utils wine winetricks \
    qdirstat blender gimp inkscape gparted vlc \
    gnome-extensions-app rpi-imager gnome-tweak-tool \
    codium vivaldi-stable

curl -sS https://raw.githubusercontent.com/starship/starship/master/install/install.sh | sh

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.spotify.Client com.discordapp.Discord

sudo chsh -s $(which zsh) $USER
gsettings set org.gnome.desktop.input-sources show-all-sources true

sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
