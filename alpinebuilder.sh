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
    echo "16) Option 16: Setup Tailscale"
    echo "17) Exit"
}

# Function to execute the selected command
execute_command() {
    case $choice in
        1)
            setup-xorg-base
            echo "Setting up Xorg..."
            ;;
        2)
            apk add xf86-video-nouveau mesa-dri-gallium mesa-va-gallium;curl https://raw.githubusercontent.com/soltros/alpinebuilder/main/nvidia-oss-module-installer.sh | sh

            echo "Setting up Open-source Nvidia drivers..."
            ;;
        3)
            apk add pipewire wireplumber pipewire-pulse pipewire-alsa; cp -a /usr/share/pipewire /etc; cp -a /usr/share/wireplumber /etc
            echo "Setting up Pipewire..."
            ;;
        4)
            apk add networkmanager nfs-utils networkmanager-wifi;wget https://raw.githubusercontent.com/soltros/alpinebuilder/main/configs/NetworkManager.conf -O /etc/NetworkManager/NetworkManager.conf;rc-service networkmanager start; rc-update add networkmanager default;rc-service networking stop;rc-update del networking boot;rc-service networkmanager restart
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
            apk add gimp tailscale vlc nano firefox thunderbird git papirus-icon-theme geany distrobox wine fish util-linux pciutils hwdata-pci usbutils hwdata-usb coreutils binutils findutils grep iproute2 bash bash-completion udisks2 build-base abuild cmake extra-cmake-modules
            echo "Setting up Derriks packages..."
            ;;
        14)
            flatpak install com.mattjakeman.ExtensionManager com.discordapp.Discord io.kopia.KopiaUI com.spotify.Client com.valvesoftware.Steam org.telegram.desktop tv.plex.PlexDesktop com.nextcloud.desktopclient.nextcloud im.riot.Riot -y
            echo "Setting up Derriks Flatpak packages... - Don't run as root"
            ;;
        15)
            setup-apkrepos; apk update; apk upgrade --available
            echo "Updating..."
            ;;
        16)
            rc-service tailscale start;rc-update add tailscale;doas tailscale up -qr
            echo "Configuring Tailscale..."
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
