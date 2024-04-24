#!/bin/bash

# Get a list of disk names
mapfile -t disks < <(lsblk -dpno NAME | grep -v "part")

ENCRYPTED=false

# Generate a menu of disks
while true; do
    clear
    echo "Please select a disk to partition:"
    i=1
    for disk in "${disks[@]}"; do
        echo "$i) $disk"
        i=$((i+1))
    done
    echo "q) Quit"

    read -r -p "Enter your choice (1-$((i-1)), q to quit): " choice

    case $choice in
        [qQ])
            echo "Quitting the program."
            exit 0
        ;;
        *)
            if [[ $choice -ge 1 && $choice -lt $i ]]; then
                disk=${disks[$((choice-1))]}
                # Get the total disk size in GiB
                total_disk_size=$(lsblk -b "$disk" --output SIZE -n | head -n 1 | awk '{print $1/1024/1024/1024}')
                echo "You have selected disk: $disk"
                break
            else
                echo "Invalid selection. Please try again."
            fi
        ;;
    esac
done

# Ask the user for the partitioning method
function display_warning() {
    clear
    echo "WARNING: $1 partitioning will overwrite all current partitions on the disk."
    read -r -p "Are you sure you want to continue? (y/n): " confirm
    confirm=${confirm:-y}
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        confirm=""
        echo "You have selected $1 partitioning."
        return 0
    else
        confirm=""
        echo "Operation cancelled."
        return 1
    fi
}

function select_filesystem() {
    while true; do
        clear
        echo "Select the file system for the partitions:"
        echo "1) ext4"
        echo "2) btrfs"
        echo "3) xfs"
        read -r -p "Enter the number of your choice: " fs_choice

        case $fs_choice in
            1) fs="ext4"; break ;;
            2) fs="btrfs"; break ;;
            3) fs="xfs"; break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

function select_partition_sizes() {
    clear

    echo "Total disk size: ${total_disk_size}G"

    read -r -p "Enter the size for the EFI partition (e.g., 256M): " efi_size
    efi_size=${efi_size:-256M}

    read -r -p "Enter the size for the boot partition (e.g., 512M): " boot_size
    boot_size=${boot_size:-512M}

    read -r -p "Would you like to create a separate /home partition? (y/n): " separate_home
    separate_home=${separate_home:-n}
    if [[ $separate_home == [yY] || $separate_home == [yY][eE][sS] ]]; then
        read -r -p "Enter the size for the /root partition (e.g., 50G): " root_size
        separate_home="y"
        root_size=${root_size:-50G}
    fi

    read -r -p "Would you like to create a separate Docker partition? (y/n): " separate_docker
    separate_docker=${separate_docker:-n}
    if [[ $separate_docker == [yY] || $separate_docker == [yY][eE][sS] ]]; then
        read -r -p "Enter the size for the Docker partition (e.g., 20G): " docker_size
        separate_docker="y"
        docker_size=${docker_size:-20G}
    fi

    read -r -p "Would you like to create a separate Pacman cache partition? (y/n): " separate_pacman_cache
    separate_pacman_cache=${separate_pacman_cache:-n}
    if [[ $separate_pacman_cache == [yY] || $separate_pacman_cache == [yY][eE][sS] ]]; then
        read -r -p "Enter the size for the Pacman cache partition (e.g., 16G): " pacman_cache_size
        separate_pacman_cache="y"
        pacman_cache_size=${pacman_cache_size:-16G}
    fi

    read -r -p "Would you like to create a swap partition? (y/n): " create_swap
    create_swap=${create_swap:-n}
    if [[ $create_swap == [yY] ]]; then
        create_swap="y"
        # Get the system's RAM size in GiB
        ram_size=$(free -g | awk '/^Mem:/{print $2}')

        # Calculate the base-2 logarithm of the RAM size and round it to an integer
        log2_ram_size=$(echo "l( ${ram_size} ) / l( 2 )" | bc -l)
        log2_ram_size=$(printf "%.0f" "$log2_ram_size")

        # If the RAM size is not a power of 2, increment the exponent
        if (( $(echo "2 ^ $log2_ram_size < $ram_size" | bc -l) )); then
            log2_ram_size=$((log2_ram_size + 1))
        fi

        # Calculate the RAM size rounded up to the nearest power of 2
        ram_size=$(echo "2 ^ $log2_ram_size" | bc -l)

        read -r -p "Enter the size for the swap partition (e.g., ${ram_size}G): " swap_size
        swap_size=${swap_size:-${ram_size}G}
    fi
}

function display_partition_table() {
    # Show the user's selections in a table
    clear
    echo "Total disk size: $total_disk_size G"
    echo
    printf "%-15s %-15s %-15s %-10s\n" "Partition" "Size" "File System" "Encrypted"
    printf "%-15s %-15s %-15s %-10s\n" "EFI" "$efi_size" "fat32" "No"
    printf "%-15s %-15s %-15s %-10s\n" "boot" "$boot_size" "ext4" "No"
    if [[ $separate_home == [yY] ]]; then
        printf "%-15s %-15s %-15s %-10s\n" "root" "$root_size" "$fs" "$([[ $ENCRYPTED == true ]] && echo "Yes" || echo "No")"
    fi
    if [[ $separate_pacman_cache == [yY] ]]; then
        printf "%-15s %-15s %-15s %-10s\n" "pacman cache" "$pacman_cache_size" "$fs" "$([[ $ENCRYPTED == true ]] && echo "Yes" || echo "No")"
    fi
    if [[ $separate_docker == [yY] ]]; then
        printf "%-15s %-15s %-15s %-10s\n" "docker" "$docker_size" "$fs" "$([[ $ENCRYPTED == true ]] && echo "Yes" || echo "No")"
    fi
    if [[ $create_swap == [yY] ]]; then
        printf "%-15s %-15s %-15s %-10s\n" "swap" "$swap_size" "linux-swap" "$([[ $ENCRYPTED == true ]] && echo "Yes" || echo "No")"
    fi
    if [[ $separate_home != [yY] ]]; then
        printf "%-15s %-15s %-15s %-10s\n" "root" "Rest of disk" "$fs" "$([[ $ENCRYPTED == true ]] && echo "Yes" || echo "No")"
    fi
    if [[ $separate_home == [yY] ]]; then
        printf "%-15s %-15s %-15s %-10s\n" "home" "Rest of disk" "$fs" "$([[ $ENCRYPTED == true ]] && echo "Yes" || echo "No")"
    fi
}

function create_logical_volume() {
    local vg_name=$1
    local lv_name=$2
    local lv_size=$3
    local type=$3

    # use -L if the size is in bytes, -l if it's +100%FREE
    if [[ $lv_size == "100%FREE" ]]; then
        lvcreate -l "$lv_size" "$vg_name" -n "$lv_name"
    else
        lvcreate -L "$lv_size" "$vg_name" -n "$lv_name"
    fi

    if [ "$type" = "linux-swap" ]; then
        mkswap /dev/"$vg_name"/"$lv_name"
        swapon /dev/"$vg_name"/"$lv_name"
    else
        mkfs."$fs" /dev/"$vg_name"/"$lv_name"
    fi
}

function create_encrypted_partitions {
    local root_mounted=false
    # Create the root partition
    if [[ $separate_home != [yY] && $separate_docker != [yY] && $separate_pacman_cache != [yY] && $create_swap != [yY] ]]; then
        create_logical_volume $vg_name root 100%FREE "$fs"
        mount /dev/mapper/$vg_name-root /mnt
        return
    elif [[ $separate_home == [yY] ]]; then
        create_logical_volume $vg_name root "$root_size" "$fs"
        mount /dev/mapper/$vg_name-root /mnt
        root_mounted=true
    fi

    # Create the swap partition
    if [[ $create_swap == [yY] ]]; then
        create_logical_volume $vg_name swap "$swap_size" linux-swap
    fi

    # Create the pacman cache partition
    if [[ $separate_pacman_cache == [yY] ]]; then
        create_logical_volume $vg_name pacman_cache "$pacman_cache_size" "$fs"

        if [[ $root_mounted == true ]]; then
            mkdir -p /mnt/var/cache/pacman
            mount /dev/mapper/$vg_name-pacman_cache /mnt/var/cache/pacman
        fi
    fi

    # Create the docker partition
    if [[ $separate_docker == [yY] ]]; then
        create_logical_volume $vg_name docker "$docker_size" "$fs"

        if [[ $root_mounted == true ]]; then
            mkdir -p /mnt/var/lib/docker
            mount /dev/mapper/$vg_name-docker /mnt/var/lib/docker
        fi
    fi

    # Create the root partition last if the home partition isn't selected but any other is
    if [[ $separate_home != [yY] && ($separate_docker == [yY] || $separate_pacman_cache == [yY] || $create_swap == [yY]) ]]; then
        create_logical_volume $vg_name root 100%FREE "$fs"

        mount /dev/mapper/$vg_name-root /mnt

        if [[ $separate_pacman_cache == [yY] ]]; then
            mkdir -p /mnt/var/cache/pacman
            mount /dev/mapper/$vg_name-pacman_cache /mnt/var/cache/pacman
        fi

        if [[ $separate_docker == [yY] ]]; then
            mkdir -p /mnt/var/lib/docker
            mount /dev/mapper/$vg_name-docker /mnt/var/lib/docker
        fi

    fi

    # Create the home partition
    if [[ $separate_home == [yY] ]]; then
        create_logical_volume $vg_name home 100%FREE "$fs" /mnt/home

        mkdir -p /mnt/home
        mount /dev/mapper/$vg_name-home /mnt/home
    fi
}

function get_partition_index() {
    local disk_idx=$1

    if [[ $disk == *"nvme"* ]]; then
        echo "${disk}p${disk_idx}"
    else
        echo "${disk}${disk_idx}"
    fi
}

function unmount_and_swapoff() {
    root_partition=$(lsblk -lpno NAME,TYPE,MOUNTPOINT "$disk" | grep -E "part|lvm" | awk '$3=="/mnt"{print $1}')
    # loop through all partitions and unmount them
    for part in $(lsblk -lpno NAME,TYPE "$disk" | grep -E "part|lvm" | awk '{print $1}'); do
        # if the partition is mounted, unmount it
        if findmnt -l "$part"; then
            if [[ $part != "$root_partition" ]] && findmnt -l "$part"; then
                umount "$part"
            fi
            umount "$part"
        fi
    done

    if findmnt -l "$root_partition"; then
        umount "$root_partition"
    fi

    swapoff -a
}

function create_partition() {
    local size=$1
    local idx=$2
    local part_type=$3
    local part_fs=$4

    # Create partition using sgdisk
    sgdisk -n "$idx":0:+"$size" -t "$idx":"$part_type" "$disk"
    partprobe "$disk"

    part_path=$(get_partition_index "$idx")

    # save encrypted disk partition to a variable
    if [[ $ENCRYPTED ]]; then
        encrypted_partition=$part_path
    fi

    if [ "$part_type" = "8200" ]; then  # linux-swap type is 8200 in GPT
        mkswap "$part_path"
        swapon "$part_path"
        elif [ "$part_fs" = "fat32" ]; then
        mkfs.fat -F32 -I "$part_path"
    elif [ -n "$part_fs" ]; then
        # if block for different filesystems
        if [ "$part_fs" = "ext4" ]; then
            mkfs.ext4 -F "$part_path"
        elif [ "$part_fs" = "btrfs" ]; then
            mkfs.btrfs -f "$part_path"
        elif [ "$part_fs" = "xfs" ]; then
            mkfs.xfs -f "$part_path"
        fi
    fi
}

function create_unencrypted_partitions {
    local idx=3
    local root_mounted=false

    # Create the root partition
    if [[ $separate_home != [yY] && $separate_docker != [yY] && $separate_pacman_cache != [yY] && $create_swap != [yY] ]]; then
        create_partition 0 $idx "8300" "$fs"
        mount "$(get_partition_index $idx)" /mnt
        return
    elif [[ $separate_home == [yY] ]]; then
        create_partition "$root_size" $idx "8300" "$fs"
        mount "$(get_partition_index $idx)" /mnt
        idx=$((idx+1))
        root_mounted=true
    fi

    # Create the swap partition
    if [[ $create_swap == [yY] ]]; then
        create_partition "$swap_size" $idx "8200"
        idx=$((idx+1))
    fi

    # Create the pacman cache partition
    if [[ $separate_pacman_cache == [yY] ]]; then
        create_partition "$pacman_cache_size" $idx "8300" "$fs"
        if [[ $root_mounted == true ]]; then
            mkdir -p /mnt/var/cache/pacman
            mount "$(get_partition_index $idx)" /mnt/var/cache/pacman
        fi
        idx=$((idx+1))
    fi

    # Create the docker partition
    if [[ $separate_docker == [yY] ]]; then
        create_partition "$docker_size" $idx "8300" "$fs"
        if [[ $root_mounted == true ]]; then
            mkdir -p /mnt/var/lib/docker
            mount "$(get_partition_index $idx)" /mnt/var/lib/docker
        fi
        idx=$((idx+1))
    fi

    # Create the root partition last if the home partition isn't selected but any other is
    if [[ $separate_home != [yY] && ($separate_docker == [yY] || $separate_pacman_cache == [yY] || $create_swap == [yY]) ]]; then
        create_partition 0 $idx "8300" "$fs"
        mount "$(get_partition_index $idx)" /mnt
        if [[ $separate_pacman_cache == [yY] ]]; then
            mkdir -p /mnt/var/cache/pacman
            mount "$(get_partition_index "$((idx-1))")" /mnt/var/cache/pacman
        fi
        if [[ $separate_docker == [yY] ]]; then\
            mkdir -p /mnt/var/lib/docker
            mount "$(get_partition_index "$((idx-2))")" /mnt/var/lib/docker
        fi
    fi

    # Create the home partition
    if [[ $separate_home == [yY] ]]; then
        create_partition 0 $idx "8300" "$fs"
        mkdir -p /mnt/home
        mount "$(get_partition_index $idx)" /mnt/home
    fi
}

function create_partitions() {
    read -r -p "Are you sure you want to create these partitions? (y/n): " confirm
    if [[ $confirm == [yY] ]]; then
        confirm=""
        echo "Creating partitions..."
        unmount_and_swapoff
        # delete all partitions on the disk
        wipefs --all "$disk"
        sgdisk -Z "$disk"
        partprobe "$disk"

        # Create the EFI partition
        create_partition "$efi_size" 1 "ef00" "fat32"

        # Create the boot partition
        create_partition "$boot_size" 2 "8300" "ext4"


        if [[ $ENCRYPTED == true ]]; then
            # Create a 'Linux LVM' partition that spans the rest of the disk
            create_partition 0 3 "8e00"
            # Encrypt the partition using LUKS2
            echo "Please enter the encryption password: "
            read -r -s password
            echo "Please confirm the encryption password: "
            read -r -s password_confirm
            if [[ $password == "$password_confirm" ]]; then
                pv_name="vault"
                echo "Creating encrypted partitions..."
                echo -n "$password" | cryptsetup luksFormat --type luks2 "$(get_partition_index 3)" -
                echo -n "$password" | cryptsetup open "$(get_partition_index 3)" $pv_name -

                # ask if user wants to overwrite the disk with random data
                read -r -p "Would you like to overwrite the disk with random data? (y/n): " overwrite
                if [[ $overwrite == [yY] ]]; then
                    echo "Overwriting the disk with random data..."
                    dd if=/dev/zero of=/dev/mapper/$pv_name bs=1M status=progress
                fi

                # Create the LVM physical volume, volume group, and logical volumes
                pvcreate /dev/mapper/$pv_name
                vg_name="Vault"
                vgcreate $vg_name /dev/mapper/$pv_name

                create_encrypted_partitions
            else
                echo "The passwords do not match. Partitioning cancelled."
                exit 0
            fi
        else
            echo "Creating unencrypted partitions..."
            create_unencrypted_partitions
        fi

        # mount boot partition
        mkdir -p /mnt/boot

        mount "$(get_partition_index 2)" /mnt/boot

        echo "Partitioning complete."
    else
        echo "Partitioning cancelled."
        exit 0
    fi
}

function semi_automated_partitioning() {
    select_partition_sizes
    select_filesystem
    display_partition_table
    create_partitions
}

while true; do
    clear
    echo "Please select a partitioning method:"
    echo "1) Semi-automated partitioning"
    echo "2) Semi-automated encrypted partitioning"
    echo "3) Manual partitioning"
    echo "q) Quit"

    read -r -p "Enter your choice (1-3, q to quit): " choice

    case $choice in
        1)
            if display_warning "semi-automated"; then
                semi_automated_partitioning
                break
            fi
        ;;
        2)
            if display_warning "semi-automated encrypted"; then
                ENCRYPTED=true
                semi_automated_partitioning
                break
            fi
        ;;
        3)
            clear
            echo "You have selected manual partitioning."
            echo "Please follow the steps below to manually partition your disk:"
            echo "1. Use 'fdisk' to create partitions on your disk."
            echo "2. Use 'mkfs' to create a filesystem on each partition."
            echo "3. Use 'mount' to mount each filesystem with the root partition being mounted to the /mnt folder."
            echo "4. If you want to create a swap partition, use 'mkswap' to set up the swap area, and 'swapon' to enable it."
            echo "When you are ready, type 'sh installation.sh -h' to start with system installation."
            # use curl to download next script
            curl -O https://raw.githubusercontent.com/czechbol/dotfiles/main/.config/yadm/arch-install/installation.sh
            exit 0
        ;;
        [qQ])
            echo "Quitting the program."
            exit 0
        ;;
        *)
            echo "Invalid selection. Please try again."
        ;;
    esac
done

# tell the user that partitioning is done
clear
echo "Partitioning is done. Starting with system installation."

while true; do
    read -r -p "Would you like to install the system now? (y/n): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        confirm=""
        break
        elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]; then
        confirm=""
        echo "Installation cancelled."
        exit 0
    else
        echo "Invalid input. Please try again."
    fi
done



if $ENCRYPTED; then
    # Run the next script with the e flag and the encrypted disk partition
    sh pacstrap.sh -d "${encrypted_partition}" -p "$pv_name"
else
    sh pacstrap.sh
fi
