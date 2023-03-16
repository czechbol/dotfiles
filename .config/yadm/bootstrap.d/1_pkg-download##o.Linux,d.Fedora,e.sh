echo "max_parallel_downloads=10
fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf

sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
sudo dnf config-manager --add-repo https://repo.vivaldi.com/stable/vivaldi-fedora.repo
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf upgrade --refresh -y
sudo dnf update

dnf install --downloadonly \ 
    python3 python3-pip ipython texlive-scheme-basic texlive-cite texlive-latexindent latexmk cmake sqlite rust cargo ansible podman \
    'google-roboto*' 'mozilla-fira*' fira-code-fonts \
    kitty neovim zsh ripgrep htop neofetch direnv unzip p7zip p7zip-plugins unrar tlp tlp-rdw ImageMagick dnf-utils wine winetricks \
    qdirstat blender gimp inkscape gparted vlc \
    gnome-extensions-app rpi-imager gnome-tweak-tool \
    codium vivaldi-stable
