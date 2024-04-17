#!/bin/bash

# download the rest of the scripts
curl -LJO https://raw.githubusercontent.com/czechbol/dotfiles/main/.config/yadm/arch-install/diskpart.sh
curl -LJO https://raw.githubusercontent.com/czechbol/dotfiles/main/.config/yadm/arch-install/pacstrap.sh
curl -LJO https://raw.githubusercontent.com/czechbol/dotfiles/main/.config/yadm/arch-install/chroot.sh

# start the installation
bash diskpart.sh

# clean up
rm /mnt/chroot.sh
