#!/bin/bash

# Function to display the menu
show_menu() {
    echo "Select an Option:"
    echo "1) Option 1: Setup Xorg"
    echo "2) Option 2: Setup Nvidia GPU drivers"
    echo "3) Option 3: Setup Pipewire/Wireplumber"
    echo "4) Option 4: Configure Networking"
    echo "5) Option 5: Configure Dbus"
    echo "6) Option 6: Configure Plugdev"
    echo "7) Option 7: Configure Eudev"
    echo "8) Option 8: Setup Docker"
    echo "9) Option 9: Setup Gnome Shell"
    echo "10) Option 10: Setup KDE Plasma 5"
    echo "11) Option 11: Setup Flatpak"
    echo "12) Option 12: Setup NixOS package manager"
    echo "13) Option 13: Setup Derriks packages"
    echo "14) Option 14: Setup Derriks Flatpak packages"
    echo "15) Option 15: Update Alpine"
    echo "16) Option 16: Convert Alpine Ext4 to Btrfs"
    echo "17) Exit"
}

# Function to convert filesystem to Btrfs
convert_to_btrfs() {
    # Check if btrfs-convert is installed
    if ! command -v btrfs-convert &> /dev/null; then
        echo "btrfs-convert is not installed. Please install btrfs-progs first."
        return 1
    fi

    # Get the device to convert
    read -rp "Enter the device to convert to Btrfs (e.g., /dev/sda1): " device

    # Verify that the device is not mounted
    if mount | grep -q "$device"; then
        echo "The device $device is mounted. Please unmount it before proceeding."
        return 1
    fi

    # Confirm with the user
    read -rp "Are you sure you want to convert $device to Btrfs? This cannot be undone. [y/N]: " confirmation
    if [[ $confirmation != "y" && $confirmation != "Y" ]]; then
        echo "Conversion cancelled."
        return 1
    fi

    # Perform the conversion
    echo "Converting $device to Btrfs..."
    if btrfs-convert "$device"; then
        echo "Conversion completed successfully."
    else
        echo "Conversion failed."
        return 1
    fi
}

# Function to execute the selected command
execute_command() {
    case $choice in
        1)
            setup-xorg-base
            echo "Setting up Xorg..."
            ;;
        2)
            apk add xf86-video-nouveau mesa-dri-gallium mesa-va-gallium
            echo "Setting up Open-source Nvidia drivers..."
            ;;
        3)
            apk add pipewire wireplumber pipewire-pulse pipewire-alsa; cp -a /usr/share/pipewire /etc; cp -a /usr/share/wireplumber /etc
            echo "Setting up Pipewire..."
            ;;
        4)
            apk add networkmanager networkmanager-wifi; rc-service networkmanager start; rc-update add networkmanager default
            echo "Configuring Network Manager..."
            ;;
        5)
            apk add dbus dbus-x11; rc-update add dbus; rc-service dbus start
            echo "Configuring Dbus..."
            ;;
        6)
            groupadd plugdev; usermod -a -G plugdev derrik
            echo "Configuring Plugdev..."
            ;;
        7)
            apk add alpine-conf; setup-devd udev
            echo "Configuring Udevd..."
            ;;
        8)
            apk add docker docker-cli-compose; addgroup derrik; rc-update add docker default; service docker start
            echo "Setting up Docker..."
            ;;
        9)
            setup-desktop gnome; apk add gnome-apps-extra; rc-update add polkit default && rc-service polkit start; apk add mesa-gles; rc-service gdm start; rc-update add gdm
            echo "Setting up Gnome Shell..."
            ;;
        10)
            apk add plasma kde-applications sddm; rc-service sddm start; rc-update add sddm
            echo "Setting up KDE Plasma 5..."
            ;;
        11)
            apk add flatpak; flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            echo "Setting up Flatpak..."
            ;;
        12)
            apk add curl; sh <(curl -L https://nixos.org/nix/install) --daemon
            echo "Setting up Nix package manager..."
            ;;
        13)
            apk add gimp tailscale vlc firefox thunderbird git papirus-icon-theme geany distrobox wine fish
            echo "Setting up Derriks packages..."
            ;;
        14)
            flatpak install com.mattjakeman.ExtensionManager com.discordapp.Discord com.spotify.Client com.valvesoftware.Steam org.telegram.desktop tv.plex.PlexDesktop com.nextcloud.desktopclient.nextcloud im.riot.Riot
            echo "Setting up Derriks Flatpak packages..."
            ;;
        15)
            setup-apkrepos; apk update; apk upgrade --available
            echo "Updating..."
            ;;
        16)
            convert_to_btrfs
            ;;
        17)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid selection. Please try again."
            ;;
    esac
}

# Main loop to display the menu and execute commands
while true; do
    show_menu
    read -rp "Enter your choice: " choice
    execute_command
done