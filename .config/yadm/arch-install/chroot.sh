#!/bin/bash

cryptdevice=""


function prompt_for_user_input() {
    clear
    read -r -p "Please enter your timezone (default is Europe/Prague): " timezone
    timezone=${timezone:-Europe/Prague}
    read -r -p "Please enter your language (default is en_US): " locale
    locale=${locale:-en_US}
    locale=${locale}.UTF-8
    read -r -p "Please enter your country code (default is CZ): " country
    country=${country:-CZ}
    read -r -p "Please enter the hostname of this machine: " hostname
    read -r -p "Please enter your username: " username
    read -r -s -p "Please enter your password: " user_password
    echo
    read -r -s -p "Please enter the root password: " root_password
    echo
    read -r -p "Do you want to install an AUR helper? (y/n): " helper
    helper=${helper:-n}
    select_aur_helper
    read -r -p "Do you want to install yadm? (y/n): " yadm
    yadm=${yadm:-n}
    prompt_for_yadm_repo
}

function select_aur_helper() {
    if [[ $helper == "y" ]]; then
        echo "1. yay"
        echo "2. paru"
        echo "3. trizen"
        read -r -p "Please select a pacman helper: " aur_helper
        case $aur_helper in
            1) aur_helper=yay;;
            2) aur_helper=paru;;
            3) aur_helper=trizen;;
            *) aur_helper=yay;;
        esac
    fi
}

function prompt_for_yadm_repo() {
    if [[ $yadm == "y" ]]; then
        while true; do
            read -r -p "Please enter the URL of the yadm repository: " yadm_repo
            if git ls-remote "$yadm_repo" &> /dev/null; then
                break
            else
                echo "The repository is not clonable. Please enter a valid URL."
            fi
        done
    fi
}

function set_time_zone() {
    ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime
    hwclock --systohc
}

function set_locale() {
    sed -i "s/^#$locale UTF-8/$locale UTF-8/" /etc/locale.gen
    locale-gen
    echo "LANG=$locale" > /etc/locale.conf
}

function setup_pacman() {
    sed -i 's/^#Color/Color/' /etc/pacman.conf
    sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
    sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf
    sed -i '/\[multilib\]/{n;s/^#//}' /etc/pacman.conf
    pacman -Sy
    pacman -S --needed --noconfirm reflector
}

function generate_mirrorlist() {
    echo "Generating mirrorlist..."
    mkdir -p /etc/pacman.d
    reflector --country "$country" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
}

function install_packages() {
    if [[ -n $cryptdevice ]]; then
        pacman -Sy --needed --noconfirm intel-ucode base-devel nano networkmanager wpa_supplicant netctl dialog lvm2
    else
        pacman -Sy --needed --noconfirm intel-ucode base-devel nano networkmanager wpa_supplicant netctl dialog
    fi
    systemctl enable NetworkManager
}

function set_hostname() {
    echo "$hostname" > /etc/hostname
    echo "127.0.0.1   localhost" > /etc/hosts
    echo "::1         localhost" >> /etc/hosts
    echo "127.0.1.1   $hostname.localdomain $hostname" >> /etc/hosts
}

function setup_mkinitcpio() {
    if [[ -n $cryptdevice ]]; then
        sed -i 's/^HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf
        mkinitcpio -P
    fi
}

function create_user() {
    echo "Creating user and setting passwords"
    useradd -m -G wheel "$username"
    echo "$username:$user_password" | chpasswd
    echo "root:$root_password" | chpasswd
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
}

function install_boot_loader() {
    pacman -S --needed --noconfirm grub efibootmgr dosfstools mtools os-prober
    if [[ -n $cryptdevice ]]; then
        sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice='"$cryptdevice"'"/' /etc/default/grub
        sed -i 's/^#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
    else
        sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/' /etc/default/grub
    fi
    if grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
        sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
    else
        echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
    fi
    grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=ArchLinux --recheck
    mkdir -p /boot/grub/locale
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
    grub-mkconfig -o /boot/grub/grub.cfg
}

function install_pacman_helpers() {
    if [[ -v aur_helper ]]; then
        printf "aur   ALL = (root) NOPASSWD: /usr/bin/makepkg, /usr/bin/pacman" > /etc/sudoers.d/02_aur
        useradd -m aur || true
        su - aur -c bash -c "rm -rf /tmp/$aur_helper ; git clone https://aur.archlinux.org/$aur_helper.git /tmp/$aur_helper ; cd /tmp/$aur_helper ; makepkg -sic --noconfirm"
        if [[ -v yadm_repo ]]; then
            su - aur -c "$aur_helper -S --needed --noconfirm yadm"
            su - "$username" -c bash -c "cd ~ && yadm clone --no-bootstrap $yadm_repo && yadm alt"
        fi
        userdel -r aur
        rm /etc/sudoers.d/02_aur
    fi
}

prompt_for_user_input
set_time_zone
set_locale
setup_pacman
generate_mirrorlist
install_packages
set_hostname
setup_mkinitcpio
create_user
install_boot_loader
install_pacman_helpers
