#!/bin/bash

cryptdevice=""

function parse_arguments() {
    while getopts ":he:p:" opt; do
        case $opt in
            h) display_help
            exit 0;;
            e) encrypted_partition=$OPTARG;;
            p) pv_name=$OPTARG;;
            \?) echo "Invalid option -$OPTARG" >&2;;
        esac
    done
}

echo "encrypted_partition=$encrypted_partition, pv_name=$pv_name"


function display_help() {
    echo "Usage: $0 [-e  <encrypted-partition> -p <physical-volume>]"
    echo "Options:"
    echo "  -e    If you are using an encrypted disk partition, specify the path to the encrypted partition."
    echo "  -p    If you are using an encrypted disk partition, specify the name of the physical volume."
}

function check_options() {
    if [[ ( -n $encrypted_partition && -z $pv_name ) || ( -z $encrypted_partition && -n $pv_name ) ]]; then
        echo "Both -e and -p options must be provided together."
        exit 1
    fi
}

function set_cryptdevice() {
    if [ -n "$encrypted_partition" ]; then
        if [[ $encrypted_partition == *"nvme"* ]]; then
            cryptdevice=${encrypted_partition}:${pv_name}:allow-discards
        else
            cryptdevice=${encrypted_partition}:${pv_name}
        fi
    fi
}

function generate_fstab() {
    genfstab -U /mnt >> /mnt/etc/fstab
}

function mount_efi_system_partition() {
    esp=$(lsblk -lpno NAME,FSTYPE | grep "vfat" | awk '{print $1}')
    mkdir -p /mnt/boot/EFI
    mount "$esp" /mnt/boot/EFI
}

function select_kernel() {
    while true; do
        clear
        echo "Select the kernel to install:"
        echo "1) linux"
        echo "2) linux-lts"
        echo "3) linux-hardened"
        echo "4) linux-zen"
        read -r -p "Enter the number of your choice: " kernel_choice
        
        case $kernel_choice in
            1) kernel="linux"; break ;;
            2) kernel="linux-lts"; break ;;
            3) kernel="linux-hardened"; break ;;
            4) kernel="linux-zen"; break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

function set_ntp() {
    timedatectl set-ntp true
}

function install_essential_packages() {
    pacstrap /mnt base "$kernel" "$kernel"-headers linux-firmware git lsb-release nano
}

function change_root_into_new_system() {
    if [[ -n $cryptdevice ]]; then
        sed -i "s|cryptdevice=\"\"|cryptdevice=\"$cryptdevice\"|" chroot.sh
    fi
    mv chroot.sh /mnt/chroot.sh
    arch-chroot /mnt sh /chroot.sh
}

function reboot_system() {
    echo "Base installation complete. You can now reboot into the system and run 'yadm bootstrap' to finish the installation."
    read -r -p "Press Enter to reboot or press Ctrl+C to cancel."
    reboot
}

parse_arguments
check_options
set_cryptdevice
echo "cryptdevice=$cryptdevice"
read -r -p "Continue?"
generate_fstab
mount_efi_system_partition
select_kernel
prompt_for_user_input
export_variables
set_ntp
generate_fstab
install_essential_packages
change_root_into_new_system
reboot_system
