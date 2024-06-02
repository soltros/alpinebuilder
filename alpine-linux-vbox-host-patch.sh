#!/bin/bash

# VirtualBox Module Installation Script for Alpine Linux

# Constants and Variables
WORKSPACE="/tmp/virtualbox-modules-workspace"
SOURCE_URL="https://america.mirror.pkgbuild.com/extra/os/x86_64/virtualbox-host-dkms-7.0.18-1-x86_64.pkg.tar.zst"
PACKAGE_NAME="virtualbox-host-dkms-7.0.18-1-x86_64.pkg.tar.zst"
BUILD_DIR="$WORKSPACE/usr/src/vboxhost-7.0.18_OSE"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Function to log messages and progress
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Set up workspace
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# Download source files
log "Downloading VirtualBox DKMS source files..."
wget -O "$PACKAGE_NAME" "$SOURCE_URL" || {
    log "Failed to download source files. Exiting."
    exit 1
}

# Extract source files
log "Extracting source files..."
tar -xf "$PACKAGE_NAME" || {
    log "Failed to extract source files. Exiting."
    exit 1
}

# Change to build directory
cd "$BUILD_DIR"

# Compile and install modules
log "Compiling VirtualBox kernel modules..."
make || {
    log "Failed to compile modules. Exiting."
    exit 1
}
make install

log "VirtualBox kernel modules installed successfully!"

# Cleanup (optional)
# rm -rf "$WORKSPACE"  # Uncomment if you want to remove the workspace after installation
