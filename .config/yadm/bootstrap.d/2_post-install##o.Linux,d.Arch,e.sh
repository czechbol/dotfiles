# prompt if the user wants to decrypt files in the yadm repository
clear
read -r -p "Do you want to decrypt files in the yadm repository? (y/n)" decrypt
decrypt=${decrypt:-n}

if [[ $decrypt == "y" ]]; then
    yadm decrypt
fi

yadm decrypt
mkdir -p ~/Pictures/Screenshots
ln -s ~/Pictures/Screenshots ~/Pictures/screenshots
mkdir -p ~/Pictures/backgrounds/desktop
ln -s ~/Projects/Personal/tokyonight-backgrounds ~/Pictures/backgrounds/desktop/tokyo-night

read -r -p "Setup is done. Press Enter to reboot or press Ctrl+C to cancel."
sudo reboot
