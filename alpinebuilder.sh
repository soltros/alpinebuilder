#!/bin/bash

# Check if 'dialog' is installed
if ! command -v dialog &> /dev/null; then
    echo "dialog is not installed. Please install it first."
    exit 1
fi

# Function to display the menu using dialog
show_menu() {
    dialog --clear --title "Select an Option" --menu "Choose an option from the menu:" 18 60 15 \
        1 "Option 1: Setup Xorg" \
        2 "Option 2: Setup Nvidia GPU drivers" \
        3 "Option 3: Setup Pipewire/Wireplumber" \
        4 "Option 4: Configure Networking" \
        5 "Option 5: Configure Dbus" \
        6 "Option 6: Configure Plugdev" \
        7 "Option 7: Configure Eudev" \
        8 "Option 8: Setup Docker" \
        9 "Option 9: Setup Gnome Shell" \
        10 "Option 10: Setup KDE Plasma 5" \
        11 "Option 11: Setup Flatpak" \
        12 "Option 12: Setup NixOS package manager" \
        13 "Option 13: Setup Derriks packages" \
        14 "Option 14: Setup Derriks Flatpak packages" \
        15 "Option 15: Update Alpine" \
        16 "Exit" 2> menu_choice.txt
}

# Function to execute the selected command
execute_command() {
    if [ ! -s menu_choice.txt ]; then
        echo "No selection made or 'dialog' exited with an error."
        return
    fi

    choice=$(< menu_choice.txt)

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
            apk add pipewire wireplumber pipewire-pulse pipewire-alsa;cp -a /usr/share/pipewire /etc;cp -a /usr/share/wireplumber /etc
            echo "Setting up Pipewire..."
            ;;
        4)
            apk add networkmanager networkmanager-wifi;rc-service networkmanager start;rc-update add networkmanager default
            echo "Configuring Network Manager..."
            ;;
        5)
            apk add dbus dbus-x11;rc-update add dbus;rc-service dbus start
            echo "Configuring Dbus..."
            ;;
        6)
            groupadd plugdev;usermod -a -G plugdev derrik
            echo "Configuring Plugdev..."
            ;;
        7)
            apk add alpine-conf;setup-devd udev
            echo "Configuring Udevd..."
            ;;
        8)
            apk add docker docker-cli-compose;addgroup derrik;rc-update add docker default;service docker start
            echo "Setting up Docker..."
            ;;
        9)
            setup-desktop gnome;apk add gnome-apps-extra;rc-update add apk-polkit-server default && rc-service apk-polkit-server start;apk add mesa-gles;rc-service gdm start;rc-update add gdm
            echo "Setting up Gnome Shell..."
            ;;
        10)
            apk add plasma kde-applications sddm;rc-service sddm start;rc-update add sddm
            echo "Setting up KDE Plasma 5..."
            ;;
        11)
            apk add flatpak;flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            echo "Setting up Flatpak..."
            ;;
        12)
            apk add curl;sh <(curl -L https://nixos.org/nix/install) --daemon
            echo "Setting up Nix package manager..."
            ;;
        13)
            apk add gimp tailscale vlc firefox thunderbird git papirus-icon-theme geany distrobox wine fish
            echo "Setting up Derriks packages..."
            ;;
        14)
            flatpak install com.mattjakeman.ExtensionManager com.discordapp.Discord com.spotify.Client com.valvesoftware.Steam org.telegram.desktop tv.plex.PlexDesktop com.nextcloud.desktopclient.nextcloud im.riot.Riot
            echo "Executing Command 14..."
            ;;
        15)
            setup-apkrepos;apk update;apk upgrade --available
            echo "Updating..."
            ;;
        16)
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
    execute_command
done
