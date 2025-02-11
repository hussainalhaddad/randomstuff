#!/bin/bash

# Check if curl is installed
if ! command -v curl &>/dev/null; then
    echo "curl is not installed. Installing..."
    sudo apt update -y > /dev/null 2>&1 && sudo apt install curl -y > /dev/null 2>&1
fi

# Detect architecture
arch=$(uname -m)

# Get the latest release version from GitHub
version=$(basename "$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/fosrl/newt/releases/latest)")

# Set the download URL based on architecture
if [[ "$arch" == "x86_64" ]]; then
    newt_url="https://github.com/fosrl/newt/releases/download/$version/newt_linux_amd64"
elif [[ "$arch" == "aarch64" ]]; then
    newt_url="https://github.com/fosrl/newt/releases/download/$version/newt_linux_arm64"
else
    echo "Unknown architecture: $arch"
    exit 1
fi

# Prompt for user input
read -p 'ID: ' id
read -p 'Secret: ' secret
read -p 'Endpoint: ' endpoint

# Download and install Newt
echo "Installing Newt version $version for $arch..."
wget -q -O /usr/local/bin/newt "$newt_url"
chmod +x /usr/local/bin/newt

# Create systemd service for Newt
cat > /etc/systemd/system/newt.service <<EOL
[Unit]
Description=Newt VPN Client - Version $version
After=network.target

[Service]
ExecStart=/usr/local/bin/newt --id $id --secret $secret --endpoint $endpoint
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
systemctl enable --quiet newt.service
systemctl start --quiet newt.service

# Final message
echo "Newt has been installed and configured to run automatically."
echo "Run 'systemctl status newt.service' to check the status."
