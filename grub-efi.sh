#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 
   exit 1
fi

# Step 1: Install GRUB EFI package
apk add grub-efi os-prober efibootmgr

# Step 2: Ensure /boot is on a FAT32 filesystem (manual check required)

# Step 3: Install GRUB for EFI
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Step 4: Modify /etc/default/grub (manual editing required)

# Step 5: Generate GRUB configuration file
grub-mkconfig -o /boot/grub/grub.cfg

echo "GRUB EFI setup completed. Please ensure /boot is on a FAT32 filesystem and modify /etc/default/grub as needed."
