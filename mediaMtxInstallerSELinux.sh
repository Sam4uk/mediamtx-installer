#!/bin/bash

# Dependencies required for the script
REQUIRED_DEPENDENCIES=(curl tar jq)

# Function to install dependencies for Debian/Ubuntu
install_deps_debian() {
    for dep in "${REQUIRED_DEPENDENCIES[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "$dep is not installed. Installing..."
            sudo apt-get update && sudo apt-get install -y "$dep"
        fi
    done
}

# Function to install dependencies for RHEL/Rocky Linux
install_deps_rhel() {
    for dep in "${REQUIRED_DEPENDENCIES[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "$dep is not installed. Installing..."
            sudo yum install -y "$dep"
        fi
    done
}

# Determine the OS and install dependencies
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian|raspbian)
            install_deps_debian
            BIN_PATH="/usr/local/bin"
            CONFIG_PATH="/usr/local/etc"
            ;;
        rhel|rocky|centos)
            install_deps_rhel
            BIN_PATH="/usr/local/bin"
            CONFIG_PATH="/usr/local/etc"
            ;;
        *)
            echo "Unsupported distribution: $ID"
            exit 1
            ;;
    esac
else
    echo "Cannot determine the OS. /etc/os-release not found."
    exit 1
fi

# Define the GitHub repository
REPO="bluenviron/mediamtx"
# GitHub API URL for the latest release
API_URL="https://api.github.com/repos/$REPO/releases/latest"
# Define the target directory
TARGET_DIR="/tmp/mediamtx"

# Determine the CPU architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        ASSET_SUFFIX="_linux_amd64.tar.gz"
        ;;
    armv8*|aarch64)
        ASSET_SUFFIX="_linux_arm64v8.tar.gz"
        ;;
    armv6*)
        ASSET_SUFFIX="_linux_armv6.tar.gz"
        ;;
    armv7*)
        ASSET_SUFFIX="_linux_armv7.tar.gz"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Ensure the target directory exists
sudo mkdir -p "$TARGET_DIR"

# Fetch the latest release data from GitHub API and parse the download URL
DOWNLOAD_URL=$(curl -s $API_URL | jq -r ".assets[] | select(.name | endswith(\"$ASSET_SUFFIX\")) | .browser_download_url")

if [[ $DOWNLOAD_URL != null && $DOWNLOAD_URL != "" ]]; then
    # Download the latest release tarball
    echo "Downloading $DOWNLOAD_URL"
    curl -L $DOWNLOAD_URL -o /tmp/mediamtx.tar.gz
    echo "Download completed."

    # Extract the tar.gz file to the target directory
    sudo tar -xzf /tmp/mediamtx.tar.gz -C "$TARGET_DIR"

    # Move the executable and config to their respective locations
    sudo mv "$TARGET_DIR/mediamtx" "$BIN_PATH/"
    sudo mv "$TARGET_DIR/mediamtx.yml" "$CONFIG_PATH/"

    # Set the executable permission
    sudo chmod +x "$BIN_PATH/mediamtx"

    # Adjust SELinux policies if SELinux is enabled
    if command -v getenforce &> /dev/null && [ "$(getenforce)" != "Disabled" ]; then
        sudo semanage fcontext -a -t bin_t "$BIN_PATH/mediamtx"
        sudo restorecon -v "$BIN_PATH/mediamtx"
    fi

    # Create systemd service
    sudo tee /etc/systemd/system/mediamtx.service >/dev/null <<EOF
[Unit]
Description=MediaMTX Service
After=network.target

[Service]
ExecStart=$BIN_PATH/mediamtx $CONFIG_PATH/mediamtx.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd, enable and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable mediamtx
    sudo systemctl start mediamtx
    sudo journalctl -u mediamtx

else
    echo "Failed to find a valid download URL for the latest release."
fi
