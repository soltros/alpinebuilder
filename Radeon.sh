#!/bin/sh

# Radeon Video Setup Script for Alpine Linux

set -e

echo "=== [1/6] Detecting GPU generation... ==="
echo "If you're using Vega or newer, install amdgpu firmware."
echo "Otherwise, install radeon firmware."
echo
echo "Choose your firmware package:"
echo "1) linux-firmware-amdgpu (Vega and later)"
echo "2) linux-firmware-radeon (older cards)"
read -rp "Enter 1 or 2: " firmware_choice

case "$firmware_choice" in
  1)
    apk add linux-firmware-amdgpu
    MODULE="amdgpu"
    ;;
  2)
    apk add linux-firmware-radeon
    MODULE="radeon"
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac

echo "=== [2/6] Enabling Kernel Modesetting (KMS)... ==="

echo "$MODULE" >> /etc/modules
echo "fbcon" >> /etc/modules

apk add mkinitfs

echo "=== [3/6] Configuring mkinitfs for KMS... ==="

MKINITFS_CONF="/etc/mkinitfs/mkinitfs.conf"
if grep -q "kms" "$MKINITFS_CONF"; then
  echo "KMS already present in mkinitfs.conf"
else
  sed -i 's/^features="/features="kms /' "$MKINITFS_CONF"
fi

echo "=== [4/6] Rebuilding initramfs... ==="
mkinitfs

echo "=== [5/6] Installing Wayland drivers... ==="
apk add mesa-dri-gallium mesa-va-gallium

echo "You may need to export MESA_LOADER_DRIVER_OVERRIDE for your GPU:"
echo "- r300, r600, radeonsi"
echo "Example: export MESA_LOADER_DRIVER_OVERRIDE=radeonsi"
echo
echo "For VA-API:"
echo "Example: export LIBVA_DRIVER_NAME=radeonsi"

echo "=== [6/6] (Optional) Installing Xorg drivers... ==="
echo "Do you plan to use Xorg? (y/n)"
read -r xorg_choice

if [ "$xorg_choice" = "y" ]; then
  apk add xf86-video-ati
  modprobe fbcon || true
fi

echo
echo "Setup complete. Reboot your system to apply changes."