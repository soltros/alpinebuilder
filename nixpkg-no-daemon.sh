#!/bin/sh

# Install necessary tools
echo "Installing necessary tools..."
sudo apk add curl tar gzip bash

# Download and install Nix
echo "Downloading and installing Nix..."
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Add Nix profile to shell configuration
echo "Configuring shell profile..."
if [ -n "$BASH_VERSION" ]; then
    PROFILE_FILE="$HOME/.bashrc"
    PROFILE_LINE="if [ -e /home/\$USER/.nix-profile/etc/profile.d/nix.sh ]; then . /home/\$USER/.nix-profile/etc/profile.d/nix.sh; fi"
elif [ -n "$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
    PROFILE_LINE="if [ -e /home/\$USER/.nix-profile/etc/profile.d/nix.sh ]; then . /home/\$USER/.nix-profile/etc/profile.d/nix.sh; fi"
else
    echo "Unsupported shell. Please configure your shell profile manually."
    exit 1
fi

if ! grep -Fxq "$PROFILE_LINE" "$PROFILE_FILE"; then
    echo "$PROFILE_LINE" >> "$PROFILE_FILE"
fi

# Source the profile
echo "Sourcing shell profile..."
. "$PROFILE_FILE"

# Create a script to start the Nix daemon
echo "Creating Nix daemon start script..."
sudo mkdir -p /etc/nix
sudo tee /etc/nix/start-nix-daemon.sh <<EOF
#!/bin/sh
if [ -x /nix/var/nix/profiles/default/bin/nix-daemon ]; then
    /nix/var/nix/profiles/default/bin/nix-daemon &
fi
EOF

# Make the script executable
echo "Making the script executable..."
sudo chmod +x /etc/nix/start-nix-daemon.sh

# Add the script to the boot process
echo "Adding script to boot process..."
sudo mkdir -p /etc/local.d
sudo ln -s /etc/nix/start-nix-daemon.sh /etc/local.d/nix.start
sudo rc-update add local default

# Start the Nix daemon now
echo "Starting Nix daemon..."
sudo /etc/nix/start-nix-daemon.sh

# Verify the installation
echo "Verifying Nix installation..."
if nix-env --version; then
    echo "Nix installation successful!"
else
    echo "Nix installation failed. Please check the logs."
fi
